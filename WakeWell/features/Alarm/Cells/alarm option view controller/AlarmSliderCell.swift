//
//  AlarmSliderCell.swift
//  WakeWell

import UIKit

final class AlarmSliderCell: UITableViewCell {

    static let reuseID = "AlarmSliderCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slider:     UISlider!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle  = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        titleLabel.textColor = WakeWellTheme.labelPrimary
        styleSlider()
    }

    private func styleSlider() {

        slider.minimumValue = 0
        slider.maximumValue = 1

        slider.minimumTrackTintColor = WakeWellTheme.accentPurple
        slider.maximumTrackTintColor = WakeWellTheme.border

        if let thumb = slider.thumbImage(for: .normal) {
            let tinted = thumb.withTintColor(WakeWellTheme.accentGold, renderingMode: .alwaysOriginal)
            slider.setThumbImage(tinted, for: .normal)
            slider.setThumbImage(tinted, for: .highlighted)
        } else {
            slider.thumbTintColor = WakeWellTheme.accentGold
        }

        slider.setMinimumTrackImage(nil, for: .normal)
        slider.setMaximumTrackImage(nil, for: .normal)

        slider.transform = .identity
    }

    private func makeTrack(_ color: UIColor) -> UIImage {
        let size = CGSize(width: 8, height: 8)
        let img = UIGraphicsImageRenderer(size: size).image { ctx in
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 4)
            color.setFill(); path.fill()
        }
        return img.resizableImage(
            withCapInsets: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4),
            resizingMode: .stretch
        )
    }
}
