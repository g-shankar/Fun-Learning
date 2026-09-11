import Foundation
import StoreKit

// MARK: - StoreKit 2: one-time unlock + yearly subscription
//
// Single source of truth for "does this device own the full app".
// Entitlement = StoreKit currentEntitlements (verified) OR the local cache
// (so the unlock works offline). Purchases made outside the app are picked
// up by the Transaction.updates listener.

final class StoreManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var isUnlocked: Bool = StoreConfig.cachedUnlock
    @Published var isBusy: Bool = false
    @Published var lastError: String? = nil

    private var updateTask: Task<Void, Never>? = nil

    init() {
        updateTask = listenForTransactions()
        Task { await refresh() }
    }

    deinit { updateTask?.cancel() }

    var foreverProduct: Product? {
        products.first { $0.id == StoreConfig.unlockForeverID }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == StoreConfig.yearlyID }
    }

    // MARK: - Catalog

    func refresh() async {
        setBusy(true)
        defer { setBusy(false) }
        do {
            let fetched = try await Product.products(for: StoreConfig.allProductIDs)
            await MainActor.run { self.products = fetched }
            await syncEntitlement()
        } catch {
            setError("Couldn't reach the App Store. Check your connection and try again.")
        }
    }

    // MARK: - Purchase

    /// Returns true when the purchase completed and unlocked the app.
    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        setBusy(true)
        defer { setBusy(false) }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checked(verification)
                await transaction.finish()
                setUnlocked(true)
                return true
            case .userCancelled:
                return false
            case .pending:
                setError("Purchase is pending approval.")
                return false
            @unknown default:
                return false
            }
        } catch {
            setError("Purchase failed. Please try again.")
            return false
        }
    }

    // MARK: - Restore

    /// Returns true when an existing purchase was found and applied.
    @discardableResult
    func restore() async -> Bool {
        setBusy(true)
        defer { setBusy(false) }
        do {
            try await AppStore.sync()
            let found = await hasEntitlement()
            if found { setUnlocked(true) }
            return found
        } catch {
            setError("Couldn't reach the App Store. Check your connection and try again.")
            return false
        }
    }

    // MARK: - Entitlement

    private func hasEntitlement() async -> Bool {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if StoreConfig.allProductIDs.contains(transaction.productID) {
                return true
            }
        }
        return false
    }

    private func syncEntitlement() async {
        // Never downgrade from the cache on an empty result: offline the
        // entitlement list can be empty even for paying users.
        if await hasEntitlement() { setUnlocked(true) }
    }

    private func setUnlocked(_ value: Bool) {
        DispatchQueue.main.async {
            self.isUnlocked = value
            StoreConfig.cachedUnlock = value
        }
    }

    private func setBusy(_ value: Bool) {
        DispatchQueue.main.async { self.isBusy = value }
    }

    private func setError(_ message: String) {
        DispatchQueue.main.async { self.lastError = message }
    }

    // MARK: - Background transaction listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                if StoreConfig.allProductIDs.contains(transaction.productID) {
                    await MainActor.run {
                        self.isUnlocked = true
                        StoreConfig.cachedUnlock = true
                    }
                }
                await transaction.finish()
            }
        }
    }

    private func checked<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value): return value
        case .unverified: throw StoreError.unverified
        }
    }
}

enum StoreError: Error {
    case unverified
}
