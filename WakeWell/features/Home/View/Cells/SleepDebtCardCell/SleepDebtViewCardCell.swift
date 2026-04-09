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
    
    var onDismissRequested: ((SleepDebtViewCardCell) -> Void)?
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    }()
    
    private var isDismissing = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
        applyStyling()
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        contentView.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isDismissing = false
        transform = .identity
        alpha = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyShadowPath()
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        
        let velocity = panGesture.velocity(in: self)
        return abs(velocity.x) > abs(velocity.y)
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
        transform = .identity
        alpha = 1
    }
    
    @objc private func closeTapped() {
        guard !isDismissing else { return }
        isDismissing = true
        
        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            usingSpringWithDamping: 0.95,
            initialSpringVelocity: 0.2,
            options: [.curveEaseInOut, .allowUserInteraction]
        ) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
                .translatedBy(x: 0, y: -8)
            self?.alpha = 0
        } completion: { [weak self] _ in
            guard let self else { return }
            self.onDismissRequested?(self)
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard !isDismissing else { return }
        
        let translation = gesture.translation(in: self)
        let progress = min(abs(translation.x) / max(bounds.width, 1), 1)
        
        switch gesture.state {
        case .changed:
            let compression = 1 - (progress * 0.04)
            transform = CGAffineTransform(translationX: translation.x, y: 0)
                .scaledBy(x: 1, y: compression)
            alpha = 1 - (progress * 0.25)
            
        case .ended, .cancelled:
            let velocityX = gesture.velocity(in: self).x
            let shouldDismiss = abs(translation.x) > bounds.width * 0.35 || abs(velocityX) > 900
            
            if shouldDismiss {
                animateSwipeDismiss(velocityX: velocityX, translationX: translation.x)
            } else {
                UIView.animate(
                    withDuration: 0.45,
                    delay: 0,
                    usingSpringWithDamping: 0.78,
                    initialSpringVelocity: 0.4,
                    options: [.curveEaseOut, .allowUserInteraction]
                ) { [weak self] in
                    self?.transform = .identity
                    self?.alpha = 1
                }
            }
            
        default:
            break
        }
    }
    
    private func animateSwipeDismiss(velocityX: CGFloat, translationX: CGFloat) {
        guard !isDismissing else { return }
        isDismissing = true
        
        let direction: CGFloat
        if translationX == 0 {
            direction = velocityX >= 0 ? 1 : -1
        } else {
            direction = translationX >= 0 ? 1 : -1
        }
        
        let targetX = direction * (bounds.width + 48)
        
        UIView.animate(
            withDuration: 0.24,
            delay: 0,
            options: [.curveEaseOut, .allowUserInteraction]
        ) { [weak self] in
            self?.transform = CGAffineTransform(translationX: targetX, y: 0)
                .scaledBy(x: 0.98, y: 0.96)
            self?.alpha = 0
        } completion: { [weak self] _ in
            guard let self else { return }
            self.onDismissRequested?(self)
        }
    }
}
