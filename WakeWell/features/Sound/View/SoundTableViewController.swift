//
//  SoundTableViewController.swift
//  sounds_tab
//

import UIKit
import AVFoundation

class SoundTableViewController: UITableViewController {

    @IBOutlet weak var segmentView: UISegmentedControl!

    // Data source
    private var allSoundsData: [Sound] = allSounds
    private var filteredSounds: [Sound] = []

    // Track currently playing sound
    private var currentlyPlayingFileName: String?

    // Cache for audio durations
    private var durationCache: [String: TimeInterval] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        filteredSounds = allSoundsData

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

        // Duration label (right side)
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
        durationLabel.textColor = .secondaryLabel
        durationLabel.sizeToFit()
        cell.accessoryView = durationLabel

        // Highlight currently playing sound
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

    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        let sound = filteredSounds[indexPath.row]

        // Track currently playing sound
        currentlyPlayingFileName = sound.fileName

        // Play sound via AudioManager
        AudioManager.shared.setPlaylist(
            filteredSounds,
            startIndex: indexPath.row
        )

        // Refresh UI highlight
        tableView.reloadData()

        // Open Now Playing screen
        guard let nowPlayingNav = storyboard?.instantiateViewController(withIdentifier: "NowPlayingNav") else { return }
        nowPlayingNav.modalPresentationStyle = .fullScreen
        present(nowPlayingNav, animated: true)
    }

    // MARK: - Audio Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance()
                .setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error:", error)
        }
    }

    // MARK: - Helpers

    /// Load actual MP3 duration
    private func loadAudioDuration(for sound: Sound) -> TimeInterval {
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: "mp3") else {
            print(" Sound file not found:", sound.fileName)
            return TimeInterval(sound.duration) // fallback
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            return player.duration
        } catch {
            print(" Failed to load duration:", error)
            return TimeInterval(sound.duration) // fallback
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
            UIColor.systemBackground.cgColor,
            UIColor.systemGray6.cgColor
        ]
        gradient.frame = view.bounds

        let backgroundView = UIView(frame: view.bounds)
        backgroundView.layer.insertSublayer(gradient, at: 0)

        tableView.backgroundView = backgroundView
    }
}
