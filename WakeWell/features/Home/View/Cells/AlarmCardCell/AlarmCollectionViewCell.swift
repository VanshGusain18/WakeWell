import UIKit

class AlarmCollectionViewCell: UICollectionViewCell {

    static let identifier = "AlarmCollectionViewCell"

    @IBOutlet weak var titleLabel:    UILabel!
    @IBOutlet weak var timeLabel:     UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var alarmIcon:     UIImageView!
    
    var onTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFromUserDefaults),
                                                name: .alarmTimeDidChange, object: nil)
        alarmIcon.tintColor = WakeWellTheme.accentPurple
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

    private func setupUI() {
        contentView.backgroundColor     = WakeWellTheme.cardBackground
        contentView.layer.cornerRadius  = 20
        contentView.layer.masksToBounds = true
        layer.masksToBounds             = false
        layer.shadowColor               = WakeWellTheme.shadowColor.cgColor
        layer.shadowOpacity             = WakeWellTheme.shadowOpacity
        layer.shadowRadius              = WakeWellTheme.shadowRadius
        layer.shadowOffset              = WakeWellTheme.shadowOffset

    }

    func configure(with viewModel: AlarmViewModel) {
        titleLabel.text    = viewModel.title
        timeLabel.text     = viewModel.timeText
        subtitleLabel.text = viewModel.subtitleText
        timeLabel.textColor = viewModel.timeText == "--:--"
            ? WakeWellTheme.labelTertiary
            : WakeWellTheme.accentGold
    }
}

