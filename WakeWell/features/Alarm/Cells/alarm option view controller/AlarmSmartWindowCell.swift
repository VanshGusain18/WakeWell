//
//  AlarmSmartWindowCell.swift
//  SetSail

import UIKit

final class AlarmSmartWindowCell: UITableViewCell {

    static let reuseID = "AlarmSmartWindowCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle  = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        titleLabel.textColor = WakeWellTheme.labelPrimary
        menuButton.setTitleColor(WakeWellTheme.accentPurple, for: .normal)
    }
}
