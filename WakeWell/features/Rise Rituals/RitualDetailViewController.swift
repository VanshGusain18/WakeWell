//
//  RitualDetailViewController.swift
//  riseRitual
//
//  Created by geu on 07/02/26.
//

import UIKit

class RitualDetailViewController: UIViewController {

    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var descLabel: UILabel!
    
    var ritual: Ritual?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
            guard let ritual = ritual else { return }
            
            backgroundImage.image = UIImage(named: ritual.imagePath) // or ritual.image
            descLabel.text = ritual.description
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMe))
            view.addGestureRecognizer(tap)
       // let blurEffectView.alpha = 0.7
        }

        @objc func dismissMe() {
            dismiss(animated: true)
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //popupView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        popupView.alpha = 0
        popupView.layer.cornerRadius = 20
        popupView.layer.masksToBounds = true
        
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: {
            self.popupView.transform = .identity
            self.popupView.alpha = 1
        }, completion: nil)
    }

}
