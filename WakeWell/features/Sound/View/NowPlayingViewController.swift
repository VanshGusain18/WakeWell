//
//  NowPlayingViewController.swift
//  sounds_tab
//
//  Created by geu on 06/02/26.
//

import UIKit

class NowPlayingViewController: UIViewController {
    var sound: Sound!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var playPauseButton: UIButton!
   
    
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    
    @IBOutlet var progressLabel: UISlider!
    
    @IBOutlet var currentTimeLabel: UILabel!
    
    @IBOutlet var reaminingTimeLabel: UILabel!
    private var timer: Timer?

    
    private let backgroundImageView = UIImageView()
        private let blurView = UIVisualEffectView(
            effect: UIBlurEffect(style: .systemThinMaterialLight)
        )

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(_:)))
        progressLabel.addGestureRecognizer(tapGesture)
        navigationController?.setNavigationBarHidden(false, animated: false)

        guard let sound = AudioManager.shared.currentSound,
              let image = UIImage(named: sound.imageName) else {
            print("Missing sound or image")
            return
        }

        titleLabel.text = sound.title
        setupBackground(image: image)
        setupMainImage(image)
        setupPlayPauseButton()
        startTimer()
        progressLabel.minimumTrackTintColor = WakeWellTheme.accentPurple
        progressLabel.maximumTrackTintColor = WakeWellTheme.border
        progressLabel.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        

    
        navigationItem.largeTitleDisplayMode = .never
    }


        private func setupBackground(image: UIImage) {
            backgroundImageView.frame = view.bounds
            backgroundImageView.image = image
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.alpha = 0.35

            blurView.frame = view.bounds

            view.insertSubview(backgroundImageView, at: 0)
            view.insertSubview(blurView, aboveSubview: backgroundImageView)
        }

        private func setupMainImage(_ image: UIImage) {
            imageView.image = image
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 26
            imageView.clipsToBounds = true
        }

        private func setupPlayPauseButton() {
            playPauseButton.layer.cornerRadius = 32
            updatePlayPauseButton()
        }

        private func updatePlayPauseButton() {
            let icon = AudioManager.shared.isPlaying ? "pause.fill" : "play.fill"
            playPauseButton.setImage(UIImage(systemName: icon), for: .normal)
        }

        @IBAction func playPauseTapped(_ sender: UIButton) {
            AudioManager.shared.togglePlayPause()
            updatePlayPauseButton()
        }

    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func previousTapped(_ sender: UIButton) {
        AudioManager.shared.playPrevious()
            refreshUI()
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        AudioManager.shared.playNext()
           refreshUI()
    }
    private func refreshUI() {
        guard let sound = AudioManager.shared.currentSound,
              let image = UIImage(named: sound.imageName) else { return }

        titleLabel.text = sound.title
        imageView.image = image
        updatePlayPauseButton()
    }
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }

    private func updateProgress() {
        let current = AudioManager.shared.currentTime
        let duration = AudioManager.shared.duration
        
        guard duration > 0 else { return }
        
        progressLabel.value = Float(current / duration)
        
        currentTimeLabel.text = formatTime(current)
        reaminingTimeLabel.text = "-\(formatTime(duration - current))"
    }
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        let duration = AudioManager.shared.duration
            let newTime = Double(sender.value) * duration
            AudioManager.shared.seek(to: newTime)
    }
    @objc func sliderTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: progressLabel)
        let percentage = location.x / progressLabel.bounds.width

        let duration = AudioManager.shared.duration
        let newTime = Double(percentage) * duration

        progressLabel.setValue(Float(percentage), animated: true)
        AudioManager.shared.seek(to: newTime)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }

    deinit {
        timer?.invalidate()
    }
}
