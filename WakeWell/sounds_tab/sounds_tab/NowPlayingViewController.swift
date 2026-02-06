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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let sound = AudioManager.shared.currentSound else { return }
        
        titleLabel.text = sound.title
        imageView.image = UIImage(named: sound.imageName)
        
        let isPlaying = AudioManager.shared.isPlaying
        playPauseButton.setTitle(isPlaying ? "Pause" : "Play", for: .normal)
    }
    
    
    
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        AudioManager.shared.togglePlayPause()
        let isPlaying = AudioManager.shared.isPlaying
        sender.setTitle(isPlaying ? "Pause" : "Play", for: .normal)
    }
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
