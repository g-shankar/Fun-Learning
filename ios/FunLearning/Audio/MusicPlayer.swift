import AVFoundation
import Foundation

// MARK: - Gentle looping background music + celebration chime
//
// music_loop.wav / chime.wav are synthesized placeholders (see /tmp/gen_music.py
// in the build notes). Final composed tracks will replace them 1:1 — same names.

final class MusicPlayer: ObservableObject {
    @Published var muted: Bool = false {
        didSet { applyVolume() }
    }

    private var player: AVAudioPlayer?
    private var chimePlayer: AVAudioPlayer?

    init() {
        configureSession()
        if let url = Bundle.main.url(forResource: "music_loop", withExtension: "wav") {
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
