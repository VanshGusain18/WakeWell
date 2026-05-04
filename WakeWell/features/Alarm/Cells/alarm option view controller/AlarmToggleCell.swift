//
//  AlarmToggleCell.swift
//  WakeWell

import UIKit

final class AlarmToggleCell: UITableViewCell {

    static let reuseID = "AlarmToggleCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toggle:     UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle  = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        toggle.onTintColor = WakeWellTheme.accentPurple
        titleLabel.textColor = WakeWellTheme.labelPrimary
    }
}
