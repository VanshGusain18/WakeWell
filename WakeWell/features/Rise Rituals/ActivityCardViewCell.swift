//
//  ActivityCardViewCell.swift
//  WakeWell
//
//  Created by geu on 18/03/26.
//

import UIKit

class ActivityCardViewCell: UICollectionViewCell {
    
    let titleLabel = UILabel()
    let imageView = UIImageView()
    let categoryLabel = UILabel()
    let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupUI()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            gradientLayer.frame = contentView.bounds
        }
        
        func setupUI() {
            contentView.layer.cornerRadius = 20
            contentView.backgroundColor = .secondarySystemBackground
            contentView.clipsToBounds = true
            
            imageView.contentMode = .scaleAspectFill
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            // Setup Gradient for readability
            gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.7).cgColor]
            gradientLayer.locations = [0.6, 1.0]
            
            titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
            titleLabel.textColor = .white
            titleLabel.numberOfLines = 2
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            categoryLabel.font = UIFont.systemFont(ofSize: 14)
            categoryLabel.textColor = UIColor.white.withAlphaComponent(0.8)
            categoryLabel.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(imageView)
            contentView.layer.addSublayer(gradientLayer)
            contentView.addSubview(titleLabel)
            contentView.addSubview(categoryLabel)
            
            NSLayoutConstraint.activate([
                // Image covers entire card
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                
                // Labels at bottom left
                categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                categoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
                
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                titleLabel.bottomAnchor.constraint(equalTo: categoryLabel.topAnchor, constant: -4)
            ])
        }
        
    func configure(with activity: Activity, isExplore: Bool) {
        titleLabel.text = activity.title
        imageView.image = UIImage(named: activity.imageName)
        
        if isExplore {
            // Smaller font for the Grid
            titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
            categoryLabel.text = ""
            categoryLabel.isHidden = true
            
            // Optional: Reduce padding for smaller cards
            titleLabel.numberOfLines = 1
        } else {
            // Larger font for the Morning Routine Hero cards
            titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
            categoryLabel.text = activity.category
            categoryLabel.isHidden = false
            titleLabel.numberOfLines = 2
        }
    }
}
