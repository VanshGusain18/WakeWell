//
//  HeaderTableViewCell.swift
//  WakeWell
//
//  Created by geu on 23/03/26.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var glassContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }
    private func setupStyle() {
            glassContainer.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            glassContainer.layer.cornerRadius = 24
            glassContainer.layer.masksToBounds = false
            
            glassContainer.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = 0.05
            glassContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
            glassContainer.layer.shadowRadius = 12
            
            glassContainer.layer.borderWidth = 1.0
            glassContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
            
            selectionStyle = .none
            backgroundColor = .clear
            
            titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
            titleLabel.textColor = .label
            
            descriptionLabel.font = .systemFont(ofSize: 15, weight: .regular)
            descriptionLabel.textColor = .secondaryLabel
            descriptionLabel.numberOfLines = 0
        }
    func configure(title: String, description: String) {
            titleLabel.text = title
            descriptionLabel.text = description
        }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
