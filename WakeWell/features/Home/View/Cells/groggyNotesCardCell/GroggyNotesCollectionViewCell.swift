//
//  GroggyNotesCollectionViewCell.swift
//  WakeWell
//
//  Created by geu on 11/04/26.
//

import UIKit

class GroggyNotesCollectionViewCell: UICollectionViewCell, UITextViewDelegate {

    static let identifier = "GroggyNotesCollectionViewCell"
    
    @IBOutlet weak var groggyTitleLabel : UILabel!
    @IBOutlet weak var groggySlider : UISlider!
    @IBOutlet weak var leftLabel : UILabel!
    @IBOutlet weak var rightLabel : UILabel!
    
    @IBOutlet weak var dividerView : UIView!
    
    @IBOutlet weak var notesTitleLabel : UILabel!
    @IBOutlet weak var notesTextView : UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCard()
        setupGroggySection()
        setupNotesSection()
        applyStyling()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyShadowPath()
    }

    private func setupCard() {
        contentView.layer.cornerRadius  = 24
        contentView.layer.masksToBounds = true
        contentView.backgroundColor     = .secondarySystemBackground
        layer.masksToBounds             = false
    }

    private func setupGroggySection() {
        groggySlider.minimumValue = 0
        groggySlider.maximumValue = 10
    }

    private func setupNotesSection() {
        notesTextView.delegate  = self
        notesTextView.textColor = .secondaryLabel
        notesTextView.backgroundColor = .clear
        notesTextView.layer.cornerRadius = 0
        dividerView.backgroundColor = .separator
    }

    private func applyStyling() {
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius  = 12
        layer.shadowOffset  = CGSize(width: 0, height: 6)
    }

    private func applyShadowPath() {
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 24
        ).cgPath
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.secondaryLabel {
            textView.text      = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text      = "Write how you feel today..."
            textView.textColor = .secondaryLabel
        }
    }

    func configure(groggy groggyVM: GroggySliderViewModel,
                   notes  notesVM:  MorningNotesViewModel) {
        groggyTitleLabel.text = groggyVM.title
        leftLabel.text        = groggyVM.leftLabel
        rightLabel.text       = groggyVM.rightLabel
        groggySlider.value    = groggyVM.value

        notesTitleLabel.text  = notesVM.title
        if notesVM.text.isEmpty {
            notesTextView.text      = notesVM.placeholderText
            notesTextView.textColor = .secondaryLabel
        } else {
            notesTextView.text      = notesVM.text
            notesTextView.textColor = .label
        }
    }
}
