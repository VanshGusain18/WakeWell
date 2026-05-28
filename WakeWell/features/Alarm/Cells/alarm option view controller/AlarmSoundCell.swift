//
//  AlarmSoundCell.swift
//  SetSail

import UIKit

final class AlarmSoundCell: UITableViewCell {

    static let reuseID = "AlarmSoundCell"

    @IBOutlet weak var titleLabel:   UILabel!
    @IBOutlet weak var summaryLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle  = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        titleLabel.textColor   = WakeWellTheme.labelPrimary
        summaryLabel.textColor = WakeWellTheme.labelSecondary
        summaryLabel.adjustsFontSizeToFitWidth = true
        summaryLabel.minimumScaleFactor = 0.7
        tintColor = WakeWellTheme.accentPurple
    }
}
