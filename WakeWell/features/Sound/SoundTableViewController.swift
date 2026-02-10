import UIKit
import AVFoundation
class SoundTableViewController: UITableViewController {

    @IBOutlet weak var segmentView: UISegmentedControl!
        var allSounds: [Sound] = [
            Sound(
                title: "Sitar Flute Tabla",
                category: .ambient,
                duration: 600,
                fileName: "Sitar_Flute_Tabla",
                imageName: "sea"
            ),
            Sound(
                title: "Railway Tracks",
                category: .ambient,
                duration: 600,
                fileName: "grand_project-railway-track-470218",
                imageName: "sea"
            ),
            Sound(
                title: "Forest",
                category: .nature,
                duration: 600,
                fileName: "mandakimdk-xylophone-and-forest-307174",
                imageName: "forest"
            )
        ]

        var filteredSounds: [Sound] = []
        var audioPlayer: AVAudioPlayer?

        // Tracks which sound is playing
        private var currentlyPlayingFileName: String?

        override func viewDidLoad() {
            super.viewDidLoad()

            filteredSounds = allSounds

            segmentView.addTarget(self,
                                  action: #selector(segmentChanged(_:)),
                                  for: .valueChanged)
            
            setupAudioSession()
            setupBackgroundGradient()
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

            // Duration label (replaces >)
            let durationLabel = UILabel()
            durationLabel.text = formatDuration(sound.duration)
            durationLabel.font = .systemFont(ofSize: 14)
            durationLabel.textColor = .secondaryLabel
            durationLabel.sizeToFit()
            cell.accessoryView = durationLabel

            // Highlight playing sound
            if sound.fileName == currentlyPlayingFileName {
                cell.backgroundColor = UIColor.systemGray6
                cell.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
                durationLabel.textColor = .systemBlue
            } else {
                cell.backgroundColor = .clear
                cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
                durationLabel.textColor = .secondaryLabel
            }

            return cell
        }
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let sound = filteredSounds[indexPath.row]

        // Track currently playing sound
        currentlyPlayingFileName = sound.fileName

        // Play sound (THIS triggers mini player)
        AudioManager.shared.play(sound: sound)

        // Refresh UI highlight
        tableView.reloadData()

        // Open Now Playing screen
        let vc = storyboard?.instantiateViewController(
            withIdentifier: "NowPlayingVC"
        ) as! NowPlayingViewController

        present(vc, animated: true)
    }

    // MARK: - Audio
        private func setupAudioSession() {
            do {
                try AVAudioSession.sharedInstance()
                    .setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Audio session error")
            }
        }

        private func playSound(named fileName: String) {
            guard let url = Bundle.main.url(forResource: fileName,
                                            withExtension: "mp3") else {
                print("❌ Sound not found:", fileName)
                return
            }

            do {
                audioPlayer?.stop()
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.play()
            } catch {
                print("❌ Audio error")
            }
        }

        // MARK: - Helpers
        private func formatDuration(_ seconds: Int) -> String {
            let minutes = seconds / 60
            let remainder = seconds % 60
            return String(format: "%d:%02d", minutes, remainder)
        }

        // MARK: - Background Gradient
        private func setupBackgroundGradient() {
            let gradient = CAGradientLayer()
            gradient.colors = [
                UIColor.systemBackground.cgColor,
                UIColor.systemGray6.cgColor
            ]
            gradient.frame = view.bounds

            let backgroundView = UIView(frame: view.bounds)
            backgroundView.layer.insertSublayer(gradient, at: 0)

            tableView.backgroundView = backgroundView
        }
    }
