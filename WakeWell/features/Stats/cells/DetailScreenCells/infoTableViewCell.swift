//
//  infoTableViewCell.swift
//  WakeWell
//
//  Created by geu on 23/03/26.
//

import UIKit

class infoTableViewCell: UITableViewCell {

    @IBOutlet weak var glassContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupStyle()
    }
    private func setupStyle() {
            // Glass effect
            glassContainer.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            glassContainer.layer.cornerRadius = 20
            glassContainer.layer.borderWidth = 1.0
            glassContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
            
            // Shadow
            glassContainer.layer.shadowColor = UIColor.black.cgColor
            glassContainer.layer.shadowOpacity = 0.05
            glassContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
            glassContainer.layer.shadowRadius = 10
            
            selectionStyle = .none
            backgroundColor = .clear
            
            // Title
            titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            titleLabel.textColor = .label
            
            // Description
            descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
            descriptionLabel.textColor = .secondaryLabel
            descriptionLabel.numberOfLines = 0
        }

        // MARK: - Configure
        func configure(title: String, description: String) {
            titleLabel.text = title
            descriptionLabel.text = description
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            titleLabel.text = nil
            descriptionLabel.text = nil
        }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
