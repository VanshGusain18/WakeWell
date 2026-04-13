import UIKit

class AlarmCollectionViewCell: UICollectionViewCell {

    static let identifier = "AlarmCollectionViewCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    var onTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        applyStyling()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyShadowPath()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onTapped = nil
    }

    @objc private func handleTap() { onTapped?() }

    private func setupUI() {
        contentView.layer.cornerRadius  = 20
        contentView.layer.masksToBounds = true
        contentView.backgroundColor     = .systemBackground
        layer.masksToBounds             = false
    }

    private func applyStyling() {
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius  = 10
        layer.shadowOffset  = CGSize(width: 0, height: 4)
    }

    private func applyShadowPath() {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
    }

    func configure(with viewModel: AlarmViewModel) {
        titleLabel.text    = viewModel.title
        timeLabel.text     = viewModel.timeText
        subtitleLabel.text = viewModel.subtitleText
    }
}
