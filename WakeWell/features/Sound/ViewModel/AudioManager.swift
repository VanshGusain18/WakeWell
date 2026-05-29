import AVFoundation

final class AudioManager {

    static let shared = AudioManager()

    private var player: AVAudioPlayer?
    private(set) var currentSound: Sound?

    private var playlist: [Sound] = []
    private var currentIndex: Int = 0

    private init() {}

    // Playback State
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }

    var duration: TimeInterval {
        return player?.duration ?? 0
    }

    var currentTime: TimeInterval {
        return player?.currentTime ?? 0
    }

    // Play Single Sound
    func play(sound: Sound) {

        // Avoid restarting same sound
        if currentSound?.fileName == sound.fileName, isPlaying {
            return
        }

        guard let url = Bundle.main.url(
            forResource: sound.fileName,
            withExtension: "mp3"
        ) else {
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()

            currentSound = sound

        } catch {
        }
    }

    // Play / Pause
    func togglePlayPause() {
        guard let player = player else { return }

        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }

  // Playlist
    func setPlaylist(_ sounds: [Sound], startIndex: Int = 0) {
        guard !sounds.isEmpty else { return }

        playlist = sounds
        currentIndex = startIndex
        play(sound: playlist[currentIndex])
    }

    func playNext() {
        guard !playlist.isEmpty else { return }

        currentIndex = (currentIndex + 1) % playlist.count
        play(sound: playlist[currentIndex])
    }

    func playPrevious() {
        guard !playlist.isEmpty else { return }

        currentIndex = (currentIndex - 1 + playlist.count) % playlist.count
        play(sound: playlist[currentIndex])
    }

  // Seek
    func seek(to time: TimeInterval) {
        player?.currentTime = time
    }

  // Stop
    func stop() {
        player?.stop()
        player = nil
        currentSound = nil
    }

    // Helper
    func isPlaying(sound: Sound) -> Bool {
        return currentSound?.fileName == sound.fileName && isPlaying
    }
}
