import UIKit

class AlarmCollectionViewCell: UICollectionViewCell {

    static let identifier = "AlarmCollectionViewCell"

    @IBOutlet weak var titleLabel:    UILabel!
    @IBOutlet weak var timeLabel:     UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    private let alarmIconImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "alarm.fill", withConfiguration: config))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    var onTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        addAlarmIcon()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFromUserDefaults),
                                                name: .alarmTimeDidChange, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func refreshFromUserDefaults() {
        let savedTime = UserDefaults.standard.object(forKey: "wakewell.savedAlarmTime") as? Date
        configure(with: AlarmViewModel(model: AlarmModel(time: savedTime)))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
    }

    override func prepareForReuse() { super.prepareForReuse(); onTapped = nil }

    @objc private func handleTap() { onTapped?() }

    // ── Card ───────────────────────────────────────────────────────────────
    private func setupUI() {
        contentView.backgroundColor     = WakeWellTheme.cardBackground
        contentView.layer.cornerRadius  = 20
        contentView.layer.masksToBounds = true
        layer.masksToBounds             = false
        layer.shadowColor               = WakeWellTheme.shadowColor.cgColor
        layer.shadowOpacity             = WakeWellTheme.shadowOpacity
        layer.shadowRadius              = WakeWellTheme.shadowRadius
        layer.shadowOffset              = WakeWellTheme.shadowOffset

        // "YOUR ALARM" — matches SleepRing "YOUR SLEEP SCORE" style
        titleLabel.font          = .systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor     = WakeWellTheme.labelSecondary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1

        // Big gold time — centre aligned like the score number
        timeLabel.font          = .monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        timeLabel.textColor     = WakeWellTheme.accentGold
        timeLabel.textAlignment = .center
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.minimumScaleFactor        = 0.6
        timeLabel.numberOfLines             = 1

        // "Tap to edit" — matches SleepRing CTA label style
        subtitleLabel.font          = .systemFont(ofSize: 10, weight: .regular)
        subtitleLabel.textColor     = WakeWellTheme.labelSecondary
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 1
    }

    // ── Alarm icon pinned to top-right corner ─────────────────────────────
    // Mirrors the chevron position in SleepRingCollectionViewCell
    private func addAlarmIcon() {
        alarmIconImageView.tintColor = WakeWellTheme.accentPurple
        contentView.addSubview(alarmIconImageView)
        NSLayoutConstraint.activate([
            alarmIconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            alarmIconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            alarmIconImageView.widthAnchor.constraint(equalToConstant: 22),
            alarmIconImageView.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    // ── Configure ─────────────────────────────────────────────────────────
    func configure(with viewModel: AlarmViewModel) {
        titleLabel.text    = viewModel.title
        timeLabel.text     = viewModel.timeText
        subtitleLabel.text = viewModel.subtitleText
        timeLabel.textColor = viewModel.timeText == "--:--"
            ? WakeWellTheme.labelTertiary
            : WakeWellTheme.accentGold
    }
}

