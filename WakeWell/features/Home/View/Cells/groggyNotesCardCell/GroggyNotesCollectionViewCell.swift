import UIKit

final class GroggyNotesCollectionViewCell: UICollectionViewCell, UITextViewDelegate {

    static let identifier = "GroggyNotesCollectionViewCell"

    enum InteractionState: Equatable {
        case empty
        case editing
        case saved
    }

    var onBeginEditing: (() -> Void)?
    var onEndEditing: (() -> Void)?
    var onPrimaryActionTapped: ((Float, String) -> Void)?

    @IBOutlet weak var groggyTitleLabel: UILabel!
    @IBOutlet weak var groggySlider: UISlider!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var notesTitleLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!

    private var interactionState: InteractionState = .empty

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
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
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        contentView.addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 24).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onBeginEditing = nil
        onEndEditing = nil
        onPrimaryActionTapped = nil
        interactionState = .empty
    }

    private func setupCard() {
        contentView.backgroundColor = WakeWellTheme.cardBackground
        contentView.subviews.first?.backgroundColor = WakeWellTheme.cardBackground
        contentView.layer.cornerRadius = 24
        contentView.layer.masksToBounds = true
        layer.masksToBounds = false
        layer.shadowColor = WakeWellTheme.shadowColor.cgColor
        layer.shadowOpacity = WakeWellTheme.shadowOpacity
        layer.shadowRadius = WakeWellTheme.shadowRadius
        layer.shadowOffset = WakeWellTheme.shadowOffset
    }

    private func setupGroggySection() {
        groggyTitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        groggyTitleLabel.textColor = WakeWellTheme.labelPrimary

        leftLabel.font = .systemFont(ofSize: 12)
        leftLabel.textColor = WakeWellTheme.labelSecondary
        rightLabel.font = leftLabel.font
        rightLabel.textColor = WakeWellTheme.labelSecondary

        groggySlider.minimumValue = 0
        groggySlider.maximumValue = 10
        groggySlider.minimumTrackTintColor = WakeWellTheme.accentPurple
        groggySlider.maximumTrackTintColor = WakeWellTheme.border
        groggySlider.thumbTintColor = WakeWellTheme.accentGold
    }

    private func setupNotesSection() {
        dividerView.backgroundColor = WakeWellTheme.border

        notesTitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        notesTitleLabel.textColor = WakeWellTheme.labelPrimary

        notesTextView.delegate = self
        notesTextView.font = .systemFont(ofSize: 14)
        notesTextView.textColor = WakeWellTheme.labelSecondary
        notesTextView.backgroundColor = .clear
        notesTextView.isScrollEnabled = true
        notesTextView.alwaysBounceVertical = true
        notesTextView.textContainerInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        notesTextView.textContainer.lineFragmentPadding = 0
        notesTextView.layer.cornerRadius = 0
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        guard interactionState == .editing else { return }
        if textView.textColor == WakeWellTheme.labelSecondary {
            textView.text = ""
            textView.textColor = WakeWellTheme.labelPrimary
        }
        textView.setContentOffset(.zero, animated: false)
        textView.scrollRangeToVisible(NSRange(location: textView.text.count, length: 0))
        onBeginEditing?()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           interactionState == .editing {
            textView.text = "Write how you feel today..."
            textView.textColor = WakeWellTheme.labelSecondary
        }
        onEndEditing?()
    }

    func textViewDidChange(_ textView: UITextView) {
        guard interactionState == .editing else { return }
        if textView.textColor == WakeWellTheme.labelSecondary {
            textView.textColor = WakeWellTheme.labelPrimary
        }
    }

    @objc private func groggyChanged() {
        guard interactionState == .editing else { return }
    }

    func configure(groggy groggyVM: GroggySliderViewModel,
                   notes notesVM: MorningNotesViewModel) {
        groggyTitleLabel.text = groggyVM.title
        leftLabel.text = groggyVM.leftLabel
        rightLabel.text = groggyVM.rightLabel
        notesTitleLabel.text = notesVM.title

        let hasSavedEntry = groggyVM.hasEntry || notesVM.hasEntry || groggyVM.isLocked || notesVM.isLocked
        let isSavedContent = hasSavedEntry && (groggyVM.isLocked || notesVM.isLocked)

        if hasSavedEntry {
            interactionState = .saved
            groggySlider.value = groggyVM.value
            notesTextView.text = notesVM.text.isEmpty ? notesVM.placeholderText : notesVM.text
            notesTextView.textColor = notesVM.text.isEmpty ? WakeWellTheme.labelSecondary : WakeWellTheme.labelPrimary
        } else {
            interactionState = .empty
            groggySlider.value = 0
            notesTextView.text = notesVM.placeholderText
            notesTextView.textColor = WakeWellTheme.labelSecondary
        }

        applyStateAppearance(animated: false)
        if isSavedContent {
            notesTextView.textColor = WakeWellTheme.labelPrimary
        }
    }

    @objc private func actionTapped() {
        switch interactionState {
        case .empty:
            enterEditingState()
        case .saved:
            enterEditingState()
        case .editing:
            commitCurrentValues()
        }
    }

    private func enterEditingState() {
        interactionState = .editing
        applyStateAppearance(animated: true)
        if notesTextView.textColor == WakeWellTheme.labelSecondary {
            notesTextView.text = ""
            notesTextView.textColor = WakeWellTheme.labelPrimary
        }
        notesTextView.isEditable = true
        notesTextView.isSelectable = true
        notesTextView.becomeFirstResponder()
        UISelectionFeedbackGenerator().selectionChanged()
    }

    private func commitCurrentValues() {
        let note = sanitizedNotesText()
        onPrimaryActionTapped?(groggySlider.value, note)

        if note.isEmpty {
            notesTextView.text = "Write how you feel today..."
            notesTextView.textColor = WakeWellTheme.labelSecondary
        } else {
            notesTextView.text = note
            notesTextView.textColor = WakeWellTheme.labelPrimary
        }

        interactionState = .saved
        notesTextView.resignFirstResponder()
        applyStateAppearance(animated: true)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func applyStateAppearance(animated: Bool) {
        let title: String
        let sliderEnabled: Bool
        let notesEditable: Bool
        let notesAlpha: CGFloat
        let sliderAlpha: CGFloat
        let buttonEnabled: Bool

        switch interactionState {
        case .empty:
            title = "Add"
            sliderEnabled = false
            notesEditable = false
            notesAlpha = 0.55
            sliderAlpha = 0.55
            buttonEnabled = true
        case .editing:
            title = "OK"
            sliderEnabled = true
            notesEditable = true
            notesAlpha = 1.0
            sliderAlpha = 1.0
            buttonEnabled = true
        case .saved:
            title = "Edit"
            sliderEnabled = false
            notesEditable = false
            notesAlpha = 0.85
            sliderAlpha = 0.85
            buttonEnabled = true
        }

        let updates = {
            self.actionButton.setTitle(title, for: .normal)
            self.groggySlider.isEnabled = sliderEnabled
            self.groggySlider.alpha = sliderAlpha
            self.notesTextView.isEditable = notesEditable
            self.notesTextView.isSelectable = notesEditable
            self.notesTextView.alpha = notesAlpha
            self.actionButton.isEnabled = buttonEnabled
            self.actionButton.alpha = 1.0
        }

        if animated {
            UIView.transition(with: actionButton, duration: 0.18, options: .transitionCrossDissolve, animations: {
                updates()
            })
        } else {
            updates()
        }
    }

    private func sanitizedNotesText() -> String {
        let text = notesTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text != "Write how you feel today..." else { return "" }
        return text
    }
}
