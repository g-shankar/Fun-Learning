import Foundation
import Combine

// MARK: - Global game state: progress, settings, shared services

final class GameState: ObservableObject {
    static let shared = GameState()

    /// How many lessons are unlocked per case (1-based count; lesson 0 always open).
    @Published var unlockedUpper: Int = 1
    @Published var unlockedLower: Int = 1
    /// Stars earned per lesson id ("A-upper"), 0...3.
    @Published var stars: [String: Int] = [:]

    @Published var musicMuted: Bool = false
    @Published var voiceEnabled: Bool = true
    @Published var narratorVoice: NarratorVoice = .warm

    /// Full-app unlock (one-time purchase or yearly subscription).
    /// Mirrors StoreManager; persisted via StoreConfig.cachedUnlock.
    @Published var isUnlocked: Bool = false
    /// Set to true anywhere to present the paywall (RootView owns the sheet).
    @Published var paywallRequested: Bool = false

    let narrator = Narrator()
    let music = MusicPlayer()
    let store = StoreManager()

    private let defaults = UserDefaults.standard

    private init() {
        unlockedUpper = max(1, defaults.integer(forKey: "unlockedUpper") == 0 ? 1 : defaults.integer(forKey: "unlockedUpper"))
        unlockedLower = max(1, defaults.integer(forKey: "unlockedLower") == 0 ? 1 : defaults.integer(forKey: "unlockedLower"))
        stars = (try? JSONDecoder().decode([String: Int].self,
                                           from: defaults.data(forKey: "stars") ?? Data())) ?? [:]
        musicMuted = defaults.bool(forKey: "musicMuted")
        voiceEnabled = defaults.object(forKey: "voiceEnabled") == nil ? true : defaults.bool(forKey: "voiceEnabled")
        narrator.enabled = voiceEnabled
        if let saved = defaults.string(forKey: "narratorVoice"),
           let v = NarratorVoice(rawValue: saved) {
            narratorVoice = v
        }
        narrator.voice = narratorVoice
        music.muted = musicMuted
        // Mirror the store's entitlement; stays live for purchases/restores.
        isUnlocked = store.isUnlocked
        store.$isUnlocked
            .receive(on: DispatchQueue.main)
            .assign(to: &$isUnlocked)
    }

    func save() {
        defaults.set(unlockedUpper, forKey: "unlockedUpper")
        defaults.set(unlockedLower, forKey: "unlockedLower")
        defaults.set(try? JSONEncoder().encode(stars), forKey: "stars")
        defaults.set(musicMuted, forKey: "musicMuted")
        defaults.set(voiceEnabled, forKey: "voiceEnabled")
        defaults.set(narratorVoice.rawValue, forKey: "narratorVoice")
    }

    /// Change the narrator voice, persist it, and confirm with a greeting.
    func setNarratorVoice(_ v: NarratorVoice) {
        narratorVoice = v
        narrator.voice = v
        save()
        narrator.preview(voice: v)
    }

    func unlockedCount(for letterCase: LetterCase) -> Int {
        letterCase == .upper ? unlockedUpper : unlockedLower
    }

    /// Free tier: letters A–C (indices 0..<freeLetterCount), both cases.
    /// Everything else needs the paid unlock.
    func canAccessLesson(index: Int) -> Bool {
        index < StoreConfig.freeLetterCount || isUnlocked
    }

    /// Record a finished lesson: award stars, unlock the next stop on the island.
    func completeLesson(_ lesson: LetterLesson, letterCase: LetterCase, drifts: Int) {
        let earned = drifts <= 2 ? 3 : (drifts <= 6 ? 2 : 1)
        stars[lesson.id] = max(stars[lesson.id] ?? 0, earned)
        let lessons = LessonData.lessons(for: letterCase)
        if let idx = lessons.firstIndex(of: lesson), idx + 1 < lessons.count {
            if letterCase == .upper {
                unlockedUpper = max(unlockedUpper, idx + 2)
            } else {
                unlockedLower = max(unlockedLower, idx + 2)
            }
        }
        save()
    }
}
