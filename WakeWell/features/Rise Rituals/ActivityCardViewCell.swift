//
//  ActivityCardViewCell.swift
//  WakeWell
//

import UIKit

// MARK: - ActivityCardViewCell

class ActivityCardViewCell: UICollectionViewCell {

    let titleLabel    = UILabel()
    let imageView     = UIImageView()
    let categoryLabel = UILabel()
    let gradientLayer = CAGradientLayer()

    /// Called when the 3-dot button is tapped
    var onOptionsTapped: (() -> Void)?
    var menuProvider: (() -> UIMenu?)? {
        didSet {
            optionsButton.menu = menuProvider?()
        }
    }

    private let optionsButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: config), for: .normal)
        btn.tintColor = .label
        btn.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.88)
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemGray5.cgColor
        btn.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        btn.layer.shadowOpacity = 1
        btn.layer.shadowRadius = 10
        btn.layer.shadowOffset = CGSize(width: 0, height: 5)
        btn.showsMenuAsPrimaryAction = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: Init

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
        gradientLayer.frame = contentView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        menuProvider = nil
        onOptionsTapped = nil
    }

    // MARK: Setup

    func setupUI() {
        contentView.layer.cornerRadius = 20
        contentView.backgroundColor = .secondarySystemBackground
        contentView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false

        gradientLayer.colors   = [UIColor.clear.cgColor,
                                   UIColor.black.withAlphaComponent(0.7).cgColor]
        gradientLayer.locations = [0.6, 1.0]

        titleLabel.font          = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor     = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        categoryLabel.font      = UIFont.systemFont(ofSize: 14)
        categoryLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(imageView)
        contentView.layer.addSublayer(gradientLayer)
        contentView.addSubview(titleLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(optionsButton)

        optionsButton.addTarget(self, action: #selector(optionsTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            // Image fills card
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // 3-dot button — top-right corner
            optionsButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            optionsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            optionsButton.widthAnchor.constraint(equalToConstant: 32),
            optionsButton.heightAnchor.constraint(equalToConstant: 32),

            // Labels at bottom
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: categoryLabel.topAnchor, constant: -4)
        ])
    }

    // MARK: Configure

    func configure(with activity: Activity, isExplore: Bool) {
        titleLabel.text    = activity.title
        imageView.image    = UIImage(named: activity.imageName)
        optionsButton.isHidden = false

        if isExplore {
            titleLabel.font      = UIFont.boldSystemFont(ofSize: 14)
            titleLabel.numberOfLines = 1
            categoryLabel.text   = ""
            categoryLabel.isHidden = true
        } else {
            titleLabel.font      = UIFont.boldSystemFont(ofSize: 22)
            titleLabel.numberOfLines = 2
            categoryLabel.text   = activity.category
            categoryLabel.isHidden = false
        }
    }

    // MARK: Actions

    @objc private func optionsTapped() {
        onOptionsTapped?()
    }
}

// MARK: - AddActivityCardCell
/// The "+" card shown at the end of the Morning Routine carousel

class AddActivityCardCell: UICollectionViewCell {

    static let identifier = "AddActivityCardCell"

    private let plusLabel: UILabel = {
        let lbl = UILabel()
        lbl.text          = "+"
        lbl.font          = UIFont.systemFont(ofSize: 44, weight: .thin)
        lbl.textColor     = .secondaryLabel
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text          = "Add Activity"
        lbl.font          = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl.textColor     = .secondaryLabel
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.layer.cornerRadius  = 20
        contentView.backgroundColor     = .secondarySystemBackground
        contentView.clipsToBounds       = true

        // Dashed border
        let dashedBorder       = CAShapeLayer()
        dashedBorder.strokeColor = UIColor.tertiaryLabel.cgColor
        dashedBorder.fillColor   = UIColor.clear.cgColor
        dashedBorder.lineDashPattern = [8, 5]
        dashedBorder.lineWidth   = 1.5
        dashedBorder.path        = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 1, dy: 1),
            cornerRadius: 20
        ).cgPath
        contentView.layer.addSublayer(dashedBorder)

        let stack = UIStackView(arrangedSubviews: [plusLabel, subtitleLabel])
        stack.axis      = .vertical
        stack.spacing   = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

// MARK: - ShowMoreFooterView
/// Footer at the bottom of the Explore section with a "Show More" button

class ShowMoreFooterView: UICollectionReusableView {

    static let identifier = "ShowMoreFooterView"

    var onShowMore: (() -> Void)?

    private let button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Show More", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        btn.tintColor = .systemBlue
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        btn.setImage(UIImage(systemName: "chevron.down", withConfiguration: config), for: .normal)
        btn.semanticContentAttribute = .forceRightToLeft
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
        button.addTarget(self, action: #selector(showMoreTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc private func showMoreTapped() {
        onShowMore?()
    }
}

// MARK: - AddToMorningSheetViewController
/// Modal sheet that lists all activities with checkmarks for adding to the morning routine

class AddToMorningSheetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var allActivities: [Activity] = []
    var selectedActivityIDs: Set<String> = []
    var maximumSelections: Int = 5
    var onDone: ((Set<String>) -> Void)?
    var onSelectionLimitReached: (() -> Void)?

    private var pendingIDs: Set<String> = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        pendingIDs = selectedActivityIDs

        title = "Add to Morning Routine"
        navigationItem.leftBarButtonItem  = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: self, action: #selector(doneTapped))

        tableView.delegate   = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "activityCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allActivities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell     = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath)
        let activity = allActivities[indexPath.row]

        var content        = cell.defaultContentConfiguration()
        content.text       = activity.title
        content.secondaryText = activity.category
        cell.contentConfiguration = content
        cell.accessoryType = pendingIDs.contains(activity.id) ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let activity = allActivities[indexPath.row]
        if pendingIDs.contains(activity.id) {
            pendingIDs.remove(activity.id)
        } else {
            guard pendingIDs.count < maximumSelections else {
                onSelectionLimitReached?()
                return
            }
            pendingIDs.insert(activity.id)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    // MARK: Actions

    @objc private func cancelTapped() { dismiss(animated: true) }
    @objc private func doneTapped()   { onDone?(pendingIDs); dismiss(animated: true) }
}
