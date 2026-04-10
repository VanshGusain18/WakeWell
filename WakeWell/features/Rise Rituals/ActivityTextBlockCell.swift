//
//  ActivityTextBlockCell.swift
//  WakeWell
//

import UIKit

final class ActivityTextBlockCell: UITableViewCell {

    static let identifier = "ActivityTextBlockCell"

    @IBOutlet private weak var sectionLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var cardView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        cardView.layer.cornerRadius = 20
        cardView.backgroundColor = .secondarySystemBackground
    }

    func configure(sectionTitle: String, body: String) {
        sectionLabel.text = sectionTitle
        bodyLabel.text = body
    }
}
