//
//  RoutineCell.swift
//  WakeWell
//
//  Created by geu on 30/03/26.
//

import UIKit

class RoutineCell: UICollectionViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func configure(with routine: Routine) {
        titleLabel.text = routine.title
        subtitleLabel.text = routine.subtitle
        imageView.image = UIImage(named: routine.imageName)
        
        cardView.alpha = routine.isSelected ? 1.0 : 0.7
    }
}
