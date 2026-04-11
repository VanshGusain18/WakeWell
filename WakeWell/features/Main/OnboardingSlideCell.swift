//
//  OnboardingSlideCell.swift
//  WakeWell
//
//  Created by geu on 11/04/26.
//

// OnboardingSlideCell.swift
import UIKit

class OnboardingSlideCell: UICollectionViewCell {

    static let identifier = "OnboardingSlideCell"

    // ── IBOutlets (connect these from XIB) ──
    @IBOutlet weak var iconContainer: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        iconContainer.layer.cornerRadius = 60
        iconContainer.clipsToBounds = true
    }

    func configure(with slide: OnboardingSlide) {
        iconImageView.image = UIImage(systemName: slide.icon)
        iconImageView.tintColor = slide.accentColor
        titleLabel.text = slide.title
        subtitleLabel.text = slide.subtitle
    }
}
