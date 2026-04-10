//
//  SleepDebtViewCardCell.swift
//  WakeWell
//
//  Created by geu on 01/04/26.
//


import UIKit

class SleepDebtViewCardCell: UICollectionViewCell {
    
    static let identifier = "SleepDebtViewCardCell"
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var onClose: (() -> Void)?
    
    override func awakeFromNib() {
            super.awakeFromNib()
            
            setupUI()
            applyStyling()
            
            closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            applyShadowPath()
        }

        private func setupUI() {

            contentView.layer.cornerRadius = 20
            contentView.layer.masksToBounds = true
            contentView.backgroundColor = .secondarySystemBackground
            
            layer.masksToBounds = false
            
            messageLabel.textColor = .label
            messageLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            messageLabel.numberOfLines = 0
            
            closeButton.tintColor = .secondaryLabel
        }

        private func applyStyling() {

            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.1
            layer.shadowRadius = 10
            layer.shadowOffset = CGSize(width: 0, height: 4)
        }

        private func applyShadowPath() {

            layer.shadowPath = UIBezierPath(
                roundedRect: bounds,
                cornerRadius: 20
            ).cgPath
        }

        func configure(with viewModel: SleepDebtViewModel) {
            messageLabel.text = viewModel.debtMessage()
        }
        
        @objc private func closeTapped() {
            onClose?()
        }
    }
