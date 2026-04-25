import UIKit

class HeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var glassContainer:    UIView!
    @IBOutlet weak var titleLabel:        UILabel!
    @IBOutlet weak var descriptionLabel:  UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle      = .none
        backgroundColor     = WakeWellTheme.glassBackground
        contentView.backgroundColor = .clear
        WakeWellTheme.styleGlassCard(glassContainer, cornerRadius: 24)

        titleLabel.font       = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor  = WakeWellTheme.labelPrimary

        descriptionLabel.font          = .systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.textColor     = WakeWellTheme.labelSecondary
        descriptionLabel.numberOfLines = 0
    }

    func configure(title: String, description: String) {
        titleLabel.text      = title
        descriptionLabel.text = description
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
