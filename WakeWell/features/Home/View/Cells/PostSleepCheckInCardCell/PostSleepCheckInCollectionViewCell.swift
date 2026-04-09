import UIKit

final class PostSleepCheckInCollectionViewCell: UICollectionViewCell, UITextViewDelegate {
    
    static let identifier = "PostSleepCheckInCollectionViewCell"
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let sliderTitleLabel = UILabel()
    private let groggySlider = UISlider()
    private let leftLabel = UILabel()
    private let rightLabel = UILabel()
    private let noteTitleLabel = UILabel()
    private let textView = UITextView()
    private let sliderLabelsStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 24).cgPath
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 24
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 14
        layer.shadowOffset = CGSize(width: 0, height: 8)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: "checkmark.circle.fill")
        iconImageView.tintColor = .systemTeal
        iconImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        
        sliderTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sliderTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        sliderTitleLabel.textColor = .label
        
        groggySlider.translatesAutoresizingMaskIntoConstraints = false
        groggySlider.minimumValue = 0
        groggySlider.maximumValue = 10
        groggySlider.minimumTrackTintColor = .systemTeal
        groggySlider.maximumTrackTintColor = .systemGray4
        
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        leftLabel.font = .systemFont(ofSize: 12, weight: .medium)
        leftLabel.textColor = .secondaryLabel
        
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.font = .systemFont(ofSize: 12, weight: .medium)
        rightLabel.textColor = .secondaryLabel
        
        noteTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        noteTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        noteTitleLabel.textColor = .label
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .secondaryLabel
        textView.backgroundColor = .systemBackground
        textView.layer.cornerRadius = 16
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        
        sliderLabelsStack.translatesAutoresizingMaskIntoConstraints = false
        sliderLabelsStack.axis = .horizontal
        sliderLabelsStack.distribution = .equalSpacing
        sliderLabelsStack.addArrangedSubview(leftLabel)
        sliderLabelsStack.addArrangedSubview(rightLabel)
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(sliderTitleLabel)
        contentView.addSubview(groggySlider)
        contentView.addSubview(sliderLabelsStack)
        contentView.addSubview(noteTitleLabel)
        contentView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            sliderTitleLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            sliderTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sliderTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            groggySlider.topAnchor.constraint(equalTo: sliderTitleLabel.bottomAnchor, constant: 14),
            groggySlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            groggySlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            sliderLabelsStack.topAnchor.constraint(equalTo: groggySlider.bottomAnchor, constant: 8),
            sliderLabelsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sliderLabelsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            noteTitleLabel.topAnchor.constraint(equalTo: sliderLabelsStack.bottomAnchor, constant: 20),
            noteTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            noteTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            textView.topAnchor.constraint(equalTo: noteTitleLabel.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 104),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with model: PostSleepCheckInModel) {
        let groggyViewModel = GroggySliderViewModel(model: model.groggy)
        let notesViewModel = MorningNotesViewModel(model: model.note)
        
        titleLabel.text = "Post - Sleep Check - In"
        subtitleLabel.text = "Reflect on how your night feels this morning."
        sliderTitleLabel.text = groggyViewModel.title
        groggySlider.value = groggyViewModel.value
        leftLabel.text = groggyViewModel.leftLabel
        rightLabel.text = groggyViewModel.rightLabel
        noteTitleLabel.text = notesViewModel.title
        
        if notesViewModel.text.isEmpty {
            textView.text = notesViewModel.placeholderText
            textView.textColor = .secondaryLabel
        } else {
            textView.text = notesViewModel.text
            textView.textColor = .label
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .secondaryLabel {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "Write how you feel today..."
            textView.textColor = .secondaryLabel
        }
    }
}
