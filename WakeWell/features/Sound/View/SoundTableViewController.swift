import UIKit
import AVFoundation

class SoundTableViewController: UITableViewController {

    @IBOutlet weak var segmentView: UISegmentedControl!

    @IBOutlet weak var outerviewSound: UIView!
    
    
    private var allSoundsData: [Sound] = allSounds
    private var filteredSounds: [Sound] = []

    private var currentlyPlayingFileName: String?
    private var durationCache: [String: TimeInterval] = [:]

    // Mini Player
    private let miniPlayer = MiniPlayerView()
    private var miniPlayerTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        filteredSounds = allSoundsData

        segmentView?.addTarget(self,
                              action: #selector(segmentChanged(_:)),
                              for: .valueChanged)
 
//        outerviewSound.backgroundColor = WakeWellTheme.background
        setupAudioSession()
        setupBackgroundGradient()
        setupMiniPlayer()

        miniPlayerTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateMiniPlayer()
        }

        //  MORE SPACE for bigger mini player
        tableView.contentInset.bottom = 110
        tableView.verticalScrollIndicatorInsets.bottom = 110
        tableView.horizontalScrollIndicatorInsets.left = tableView.adjustedContentInset.left

        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(closeTapped)
        )

    }
    private func applyTheme() {
        

        segmentView?.selectedSegmentTintColor = WakeWellTheme.accentPurple
        segmentView?.backgroundColor          = WakeWellTheme.purpleTint
        segmentView?.setTitleTextAttributes(
            [.foregroundColor: UIColor.white,
             .font: UIFont.systemFont(ofSize: 13, weight: .semibold)], for: .selected)
        segmentView?.setTitleTextAttributes(
            [.foregroundColor: WakeWellTheme.shadowColor], for: .normal)
    }

   // Segment Control
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filteredSounds = allSoundsData
        case 1:
            filteredSounds = allSoundsData.filter { $0.category == .nature }
        case 2:
            filteredSounds = allSoundsData.filter { $0.category == .weather }
        case 3:
            filteredSounds = allSoundsData.filter { $0.category == .ambient }
        default:
            break
        }
        tableView.reloadData()
    }

   // TableView Data Source
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
        let duration: TimeInterval

        if let cached = durationCache[sound.fileName] {
            duration = cached
        } else {
            duration = loadAudioDuration(for: sound)
            durationCache[sound.fileName] = duration
        }

        durationLabel.text = formatDuration(Int(duration))
        durationLabel.font = .systemFont(ofSize: 14)
        durationLabel.textColor = WakeWellTheme.labelSecondary
        durationLabel.sizeToFit()
        cell.accessoryView = durationLabel

        if sound.fileName == currentlyPlayingFileName {
            cell.backgroundColor = WakeWellTheme.purpleTint
            cell.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            durationLabel.textColor = WakeWellTheme.accentPurple
        } else {
            cell.backgroundColor = .clear
            cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            durationLabel.textColor = WakeWellTheme.labelSecondary
        }

        return cell
    }

    // TableView Delegate
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        AudioManager.shared.setPlaylist(filteredSounds, startIndex: indexPath.row)

        tableView.reloadData()
        updateMiniPlayer()

        guard let nowPlayingNav = storyboard?.instantiateViewController(withIdentifier: "NowPlayingNav") else { return }
        nowPlayingNav.modalPresentationStyle = .fullScreen
        present(nowPlayingNav, animated: true)
    }

  // Mini Player
    private func setupMiniPlayer() {
        miniPlayer.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(miniPlayer)

        //  FORCE FULL WIDTH (this is the missing piece)
        NSLayoutConstraint.activate([
            miniPlayer.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            miniPlayer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),

            miniPlayer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),

            miniPlayer.heightAnchor.constraint(equalToConstant: 72)
        ])

        

        miniPlayer.isHidden = true

        miniPlayer.playPauseButton.addTarget(self, action: #selector(miniPlayPauseTapped), for: .touchUpInside)
        miniPlayer.nextButton.addTarget(self, action: #selector(miniNextTapped), for: .touchUpInside)
        miniPlayer.previousButton.addTarget(self, action: #selector(miniPreviousTapped), for: .touchUpInside)
        miniPlayer.containerButton.addTarget(self, action: #selector(openNowPlaying), for: .touchUpInside)
    }

    private func updateMiniPlayer() {
        guard let sound = AudioManager.shared.currentSound else {
            miniPlayer.isHidden = true
            return
        }

        miniPlayer.isHidden = false

        //  SYNC TABLE STATE
        if currentlyPlayingFileName != sound.fileName {
            currentlyPlayingFileName = sound.fileName

            // Update visible rows only
            if let visibleRows = tableView.indexPathsForVisibleRows {
                tableView.reloadRows(at: visibleRows, with: .none)
            }
        }
        let image = UIImage(named: sound.imageName)

        miniPlayer.updateUI(
            title: sound.title,
            image: image,
            isPlaying: AudioManager.shared.isPlaying
        )
    }

    @objc private func miniPlayPauseTapped() {
        AudioManager.shared.togglePlayPause()
        updateMiniPlayer()
    }

    @objc private func miniNextTapped() {
        AudioManager.shared.playNext()
        updateMiniPlayer()
    }

    @objc private func miniPreviousTapped() {
        AudioManager.shared.playPrevious()
        updateMiniPlayer()
    }

    @objc private func openNowPlaying() {
        guard let nowPlayingNav = storyboard?.instantiateViewController(withIdentifier: "NowPlayingNav") else { return }
        nowPlayingNav.modalPresentationStyle = .fullScreen
        present(nowPlayingNav, animated: true)
    }

    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    // Audio Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance()
                .setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error:", error)
        }
    }

    private func loadAudioDuration(for sound: Sound) -> TimeInterval {
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: "mp3") else {
            return TimeInterval(sound.duration)
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            return player.duration
        } catch {
            return TimeInterval(sound.duration)
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%d:%02d", minutes, remainder)
    }

    private func setupBackgroundGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            WakeWellTheme.background.cgColor,
            WakeWellTheme.cardElevated.cgColor
        ]
        gradient.frame = view.bounds

        let backgroundView = UIView(frame: view.bounds)
        backgroundView.layer.insertSublayer(gradient, at: 0)

        tableView.backgroundView = backgroundView
    }
}


