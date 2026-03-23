//
//  SleepTimelineCell.swift
//  WakeWell
//
//  Created by geu on 23/03/26.
//

import UIKit

class SleepTimelineCell: UITableViewCell {

    @IBOutlet weak var glassContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timelineStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    private func setupStyle() {
        glassContainer.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        glassContainer.layer.cornerRadius = 20
        glassContainer.layer.borderWidth = 1
        glassContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor

        glassContainer.layer.shadowColor = UIColor.black.cgColor
        glassContainer.layer.shadowOpacity = 0.05
        glassContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        glassContainer.layer.shadowRadius = 10

        selectionStyle = .none
        backgroundColor = .clear

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
    }

    func configure(title: String, segments: [SleepSegment]) {
        titleLabel.text = title
        
        timelineStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard let totalEnd = segments.last?.end else { return }

        for segment in segments {
            let widthRatio = (segment.end - segment.start) / totalEnd
            
            let view = UIView()
            view.backgroundColor = segment.isAwake
                ? UIColor.systemRed.withAlphaComponent(0.8)
                : UIColor.systemBlue.withAlphaComponent(0.8)

            view.layer.cornerRadius = 4

            timelineStackView.addArrangedSubview(view)

            view.widthAnchor.constraint(equalTo: timelineStackView.widthAnchor, multiplier: widthRatio).isActive = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        timelineStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
