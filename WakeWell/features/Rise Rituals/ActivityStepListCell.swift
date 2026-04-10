//
//  ActivityStepListCell.swift
//  WakeWell
//

import UIKit

final class ActivityStepListCell: UITableViewCell {

    static let identifier = "ActivityStepListCell"

    @IBOutlet private weak var sectionLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var cardView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        cardView.layer.cornerRadius = 20
        cardView.backgroundColor = .secondarySystemBackground
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    func configure(sectionTitle: String, steps: [String]) {
        sectionLabel.text = sectionTitle

        for (index, step) in steps.enumerated() {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = .systemFont(ofSize: 17)
            label.textColor = .secondaryLabel
            label.text = "\(index + 1). \(step)"
            stackView.addArrangedSubview(label)
        }
    }
}
