import UIKit

class infoTableViewCell: UITableViewCell {

    @IBOutlet weak var glassContainer:    UIView!
    @IBOutlet weak var titleLabel:        UILabel!
    @IBOutlet weak var descriptionLabel:  UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle      = .none
        backgroundColor     = WakeWellTheme.glassBackground
        contentView.backgroundColor = .clear
        WakeWellTheme.styleGlassCard(glassContainer, cornerRadius: 20)

        titleLabel.font       = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor  = WakeWellTheme.labelPrimary

        descriptionLabel.font          = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor     = WakeWellTheme.labelSecondary
        descriptionLabel.numberOfLines = 0
    }

    func configure(title: String, description: String) {
        titleLabel.text       = title
        descriptionLabel.text = description
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text       = nil
        descriptionLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
