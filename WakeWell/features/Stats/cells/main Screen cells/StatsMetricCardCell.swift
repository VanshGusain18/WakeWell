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
        setupUI()
        setupGestures()
    }
    
    private func setupUI() {
        configureLabelStyle(leftTitleLabel, size: 14, weight: .medium, color: .systemGray)
        configureLabelStyle(rightTitleView, size: 14, weight: .medium, color: .systemGray)
        
        configureLabelStyle(leftValueLabel, size: 26, weight: .semibold, color: .label)
        configureLabelStyle(rightValueView, size: 26, weight: .semibold, color: .label)
        
        applyLiquidGlassEffect(to: leftCardView)
        applyLiquidGlassEffect(to: rightCardView)
    }
    
    private func configureLabelStyle(_ label: UILabel, size: CGFloat, weight: UIFont.Weight, color: UIColor) {
        label.font = .systemFont(ofSize: size, weight: weight)
        label.textColor = color
    }
    
    private func applyLiquidGlassEffect(to card: UIView) {
        card.backgroundColor = .systemBackground.withAlphaComponent(0.8)
        card.layer.cornerRadius = 20
        card.isUserInteractionEnabled = true
        
        card.layer.borderWidth = 0.5
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowOffset = CGSize(width: 0, height: 8)
        card.layer.shadowRadius = 12
        card.layer.masksToBounds = false
    }
    
    private func setupGestures() {
        let leftTap = UITapGestureRecognizer(target: self, action: #selector(leftCardTapped))
        leftCardView.addGestureRecognizer(leftTap)
        
        let rightTap = UITapGestureRecognizer(target: self, action: #selector(rightCardTapped))
        rightCardView.addGestureRecognizer(rightTap)
    }
    
    func configure(leftTitle: String,leftValue: String,rightTitle: String?,rightValue: String?,leftAction: (() -> Void)? = nil,rightAction: (() -> Void)? = nil) {
        leftTitleLabel.text = leftTitle
        leftValueLabel.text = leftValue
        
        rightTitleView.text = rightTitle
        rightValueView.text = rightValue
        
        self.leftTapAction = leftAction
        self.rightTapAction = rightAction
        
        rightCardView.alpha = (rightTitle == nil) ? 0 : 1
    }
    
    @objc private func leftCardTapped() {
        provideHapticFeedback()
        animateInteraction(leftCardView)
        leftTapAction?()
    }
    
    @objc private func rightCardTapped() {
        provideHapticFeedback()
        animateInteraction(rightCardView)
        rightTapAction?()
    }
    
    private func animateInteraction(_ view: UIView) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
            view.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            view.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseIn]) {
                view.transform = .identity
                view.alpha = 1.0
            }
        }
    }
    
    private func provideHapticFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

    
