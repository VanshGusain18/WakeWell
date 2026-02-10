import AVFoundation

final class AudioManager {

    static let shared = AudioManager()

    private var player: AVAudioPlayer?
    private(set) var currentSound: Sound?

    private init() {}

    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }

    // MARK: - Play Sound
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
            player?.prepareToPlay()
            player?.play()

            currentSound = sound

            // 🔔 Notify Mini Player
            NotificationCenter.default.post(
                name: .audioDidStart,
                object: nil
            )

        } catch {
            print("❌ Audio error:", error)
        }
    }

    // MARK: - Play / Pause
    func togglePlayPause() {
        guard let player = player else { return }

        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }

        // 🔔 Notify Mini Player
        NotificationCenter.default.post(
            name: .audioDidToggle,
            object: nil
        )
    }

    // MARK: - Stop
    func stop() {
        player?.stop()
        player = nil
        currentSound = nil

        // 🔔 Notify Mini Player
        NotificationCenter.default.post(
            name: .audioDidStop,
            object: nil
        )
    }

    func isPlaying(sound: Sound) -> Bool {
        return currentSound?.fileName == sound.fileName && isPlaying
    }
}

extension Notification.Name {
    static let audioDidStart = Notification.Name("audioDidStart")
    static let audioDidToggle = Notification.Name("audioDidToggle")
    static let audioDidStop = Notification.Name("audioDidStop")
}
