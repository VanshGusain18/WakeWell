import UIKit

class GroggyNotesCollectionViewCell: UICollectionViewCell, UITextViewDelegate {

    static let identifier = "GroggyNotesCollectionViewCell"

    @IBOutlet weak var groggyTitleLabel: UILabel!
    @IBOutlet weak var groggySlider:     UISlider!
    @IBOutlet weak var leftLabel:        UILabel!
    @IBOutlet weak var rightLabel:       UILabel!
    @IBOutlet weak var dividerView:      UIView!
    @IBOutlet weak var notesTitleLabel:  UILabel!
    @IBOutlet weak var notesTextView:    UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCard()
        setupGroggySection()
        setupNotesSection()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 24).cgPath
    }

    private func setupCard() {
        contentView.backgroundColor     = WakeWellTheme.cardBackground
        contentView.layer.cornerRadius  = 24
        contentView.layer.masksToBounds = true
        layer.masksToBounds  = false
        layer.shadowColor    = WakeWellTheme.shadowColor.cgColor
        layer.shadowOpacity  = WakeWellTheme.shadowOpacity
        layer.shadowRadius   = WakeWellTheme.shadowRadius
        layer.shadowOffset   = WakeWellTheme.shadowOffset
    }

    private func setupGroggySection() {
        groggyTitleLabel.font      = .systemFont(ofSize: 15, weight: .semibold)
        groggyTitleLabel.textColor = WakeWellTheme.labelPrimary

        leftLabel.font       = .systemFont(ofSize: 12)
        leftLabel.textColor  = WakeWellTheme.labelSecondary
        rightLabel.font      = leftLabel.font
        rightLabel.textColor = WakeWellTheme.labelSecondary

        // Purple track, gold thumb — matches purple/amber palette
        groggySlider.minimumValue           = 0
        groggySlider.maximumValue           = 10
        groggySlider.minimumTrackTintColor  = WakeWellTheme.accentPurple
        groggySlider.maximumTrackTintColor  = WakeWellTheme.border
        groggySlider.thumbTintColor         = WakeWellTheme.accentGold
    }

    private func setupNotesSection() {
        dividerView.backgroundColor    = WakeWellTheme.border

        notesTitleLabel.font           = .systemFont(ofSize: 15, weight: .semibold)
        notesTitleLabel.textColor      = WakeWellTheme.labelPrimary

        notesTextView.delegate         = self
        notesTextView.font             = .systemFont(ofSize: 14)
        notesTextView.textColor        = WakeWellTheme.labelSecondary
        notesTextView.backgroundColor  = .clear
        notesTextView.layer.cornerRadius = 0
    }

    // ── TextViewDelegate (logic unchanged) ────────────────────────────────
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == WakeWellTheme.labelSecondary {
            textView.text      = ""
            textView.textColor = WakeWellTheme.labelPrimary
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text      = "Write how you feel today..."
            textView.textColor = WakeWellTheme.labelSecondary
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
            notesTextView.textColor = WakeWellTheme.labelSecondary
        } else {
            notesTextView.text      = notesVM.text
            notesTextView.textColor = WakeWellTheme.labelPrimary
        }
    }
}
