import SwiftUI
import StoreKit

// MARK: - Paywall: one-time unlock OR yearly subscription — the parent chooses.
//
// Kids-category safe: no analytics, no accounts, no external links, no ads.
// Every purchase/restore goes through the grown-ups gate first.

struct PaywallView: View {
    @ObservedObject var gameState: GameState
    @Environment(\.dismiss) private var dismiss

    @State private var showGate = false
    @State private var pendingProduct: Product? = nil
    @State private var didRestoreNothing = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    MascotView(state: .wave, size: 110)

                    Text("Unlock Fun Learning")
                        .font(.system(size: 32, weight: .black))

                    Text("Every letter A–Z in both cases, plus Numbers, Shapes, Words and every future world. One payment or yearly — your choice.")
                        .font(.system(size: 17))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)

                    if let product = gameState.store.foreverProduct {
                        productCard(product: product,
                                    title: "Unlock Forever",
                                    blurb: "One payment. Yours forever.",
                                    accent: .orange)
                    }

                    if let product = gameState.store.yearlyProduct {
                        productCard(product: product,
                                    title: "Yearly",
                                    blurb: "Billed once a year. Cancel anytime.",
                                    accent: .blue)
                    }

                    if gameState.store.products.isEmpty && !gameState.store.isBusy {
                        VStack(spacing: 10) {
                            Text("Couldn't load purchase options. Check your connection.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Button("Retry") {
                                Task { await gameState.store.refresh() }
                            }
                            .font(.headline)
                        }
                        .padding(.vertical, 8)
                    }

                    if let error = gameState.store.lastError {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button("Restore Purchases") {
                        didRestoreNothing = false
                        Task {
                            let found = await gameState.store.restore()
                            if found {
                                dismiss()
                            } else {
                                didRestoreNothing = true
                            }
                        }
                    }
                    .font(.system(size: 18, weight: .bold))
                    .padding(.top, 6)

                    if didRestoreNothing {
                        Text("No previous purchases found on this Apple ID.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    Text("For parents: payments are handled securely by Apple. No ads, no accounts, no data collection.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 8)
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showGate) {
                ParentalGateView {
                    if let product = pendingProduct {
                        Task {
                            if await gameState.store.purchase(product) {
                                dismiss()
                            }
                        }
                    }
                }
            }
            .disabled(gameState.store.isBusy)
            .overlay {
                if gameState.store.isBusy {
                    ProgressView()
                        .scaleEffect(1.6)
                }
            }
        }
        .task { await gameState.store.refresh() }
    }

    private func productCard(product: Product,
                            title: String,
                            blurb: String,
                            accent: Color) -> some View {
        Button {
            pendingProduct = product
            showGate = true
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.primary)
                    Text(blurb)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(product.displayPrice)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(accent)
                    .clipShape(Capsule())
            }
            .padding(18)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(accent.opacity(0.55), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
