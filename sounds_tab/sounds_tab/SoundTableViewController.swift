import UIKit
import AVFoundation
class SoundTableViewController: UITableViewController {

    @IBOutlet weak var segmentView: UISegmentedControl!

    
    var allSounds: [Sound] = [
        Sound(
            title: "Sitar Flute Tabla",
            category: .nature,
            duration: 600,
            fileName: "Sitar_Flute_Tabla",
            imageName: "sea"
        )

    ]

    var filteredSounds: [Sound] = []
    var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        filteredSounds = allSounds
        segmentView.addTarget(self,
                              action: #selector(segmentChanged(_:)),
                              for: .valueChanged)
        // 🔍 Test if sound is found
        let testURL = Bundle.main.url(forResource: "Sitar_Flute_Tabla", withExtension: "mp3")
        print("Sound URL:", testURL as Any)

        // 🔊 Audio session (important)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error")
        }
    }

    // MARK: - Segmented Control
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filteredSounds = allSounds
        case 1:
            filteredSounds = allSounds.filter { $0.category == .nature }
        case 2:
            filteredSounds = allSounds.filter { $0.category == .weather }
        case 3:
            filteredSounds = allSounds.filter { $0.category == .ambient }
        default:
            break
        }

        tableView.reloadData()
    }

    // MARK: - TableView Data Source
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return filteredSounds.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SoundCell",
            for: indexPath
        )

        let sound = filteredSounds[indexPath.row]

        cell.textLabel?.text = sound.title
        cell.detailTextLabel?.text = sound.category.rawValue

        let durationLabel = UILabel()
        durationLabel.text = formatDuration(TimeInterval(sound.duration))
        durationLabel.font = .systemFont(ofSize: 14)
        durationLabel.textColor = .gray
        durationLabel.sizeToFit()
        cell.accessoryView = durationLabel

        return cell
    }

    // MARK: - Play sound on tap
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {

        let sound = filteredSounds[indexPath.row]

        AudioManager.shared.play(sound: sound)

        guard let vc = storyboard?.instantiateViewController(
            withIdentifier: "NowPlayingVC"
        ) as? NowPlayingViewController else { return }

        present(vc, animated: true)
    }



    // MARK: - Helpers
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func playSound(named fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("❌ Sound not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
            print("▶️ Playing:", fileName)
        } catch {
            print("❌ Audio error:", error)
        }
    }
}
