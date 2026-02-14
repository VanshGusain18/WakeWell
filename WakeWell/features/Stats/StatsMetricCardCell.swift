//
//  StatsMetricCardCell.swift
//  WakeWell
//
//  Created by geu on 12/02/26.
//

import UIKit

class StatsMetricCardCell: UITableViewCell {
    @IBOutlet weak var leftCardView: UIView!
    @IBOutlet weak var leftTitleLabel: UILabel!
    @IBOutlet weak var leftValueLabel: UILabel!
    @IBOutlet weak var rightCardView: UIView!
    @IBOutlet weak var rightTitleView: UILabel!
    @IBOutlet weak var rightValueView: UILabel!
    
    var leftTapAction: (() -> Void)?
    var rightTapAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        // Left Card Styling
        leftCardView.layer.cornerRadius = 16
        leftCardView.layer.borderWidth = 1
        leftCardView.layer.borderColor = UIColor.black.cgColor
        leftCardView.isUserInteractionEnabled = true

        // Right Card Styling
        rightCardView.layer.cornerRadius = 16
        rightCardView.layer.borderWidth = 1
        rightCardView.layer.borderColor = UIColor.black.cgColor
        rightCardView.isUserInteractionEnabled = true

        // Left Tap
        let leftTap = UITapGestureRecognizer(target: self, action: #selector(leftCardTapped))
        leftCardView.addGestureRecognizer(leftTap)

        // Right Tap
        let rightTap = UITapGestureRecognizer(target: self, action: #selector(rightCardTapped))
        rightCardView.addGestureRecognizer(rightTap)
    }

    func configure(
        leftTitle: String,
        leftValue: String,
        rightTitle: String?,
        rightValue: String?,
        leftAction: (() -> Void)? = nil,
        rightAction: (() -> Void)? = nil
    ) {
        leftTitleLabel.text = leftTitle
        leftValueLabel.text = leftValue
        
        rightTitleView.text = rightTitle
        rightValueView.text = rightValue
        
        self.leftTapAction = leftAction
        self.rightTapAction = rightAction
    }

    @objc private func leftCardTapped() {
        leftTapAction?()
    }

    @objc private func rightCardTapped() {
        rightTapAction?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
