//
//  AlarmPickerCell.swift
//  SetSail

import UIKit

final class AlarmPickerCell: UITableViewCell {

    static let reuseID = "AlarmPickerCell"

    @IBOutlet weak var timePicker:    CircularTimePicker!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle       = .none
        backgroundColor      = .clear
        contentView.backgroundColor = .clear
    }

}
