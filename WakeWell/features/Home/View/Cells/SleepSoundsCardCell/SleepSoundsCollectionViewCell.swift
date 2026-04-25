import UIKit

class SleepSoundsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel:        UILabel!
    @IBOutlet weak var chevronImageView:  UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 24).cgPath
    }

    private func setupUI() {
        contentView.backgroundColor     = WakeWellTheme.cardBackground
        contentView.layer.cornerRadius  = 24
        contentView.layer.masksToBounds = true
        layer.masksToBounds  = false
        layer.shadowColor    = WakeWellTheme.shadowColor.cgColor
        layer.shadowOpacity  = WakeWellTheme.shadowOpacity
        layer.shadowRadius   = WakeWellTheme.shadowRadius
        layer.shadowOffset   = WakeWellTheme.shadowOffset

        titleLabel?.font      = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel?.textColor = WakeWellTheme.labelPrimary

        chevronImageView?.tintColor = WakeWellTheme.accentPurple
    }

    func configure(with viewModel: SleepSoundsViewModel) {
        titleLabel.text = viewModel.title
    }
}
