//
//  RitualDetailViewController.swift
//  riseRitual
//
//  Created by geu on 07/02/26.
//

import UIKit

class RitualDetailViewController: UIViewController {
    
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descImage: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var scienceLabel: UILabel!
    
    var ritual: Ritual?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        prepareAnimation()
    }
    
    func setupUI() {
        guard let ritual = ritual else { return }
        
        backgroundImage.image = UIImage(named: ritual.imagePath)
        titleLabel.text = ritual.name
        descImage.image = UIImage(named: ritual.imagePath)
        descImage.layer.cornerRadius = 16
        descLabel.setLineSpacing(lineSpacing: 4, text: ritual.description)
        scienceLabel.text = "SCIENCE: \(ritual.scienceReference)"
        scienceLabel.setLineSpacing(lineSpacing: 4, text: ritual.scienceReference)
        scienceLabel.alpha = 0.7
        
        startButton.layer.cornerRadius = startButton.frame.height / 2
        startButton.layer.shadowColor = UIColor.black.cgColor
        startButton.layer.shadowOpacity = 0.1
        startButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMe))
        view.addGestureRecognizer(tap)
    }
    
    //animation
    func prepareAnimation() {
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        titleLabel.alpha = 0
        descLabel.alpha = 0
        scienceLabel.alpha = 0
        startButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.titleLabel.transform = .identity
            self.titleLabel.alpha = 1
            self.descLabel.alpha = 1
            self.scienceLabel.alpha = 0.7
            self.startButton.transform = .identity
        })
    }
    
    @objc func dismissMe() {
        dismiss(animated: true)
    }
}
extension UILabel {
    func setLineSpacing(lineSpacing: CGFloat, text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = self.textAlignment
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }
}

// When in swift , animations like flipping the card to show the science referenc will be show
