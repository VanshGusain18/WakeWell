//
//  AlarmCollectionViewCell.swift
//  WakeWell
//
//  Created by geu on 13/02/26.
//

import UIKit

class AlarmCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
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
        contentView.layer.cornerRadius = 20
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
            cornerRadius: 20
        ).cgPath
    }
    
    func configure(with viewModel: AlarmViewModel) {
        titleLabel.text = viewModel.title
        timeLabel.text = viewModel.timeText
        subtitleLabel.text = viewModel.subtitleText
    }
}
