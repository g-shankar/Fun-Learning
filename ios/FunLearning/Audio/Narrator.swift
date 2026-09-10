import AVFoundation
import Foundation

// MARK: - Warm narrator voice for toddlers

final class Narrator: ObservableObject {
    var enabled: Bool = true

    private let synth = AVSpeechSynthesizer()

    private let praises = [
        "Great job!", "Wonderful!", "You did it!", "Amazing!",
        "Super tracing!", "Yay! Beautiful!", "Wow, so good!",
    ]

    /// Speak text with a warm, slow toddler-friendly voice.
    func speak(_ text: String, rate: Float = 0.42) {
        guard enabled else { return }
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = rate
        utterance.pitchMultiplier = 1.1
        utterance.preUtteranceDelay = 0.15
        utterance.postUtteranceDelay = 0.25
        synth.speak(utterance)
    }

    func introduce(lesson: LetterLesson, letterCase: LetterCase) {
        let kind = letterCase == .upper ? "capital" : "small"
        speak("Let's trace the \(kind) letter \(lesson.char). \(lesson.char) is for \(lesson.word)!")
    }

    func instructStroke(number: Int) {
        speak("Now trace stroke \(number).", rate: 0.45)
    }

    func praise() {
        speak(praises.randomElement() ?? "Great job!")
    }

    func sayWord(for lesson: LetterLesson) {
        speak("\(lesson.char). \(lesson.word).")
    }

    func celebrate(lesson: LetterLesson) {
        speak("Yay! You traced the letter \(lesson.char)! \(lesson.char) is for \(lesson.word)!")
    }

    func gentleNudge() {
        speak("Follow the dotted line.", rate: 0.45)
    }
}
