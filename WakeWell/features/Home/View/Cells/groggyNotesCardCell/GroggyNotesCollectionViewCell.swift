import UIKit

class GroggyNotesCollectionViewCell: UICollectionViewCell, UITextViewDelegate {

    static let identifier = "GroggyNotesCollectionViewCell"
    enum PrimaryAction {
        case set
        case update
    }

    var onBeginEditing: (() -> Void)?
    var onEndEditing: (() -> Void)?
    var onGroggyChange: ((Float) -> Void)?
    var onTextChange: ((String) -> Void)?
    var onPrimaryActionTapped: ((Float, String, PrimaryAction) -> Void)?

    @IBOutlet weak var groggyTitleLabel: UILabel!
    @IBOutlet weak var groggySlider:     UISlider!
    @IBOutlet weak var leftLabel:        UILabel!
    @IBOutlet weak var rightLabel:       UILabel!
    @IBOutlet weak var dividerView:      UIView!
    @IBOutlet weak var notesTitleLabel:  UILabel!
    @IBOutlet weak var notesTextView:    UITextView!

    private var hasSavedValue = false
    private var isEditingGroggy = false

    private let setButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Set", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.setTitleColor(WakeWellTheme.accentPurple, for: .normal)
        button.setTitleColor(WakeWellTheme.labelTertiary, for: .disabled)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCard()
        setupGroggySection()
        setupNotesSection()
        groggySlider.addTarget(self, action: #selector(groggyChanged), for: .valueChanged)
        setButton.addTarget(self, action: #selector(setTapped), for: .touchUpInside)
        contentView.addSubview(setButton)
        NSLayoutConstraint.activate([
            setButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            setButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 24).cgPath
    }

    private func setupCard() {
        contentView.backgroundColor     = WakeWellTheme.cardBackground
        contentView.subviews.first?.backgroundColor = WakeWellTheme.cardBackground
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
        notesTextView.isScrollEnabled  = true
        notesTextView.alwaysBounceVertical = true
        notesTextView.textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        notesTextView.textContainer.lineFragmentPadding = 0
        notesTextView.layer.cornerRadius = 0
    }

    // ── TextViewDelegate (logic unchanged) ────────────────────────────────
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == WakeWellTheme.labelSecondary {
            textView.text      = ""
            textView.textColor = WakeWellTheme.labelPrimary
        }
        textView.setContentOffset(.zero, animated: false)
        textView.scrollRangeToVisible(NSRange(location: textView.text.count, length: 0))
        onBeginEditing?()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text      = "Write how you feel today..."
            textView.textColor = WakeWellTheme.labelSecondary
        }
        onEndEditing?()
    }

    func textViewDidChange(_ textView: UITextView) {
        onTextChange?(textView.text)
    }

    @objc private func groggyChanged() {
        onGroggyChange?(groggySlider.value)
    }

    func configure(groggy groggyVM: GroggySliderViewModel,
                   notes  notesVM:  MorningNotesViewModel) {
        groggyTitleLabel.text = groggyVM.title
        leftLabel.text        = groggyVM.leftLabel
        rightLabel.text       = groggyVM.rightLabel
        groggySlider.value    = groggyVM.value
        notesTitleLabel.text  = notesVM.title
        hasSavedValue = groggyVM.isLocked || notesVM.isLocked
        isEditingGroggy = false
        updateGroggyInteractionState(animated: false)
        if notesVM.text.isEmpty {
            notesTextView.text      = notesVM.placeholderText
            notesTextView.textColor = WakeWellTheme.labelSecondary
        } else {
            notesTextView.text      = notesVM.text
            notesTextView.textColor = WakeWellTheme.labelPrimary
        }
    }

    @objc private func setTapped() {
        if hasSavedValue && !isEditingGroggy {
            isEditingGroggy = true
            updateGroggyInteractionState(animated: true)
            return
        }

        let action: PrimaryAction = hasSavedValue ? .update : .set
        onPrimaryActionTapped?(groggySlider.value, notesTextView.text, action)

        hasSavedValue = true
        isEditingGroggy = false
        updateGroggyInteractionState(animated: true)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onBeginEditing = nil
        onEndEditing = nil
        onGroggyChange = nil
        onTextChange = nil
        onPrimaryActionTapped = nil
    }

    private func updateGroggyInteractionState(animated: Bool) {
        let targetTitle: String
        let targetEnabled: Bool
        let targetAlpha: CGFloat

        if !hasSavedValue {
            targetTitle = "Set"
            targetEnabled = true
            targetAlpha = 1.0
        } else if isEditingGroggy {
            targetTitle = "Update"
            targetEnabled = true
            targetAlpha = 1.0
        } else {
            targetTitle = "Update"
            targetEnabled = false
            targetAlpha = 0.95
        }

        let updates = {
            self.setButton.setTitle(targetTitle, for: .normal)
            self.groggySlider.isEnabled = targetEnabled
            self.setButton.isEnabled = true
            self.setButton.alpha = targetAlpha
        }

        if animated {
            UIView.transition(with: setButton, duration: 0.18, options: .transitionCrossDissolve, animations: {
                updates()
            })
        } else {
            updates()
        }
    }
}
