import AVFoundation
import Foundation

// MARK: - Prerecorded narrator voices (no more robotic speech synthesis)
//
// All narration is played from bundled MP3 clips recorded in three voices:
// warm, bubbly and chipper. Files live in Resources/Voice/ with a
// "<voice>_" filename prefix so they stay unique no matter how XcodeGen
// adds the Resources folder (groups vs folder references).

enum NarratorVoice: String, CaseIterable {
    case warm, bubbly, chipper

    var title: String { rawValue.capitalized }
}

final class Narrator: ObservableObject {
    @Published var voice: NarratorVoice = .warm
    var enabled: Bool = true

    private var player: AVAudioPlayer?
    private var lastClip: String = ""
    private var lastPlayTime: Date = .distantPast

    /// Same clip retriggered inside this window is ignored (no-repeat rule).
    private let debounceInterval: TimeInterval = 1.2

    // MARK: - Core playback

    /// Play one clip from the selected voice's pack.
    /// Single shared player: the active clip is stopped before the new one
    /// starts, so narration can never overlap itself.
    private func play(_ clip: String, voice overrideVoice: NarratorVoice? = nil) {
        guard enabled else { return }
        let now = Date()
        if clip == lastClip, now.timeIntervalSince(lastPlayTime) < debounceInterval { return }
        let v = overrideVoice ?? voice
        let name = "\(v.rawValue)_\(clip)"
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
        do {
            player?.stop()
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            lastClip = clip
            lastPlayTime = now
        } catch {
            // Stay silent rather than crash a kids' app.
        }
    }

    /// Filename slug for a lesson's word: "Ice cream" -> "icecream".
    private func wordSlug(_ word: String) -> String {
        word.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
    }

    private func letterSlug(_ char: String) -> String {
        char.lowercased()
    }

    // MARK: - Narration moments (mirrors the web demo's clip map)

    /// Lesson intro: "Let's trace the big/little letter A together!"
    func introduce(lesson: LetterLesson, letterCase: LetterCase) {
        let l = letterSlug(lesson.char)
        play(letterCase == .upper ? "trace_cap_\(l)" : "trace_sml_\(l)")
    }

    /// Stroke guidance. Clips: 1 -> "Start at the number one dot.",
    /// 2 -> "Follow the dotted path.", 3+ -> "Almost there, keep going!"
    func instructStroke(number: Int) {
        switch number {
        case 1: play("guide_1")
        case 2: play("guide_2")
        default: play("guide_3")
        }
    }

    func praise() {
        play("praise_\([1, 2, 3, 4].randomElement() ?? 1)")
    }

    /// Word card speaker button: just the word, e.g. "Apple!"
    func sayWord(for lesson: LetterLesson) {
        play("word_\(wordSlug(lesson.word))")
    }

    /// Lesson complete celebration.
    func celebrate(lesson: LetterLesson) {
        play([ "cheer_1", "cheer_2" ].randomElement() ?? "cheer_1")
    }

    /// Idle nudge: "Follow the dotted path."
    func gentleNudge() {
        play("guide_2")
    }

    /// Island welcome: "Hi! I'm Pip! Let's trace letters together! Yay!"
    func welcome() {
        play("pip_hello")
    }

    /// Letter node tapped: "B is for Bear! buh, buh, Bear!"
    func letterTapped(lesson: LetterLesson) {
        let l = letterSlug(lesson.char)
        play("\(l)_is_for_\(wordSlug(lesson.word))")
    }

    /// Preview a voice in the picker without changing the selection.
    func preview(voice v: NarratorVoice) {
        play("pip_hello", voice: v)
    }
}
