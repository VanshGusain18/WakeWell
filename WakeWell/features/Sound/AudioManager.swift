import AVFoundation

final class AudioManager {

    static let shared = AudioManager()

    private var player: AVAudioPlayer?
    private(set) var currentSound: Sound?
    private var playlist: [Sound] = []
    private var currentIndex: Int = 0

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
    func setPlaylist(sounds: [Sound], startIndex: Int) {
        playlist = sounds
        currentIndex = startIndex
        play(sound: playlist[currentIndex])
    }
    func playNext() {
        guard !playlist.isEmpty else { return }

        currentIndex += 1

        if currentIndex >= playlist.count {
            currentIndex = 0   // 🔁 loop inside category
        }

        play(sound: playlist[currentIndex])
    }
//slider value
    var duration: TimeInterval {
        return player?.duration ?? 0
    }

    var currentTime: TimeInterval {
        return player?.currentTime ?? 0
    }

    func seek(to time: TimeInterval) {
        player?.currentTime = time
    }

    func playPrevious() {
        guard !playlist.isEmpty else { return }

        currentIndex -= 1

        if currentIndex < 0 {
            currentIndex = playlist.count - 1   // 🔁 loop backwards
        }

        play(sound: playlist[currentIndex])
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
