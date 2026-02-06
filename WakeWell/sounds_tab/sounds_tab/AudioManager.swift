import AVFoundation

final class AudioManager {
    static let shared = AudioManager()

    private var player: AVAudioPlayer?
    private(set) var currentSound: Sound?

    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }

    func play(sound: Sound) {
        // If same sound is already playing, do nothing
        if currentSound?.fileName == sound.fileName, isPlaying {
            return
        }

        guard let url = Bundle.main.url(
            forResource: sound.fileName,
            withExtension: "mp3"
        ) else {
            print("❌ Sound not found")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.play()
            currentSound = sound
        } catch {
            print("❌ Audio error:", error)
        }
    }

    // ✅ THIS is what your button is calling
    func togglePlayPause() {
        guard let player = player else { return }

        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }

    func stop() {
        player?.stop()
        currentSound = nil
    }

    func isPlaying(sound: Sound) -> Bool {
        return currentSound?.fileName == sound.fileName && isPlaying
    }
}
