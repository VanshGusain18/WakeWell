//
//  RiseRitualCollectionViewCell.swift
//  WakeWell
//
//  Created by geu on 11/04/26.
//

import UIKit

class RiseRitualCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var viewTabButton: UIButton!
    
    static let identifier = "RiseRitualCollectionViewCell"
    
    var onClose: (() -> Void)?
    /// Injected by HomeViewController — navigates into the Rise Ritual runner.
    var onStartRitual: (() -> Void)?
    /// Injected by HomeViewController — switches the tab bar to the Rise tab.
    var onViewRiseTab: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCard()
        setupLabels()
        setupButtons()
        applyStyling()
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addSwipeGesture()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyShadowPath()
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
            let clampedX = translation.x > 0 ? translation.x : translation.x * 0.3
            contentView.transform = CGAffineTransform(translationX: clampedX, y: 0)
            let progress = min(abs(clampedX) / (bounds.width * 0.5), 1.0)
            contentView.alpha = 1.0 - progress * 0.6
            
        case .ended, .cancelled:
            let movedEnough = abs(translation.x) > bounds.width * 0.4
            let fastEnough = abs(velocity.x) > 800
            
            if movedEnough || fastEnough {
                dismissWithAnimation()
            } else {
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
    @objc private func closeTapped() {
        dismissWithAnimation()
    }
    private func setupCard() {
        contentView.layer.cornerRadius  = 24
        contentView.layer.masksToBounds = true
        contentView.backgroundColor     = .secondarySystemBackground
        layer.masksToBounds             = false
    }

    private func setupLabels() {
        titleLabel.font           = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor      = .label
        titleLabel.numberOfLines  = 1

        categoryLabel.font        = UIFont.systemFont(ofSize: 11, weight: .semibold)
        categoryLabel.textColor   = .secondaryLabel
        categoryLabel.numberOfLines = 1

        descriptionLabel.font         = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor    = .secondaryLabel
        descriptionLabel.numberOfLines = 0
    }

    private func setupButtons() {
        iconContainerView.backgroundColor  = UIColor.systemOrange.withAlphaComponent(0.12)
        iconContainerView.layer.cornerRadius = 12
        iconContainerView.clipsToBounds     = true

        iconImageView.tintColor   = .systemOrange
        iconImageView.contentMode = .scaleAspectFit

        startButton.setTitle("Start Ritual", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font    = UIFont.systemFont(ofSize: 15, weight: .semibold)
        startButton.layer.cornerRadius  = 20
        startButton.clipsToBounds       = true

        viewTabButton.setTitle("VIEW RISE TAB  ›", for: .normal)
        viewTabButton.setTitleColor(.secondaryLabel, for: .normal)
        viewTabButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        viewTabButton.backgroundColor  = .clear

        closeButton.tintColor = .secondaryLabel
    }

    private func applyStyling() {
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowRadius  = 12
        layer.shadowOffset  = CGSize(width: 0, height: 6)
    }

    private func applyShadowPath() {
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 24
        ).cgPath
    }

    func configure(with viewModel: RiseRitualViewModel) {
        titleLabel.text       = viewModel.title
        categoryLabel.text    = viewModel.category
        descriptionLabel.text = viewModel.description
        startButton.setTitle(viewModel.startButtonTitle, for: .normal)
        viewTabButton.setTitle(viewModel.viewTabTitle, for: .normal)
    }


    @IBAction func startButtonfunction(_ sender: Any) {
        onStartRitual?()
    }
    @IBAction func viewRiseTabbutton(_ sender: Any) {
        onViewRiseTab?()
    }
}
