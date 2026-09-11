import Foundation

// MARK: - Store configuration: product IDs + free/paid boundary
//
// GOWRISHANKAR — ACTION REQUIRED in App Store Connect
// (needs the Apple Developer Program, $99/yr, + the Paid Apps agreement signed):
//
//   1. Create a NON-CONSUMABLE product:
//        Product ID : funlearning.unlock.forever
//        Name       : "Unlock Everything Forever"
//   2. Create an AUTO-RENEWABLE SUBSCRIPTION product:
//        Product ID : funlearning.yearly
//        Name       : "Yearly"
//        Duration   : 1 year
//
// Prices are set in App Store Connect — the app reads each product's
// displayPrice live, so nothing is hardcoded here.

enum StoreConfig {
    /// One-time purchase: unlocks everything forever.
    static let unlockForeverID = "funlearning.unlock.forever"
    /// Auto-renewable subscription: unlocks everything while active.
    static let yearlyID = "funlearning.yearly"

    static var allProductIDs: [String] { [unlockForeverID, yearlyID] }

    /// Free tier: letters A–C (indices 0..<3), upper + lower, free forever.
    /// Everything from D onward (and all future worlds) needs the unlock.
    static let freeLetterCount = 3

    // Local entitlement cache so the unlock survives offline + reinstalls
    // restore it. StoreKit's currentEntitlements is the source of truth;
    // this is the fallback.
    private static let unlockKey = "funlearning.unlocked"

    static var cachedUnlock: Bool {
        get { UserDefaults.standard.bool(forKey: unlockKey) }
        set { UserDefaults.standard.set(newValue, forKey: unlockKey) }
    }
}
