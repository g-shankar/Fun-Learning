import AVFoundation
import Foundation

// MARK: - Cheerful looping background music + celebration chime
//
// bgm_cheerful.mp3 is the composed ukulele-style loop (see
// ~/workspace/fun-learning/music/make_bgm.py). Fully synthesized in-house,
// so there are no licensing issues.

final class MusicPlayer: ObservableObject {
    @Published var muted: Bool = false {
        didSet { applyVolume() }
    }

    private var player: AVAudioPlayer?
    private var chimePlayer: AVAudioPlayer?

    init() {
        configureSession()
        if let url = Bundle.main.url(forResource: "bgm_cheerful", withExtension: "mp3") {
            player = try? AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = 0.32
            player?.prepareToPlay()
        }
        if let url = Bundle.main.url(forResource: "chime", withExtension: "wav") {
            chimePlayer = try? AVAudioPlayer(contentsOf: url)
            chimePlayer?.volume = 0.6
            chimePlayer?.prepareToPlay()
        }
    }

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback,
                                                            options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session failed: \(error)")
        }
    }

    private func applyVolume() {
        player?.volume = muted ? 0 : 0.32
    }

    func start() {
        guard !muted else { return }
        if player?.isPlaying != true { player?.play() }
    }

    func stop() {
        player?.stop()
    }

    func playChime() {
        guard !muted else { return }
        chimePlayer?.play()
    }
}
