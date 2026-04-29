// OnboardingPageTableViewController.swift
// WakeWell
//
// A single onboarding slide rendered inside a UITableViewController.
// Replaces OnboardingPageViewController + OnboardingPageView.xib.
// No IBOutlets — fully code-driven.

import UIKit

// MARK: - Data model (shared across onboarding)

struct OnboardingPage {
    let sfSymbol:    String
    let title:       String
    let subtitle:    String
    let accentColor: UIColor
}

// MARK: - Section model

private enum PageSection: Int, CaseIterable {
    case appIcon        // app icon badge
    case illustration   // large SF symbol
    case text           // title + subtitle
}

// MARK: - View Controller

final class OnboardingPageTableViewController: UITableViewController {

    // MARK: Data (set by the container before display)
    var page: OnboardingPage?
    var pageIndex: Int = 0

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupTableView()
    }

    // MARK: Setup

    private func setupTableView() {
        tableView.register(AppIconCell.self,     forCellReuseIdentifier: AppIconCell.reuseID)
        tableView.register(IllustrationCell.self, forCellReuseIdentifier: IllustrationCell.reuseID)
        tableView.register(TextCell.self,         forCellReuseIdentifier: TextCell.reuseID)

        tableView.backgroundColor  = .clear
        tableView.separatorStyle   = .none
        tableView.isScrollEnabled  = false
        tableView.allowsSelection  = false
        tableView.showsVerticalScrollIndicator = false
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        PageSection.allCases.count
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int { 1 }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch PageSection(rawValue: indexPath.section)! {

        case .appIcon:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: AppIconCell.reuseID, for: indexPath) as! AppIconCell
            cell.configure()
            return cell

        case .illustration:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: IllustrationCell.reuseID, for: indexPath) as! IllustrationCell
            if let p = page {
                cell.configure(sfSymbol: p.sfSymbol, accentColor: p.accentColor)
            }
            return cell

        case .text:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TextCell.reuseID, for: indexPath) as! TextCell
            if let p = page {
                cell.configure(title: p.title, subtitle: p.subtitle)
            }
            return cell
        }
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        let h = tableView.bounds.height
        switch PageSection(rawValue: indexPath.section)! {
        case .appIcon:       return 80
        case .illustration:  return h * 0.45
        case .text:          return h * 0.35
        }
    }

    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat { .leastNormalMagnitude }
    override func tableView(_ tableView: UITableView,
                            heightForFooterInSection section: Int) -> CGFloat { .leastNormalMagnitude }
}

// MARK: - AppIconCell

private final class AppIconCell: UITableViewCell {
    static let reuseID = "AppIconCell"

    private let iconView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor       = .clear
        contentView.backgroundColor = .clear
        selectionStyle        = .none

        let cfg = UIImage.SymbolConfiguration(pointSize: 38, weight: .medium)
        iconView.image           = UIImage(systemName: "moon.zzz.fill",
                                           withConfiguration: cfg)?
                                     .withTintColor(WakeWellTheme.accentGold,
                                                    renderingMode: .alwaysOriginal)
        iconView.backgroundColor    = WakeWellTheme.cardBackground
        iconView.layer.cornerRadius = 18
        iconView.layer.shadowColor  = WakeWellTheme.shadowColor.cgColor
        iconView.layer.shadowOpacity = 0.25
        iconView.layer.shadowRadius = 10
        iconView.layer.shadowOffset = CGSize(width: 0, height: 4)
        iconView.contentMode        = .center
        iconView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 64),
            iconView.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure() { /* static content */ }
}

// MARK: - IllustrationCell

private final class IllustrationCell: UITableViewCell {
    static let reuseID = "IllustrationCell"

    private let imageView2 = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor       = .clear
        contentView.backgroundColor = .clear
        selectionStyle        = .none

        imageView2.contentMode = .scaleAspectFit
        imageView2.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView2)
        NSLayoutConstraint.activate([
            imageView2.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView2.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            imageView2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            imageView2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(sfSymbol: String, accentColor: UIColor) {
        let cfg = UIImage.SymbolConfiguration(pointSize: 120, weight: .thin)
        imageView2.image = UIImage(systemName: sfSymbol, withConfiguration: cfg)?
                             .withTintColor(accentColor, renderingMode: .alwaysOriginal)
    }
}

// MARK: - TextCell

private final class TextCell: UITableViewCell {
    static let reuseID = "TextCell"

    private let titleLabel    = UILabel()
    private let subtitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor       = .clear
        contentView.backgroundColor = .clear
        selectionStyle        = .none

        titleLabel.textColor     = WakeWellTheme.labelPrimary
        titleLabel.font          = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        subtitleLabel.textColor     = WakeWellTheme.labelSecondary
        subtitleLabel.font          = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis    = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, subtitle: String) {
        titleLabel.text    = title
        subtitleLabel.text = subtitle
    }
}
