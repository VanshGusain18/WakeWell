//
//  SleepSoundsCollectionViewCell.swift
//  WakeWell
//
//  Created by geu on 12/03/26.
//

import UIKit

class SleepSoundsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        applyStyling()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyShadowPath()
    }

    private func setupUI() {

        contentView.layer.cornerRadius = 24
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .secondarySystemBackground

        layer.masksToBounds = false
    }

    private func applyStyling() {

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 6)
    }

    private func applyShadowPath() {

        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 24
        ).cgPath
    }
    
    func configure(with viewModel: SleepSoundsViewModel) {
        titleLabel.text = viewModel.title
    }
}
