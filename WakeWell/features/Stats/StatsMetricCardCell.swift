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
        leftTitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        leftTitleLabel.textColor = .systemGray

        leftValueLabel.font = .systemFont(ofSize: 26, weight: .semibold)
        leftValueLabel.textColor = .label

        rightTitleView.font = .systemFont(ofSize: 14, weight: .medium)
        rightTitleView.textColor = .systemGray

        rightValueView.font = .systemFont(ofSize: 26, weight: .semibold)
        rightValueView.textColor = .label
        
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

        
        setupCardStyle(leftCardView)
        setupCardStyle(rightCardView)

        // Left Tap
        let leftTap = UITapGestureRecognizer(target: self, action: #selector(leftCardTapped))
        leftCardView.addGestureRecognizer(leftTap)

        // Right Tap
        let rightTap = UITapGestureRecognizer(target: self, action: #selector(rightCardTapped))
        rightCardView.addGestureRecognizer(rightTap)
    }
    private func setupCardStyle(_ card: UIView) {

        card.layer.cornerRadius = 18
        card.backgroundColor = UIColor.systemBackground

        // subtle border
        card.layer.borderWidth = 0.5
        card.layer.borderColor = UIColor.systemGray4.cgColor

        // soft shadow
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.layer.shadowRadius = 6

        card.layer.masksToBounds = false
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
        animateTap(leftCardView)
        leftTapAction?()
    }

    @objc private func rightCardTapped() {
        animateTap(rightCardView)
        rightTapAction?()
    }
    private func animateTap(_ view: UIView) {

        UIView.animate(withDuration: 0.1, animations: {
            view.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                view.transform = .identity
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
