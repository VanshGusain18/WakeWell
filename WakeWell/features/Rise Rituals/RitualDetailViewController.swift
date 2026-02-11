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
    
    var ritual: Ritual?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        guard let ritual = ritual else { return }
            
        backgroundImage.image = UIImage(named: ritual.imagePath)
        titleLabel.text = ritual.name
        descImage.image = UIImage(named: ritual.imagePath)
        descImage.layer.cornerRadius = 20
        descLabel.text = ritual.description
            
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMe))
            view.addGestureRecognizer(tap)
    }

        @objc func dismissMe() {
            dismiss(animated: true)
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: {
        }, completion: nil)
    }

}
