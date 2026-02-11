//
//  ActivitiesCollectionViewCell.swift
//  riseRitual
//
//  Created by geu on 31/01/26.
//

import UIKit

class ActivitiesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 20
        self.contentView.layer.cornerCurve = .continuous
        self.contentView.clipsToBounds = true
    }
    func configure(ritual: Ritual)
    {
        self.imageView.image = UIImage(named: ritual.imagePath)
        imageName.text = ritual.name
        imageName.layer.cornerRadius = 20
    }
}
