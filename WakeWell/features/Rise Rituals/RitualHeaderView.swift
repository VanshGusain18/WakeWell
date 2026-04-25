import UIKit

class RitualHeaderView: UICollectionReusableView {

    let titleLabel = UILabel()
    static let identifier = "RitualHeaderView"

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        titleLabel.font      = .boldSystemFont(ofSize: 22)
        titleLabel.textColor = WakeWellTheme.labelPrimary
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}
