import UIKit

class RoutineFooterView: UICollectionReusableView {

    static let identifier = "RoutineFooterView"
    let startButton = UIButton(type: .system)
    var startAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        // Gold CTA button — matches screenshot "Start Ritual"
        WakeWellTheme.stylePrimaryButton(startButton, cornerRadius: 16)
        startButton.setTitle("Start Routine", for: .normal)
        startButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        startButton.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)

        addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            startButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            startButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    @objc func btnTapped() { startAction?() }
    required init?(coder: NSCoder) { fatalError() }
}
