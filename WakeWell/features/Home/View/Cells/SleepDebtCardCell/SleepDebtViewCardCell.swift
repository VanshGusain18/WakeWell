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
        addSwipeGesture()  
    }
    
    private func addSwipeGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        contentView.addGestureRecognizer(pan)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        
        switch gesture.state {
        case .changed:
            // Only allow horizontal drag, resist leftward drag slightly
            let clampedX = translation.x > 0 ? translation.x : translation.x * 0.3
            contentView.transform = CGAffineTransform(translationX: clampedX, y: 0)
            // Fade out as it slides
            let progress = min(abs(clampedX) / (bounds.width * 0.5), 1.0)
            contentView.alpha = 1.0 - progress * 0.6
            
        case .ended, .cancelled:
            let movedEnough = abs(translation.x) > bounds.width * 0.4
            let fastEnough = abs(velocity.x) > 800
            
            if movedEnough || fastEnough {
                dismissWithAnimation()
            } else {
                // Snap back
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.7,
                               initialSpringVelocity: 0.5) {
                    self.contentView.transform = .identity
                    self.contentView.alpha = 1.0
                }
            }
        default:
            break
        }
    }
    
    private func dismissWithAnimation() {
        let direction: CGFloat = contentView.transform.tx >= 0 ? 1 : -1
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseOut
        ) {
            self.contentView.transform = CGAffineTransform(
                translationX: direction * self.bounds.width * 1.5,
                y: 0
            )
            self.contentView.alpha = 0
        } completion: { _ in
            self.onClose?()
        }
    }
    
    // MODIFY closeTapped to also animate
    @objc private func closeTapped() {
        dismissWithAnimation()
    }
    
    // ... rest of your existing methods unchanged
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
}
