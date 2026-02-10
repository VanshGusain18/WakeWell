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
        private let backgroundImageView = UIImageView()
        private let blurView = UIVisualEffectView(
            effect: UIBlurEffect(style: .systemThinMaterialLight)
        )

        override func viewDidLoad() {
            super.viewDidLoad()

            guard let sound = AudioManager.shared.currentSound,
                  let image = UIImage(named: sound.imageName) else {
                print("❌ Missing sound or image")
                return
            }

            titleLabel.text = sound.title

            setupBackground(image: image)
            setupMainImage(image)
            setupPlayPauseButton()
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

        @IBAction func closeTapped(_ sender: UIButton) {
            dismiss(animated: true)
        }
    }
