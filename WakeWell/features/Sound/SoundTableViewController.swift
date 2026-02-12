import UIKit
import AVFoundation
class SoundTableViewController: UITableViewController {

    @IBOutlet weak var segmentView: UISegmentedControl!
        var allSounds: [Sound] = [
           //ambience
            Sound(
                title: "White Noise",
                category: .ambient,
                duration: 600,
                fileName: "light_music-white-noise-188847",
                imageName: "soundsrelaxing89-cozy-7023760"
                ),
            Sound(
                title: "Beats of Nature",
                category: .ambient,
                duration: 600,
                fileName: "folk_acoustic-the-beat-of-nature-122841",
                imageName: "beena777-ai-generated-9594995"
            ),
            Sound(
                title: "Piano Strings",
                category: .ambient,
                duration: 600,
                fileName: "good_b_music-ambient-piano-and-strings-10711",
                imageName: "ralf1403-piano-10046998 1"
            ),
            Sound(
                title: "Meditation Music",
                category: .ambient,
                duration: 600,
                fileName: "grand_project-breath-of-enlightenment-meditation-music-407178",
                imageName: "couleur-candles-9874140"
                ),
            Sound(
                title: "Railway Tracks",
                category: .ambient,
                duration: 600,
                fileName: "grand_project-railway-track-470218",
                imageName: "tama66-tunnel-4427609"
                ),
            Sound(
                title: "Cinematic ambient",
                category: .ambient,
                duration: 600,
                fileName: "lexin_music-inspiring-cinematic-ambient-116199",
                imageName: "foundry-shop-868071"
                ),
            Sound(
                title: "Coorporate World",
                category: .ambient,
                duration: 600,
                fileName: "sound4stock-soft-background-corporate-music-472861",
                imageName: "rus-burkhanov-building-4803602"
                ),
            Sound(
                title: "Vibing relaxing music",
                category: .ambient,
                duration: 600,
                fileName: "vibehorn-relax-lofi-beat-461489",
                imageName: "iffany-ai-generated-9380435"
                ),
            //Nature
            Sound(
                title: "Saving Nature",
                category: .nature,
                duration: 600,
                fileName: "emmraan-saving-nature-218413",
                imageName: "sonyuser-river-5765785"
                ),
            Sound(
                title: "Melody",
                category: .nature,
                duration: 600,
                fileName: "good_b_music-melody-of-nature-main-6672",
                imageName: "flower"
                ),
            Sound(
                    title: "Flowing Water",
                    category: .nature,
                    duration: 600,
                    fileName: "natureseye-the-old-water-mill-meditation-8005",
                    imageName: "pexels-sea-1850228"
                    ),
            Sound(
                title: "Xylophone beats",
                category: .nature,
                duration: 600,
                fileName: "mandakimdk-xylophone-and-forest-307174",
                imageName: "ralf1403-sheet-music-8463988 1"
                ),
            Sound(
                title: "Forest",
                category: .nature,
                duration: 600,
                fileName: "rikardfrizz-the-enchanted-forest-252441",
                imageName: "beena777-ai-generated-9594995"
                ),
            Sound(
                title: "Soundscape",
                category: .nature,
                duration: 600,
                fileName: "surprising_media-ambient-nature-soundscape-344565",
                imageName: "pinecone"
                ),
            Sound(
                title: "Spiritual Forest",
                category: .nature,
                duration: 600,
                fileName: "sonican-spiritual-nature-364866",
                imageName: "stills_by_suki-banff-8329971"
                ),
            Sound(
                    title: "Wind And Bells",
                    category: .nature,
                    duration: 600,
                    fileName: "meditativetiger-sleep-inducing-tibetan-bells-388638",
                    imageName: "chrisart16-bell-4401148"
                    ),
           
            //Weather
            Sound(
                title: "Rain",
                category: .weather,
                duration: 600,
                fileName: "desifreemusic-relaxing-sleep-music-with-soft-ambient-rain-369762",
                imageName: "hungvina1986-season-4559795"
                ),
            Sound(
                title: "Wind",
                category: .weather,
                duration: 600,
                fileName: "grand_project-zen-wind-411951",
                imageName: "manfredrichter-windmill-7963566"
                ),
            
        Sound(
            title: "Brighter Tomorrow",
            category: .weather,
            duration: 600,
            fileName: "49534488-a-brighter-tomorrow-333965",
            imageName: "heungsoon-cherry-blossom-7889717"
            ),
            Sound(
                title: "Partly cloudy skies",
                category: .weather,
                duration: 600,
                fileName: "49534488-partly-cloudy-skies-return-333957",
                imageName: "wpquadrosemolduras-rainbow-5039388"
                ),
            Sound(
                title: "Rain cocoon",
                category: .weather,
                duration: 600,
                fileName: "book_of_life-rain-cocoon-316178",
                imageName: "chamelete-caterpillar-2482317"
                ),
            Sound(
                title: "Weather Melody",
                category: .weather,
                duration: 600,
                fileName: "musicword-weather-melody-182846",
                imageName: "congvuphotographer-landscape-5104510"
                ),
            Sound(
                title: "Spring",
                category: .weather,
                duration: 600,
                fileName: "musicword-spring-weather-312701",
                imageName: "chiemseherin-meadow-5229169"
                ),
            Sound(
                title: "Autumn",
                category: .weather,
                duration: 600,
                fileName: "musicword-autumn-weather-236905",
                imageName: "heungsoon-maple-leaves-2789234"
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
