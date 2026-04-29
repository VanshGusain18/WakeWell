// ProfileTableViewController.swift
// WakeWell
//
// Displays the logged-in user's profile in a grouped UITableViewController.
// Fully storyboard-driven — no XIB needed.

import UIKit

// MARK: - Section / Row model

private enum ProfileSection: Int, CaseIterable {
    case avatar      = 0   // single cell with avatar + name + email
    case stats       = 1   // Age, Gender, Sleep Goal
    case account     = 2   // Member Since
    case actions     = 3   // Log Out
}

private enum StatsRow: Int, CaseIterable {
    case age, gender, sleepGoal
    var title: String {
        switch self {
        case .age:       return "Age"
        case .gender:    return "Gender"
        case .sleepGoal: return "Sleep Goal"
        }
    }
}

// MARK: - View Controller

final class ProfileTableViewController: UITableViewController {

    // MARK: Private state

    private var profileName      = ""
    private var profileEmail     = ""
    private var profileInitials  = "?"
    private var profileAge       = "—"
    private var profileGender    = "—"
    private var profileSleepGoal = "—"
    private var profileMemberSince = ""

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        setupTableView()
        applyTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfile()
        tableView.reloadData()
    }

    // MARK: Setup

    private func setupTableView() {
        tableView.register(AvatarCell.self,       forCellReuseIdentifier: AvatarCell.reuseID)
        tableView.register(DetailCell.self,       forCellReuseIdentifier: DetailCell.reuseID)
        tableView.register(ActionCell.self,       forCellReuseIdentifier: ActionCell.reuseID)
        tableView.separatorInset  = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        tableView.separatorColor  = WakeWellTheme.border
        tableView.backgroundColor = WakeWellTheme.background
        tableView.contentInset    = UIEdgeInsets(top: 16, left: 0, bottom: 32, right: 0)
    }

    private func applyTheme() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor    = UIColor(hex: "#1C1A3A")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        navigationController?.navigationBar.standardAppearance   = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = WakeWellTheme.accentGold
    }

    // MARK: Data

    private func loadProfile() {
        guard let profile = DatabaseManager.shared.fetchUserProfile() else {
            profileName        = "No profile found"
            profileEmail       = ""
            profileInitials    = "?"
            profileAge         = "—"
            profileGender      = "—"
            profileSleepGoal   = "—"
            profileMemberSince = ""
            return
        }

        profileName   = profile.name
        profileEmail  = profile.email

        let parts = profile.name.split(separator: " ")
        let inits = parts.prefix(2).compactMap { $0.first }.map { String($0) }.joined()
        profileInitials = inits.isEmpty ? "?" : inits.uppercased()

        profileAge       = "\(profile.age) years"
        profileGender    = profile.gender.capitalized
        profileSleepGoal = String(format: "%.1f hours", profile.sleepGoalHours)

        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        profileMemberSince = df.string(from: profile.createdAt)
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        ProfileSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch ProfileSection(rawValue: section)! {
        case .avatar:   return 1
        case .stats:    return StatsRow.allCases.count
        case .account:  return 1
        case .actions:  return 1
        }
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch ProfileSection(rawValue: indexPath.section)! {

        case .avatar:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: AvatarCell.reuseID, for: indexPath) as! AvatarCell
            cell.configure(initials: profileInitials,
                           name: profileName,
                           email: profileEmail,
                           memberSince: profileMemberSince)
            return cell

        case .stats:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: DetailCell.reuseID, for: indexPath) as! DetailCell
            let row = StatsRow(rawValue: indexPath.row)!
            let value: String
            switch row {
            case .age:       value = profileAge
            case .gender:    value = profileGender
            case .sleepGoal: value = profileSleepGoal
            }
            cell.configure(title: row.title, value: value)
            return cell

        case .account:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: DetailCell.reuseID, for: indexPath) as! DetailCell
            cell.configure(title: "Member Since", value: profileMemberSince)
            return cell

        case .actions:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ActionCell.reuseID, for: indexPath) as! ActionCell
            cell.configure(title: "Log Out", isDestructive: true)
            return cell
        }
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch ProfileSection(rawValue: indexPath.section)! {
        case .avatar:  return 160
        default:       return 56
        }
    }

    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        guard let title = sectionTitle(for: section) else { return nil }
        return makeSectionHeader(title: title)
    }

    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        sectionTitle(for: section) != nil ? 36 : 8
    }

    override func tableView(_ tableView: UITableView,
                            heightForFooterInSection section: Int) -> CGFloat { 8 }

    override func tableView(_ tableView: UITableView,
                            viewForFooterInSection section: Int) -> UIView? { UIView() }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if ProfileSection(rawValue: indexPath.section) == .actions {
            confirmLogout()
        }
    }

    // MARK: Private helpers

    private func sectionTitle(for section: Int) -> String? {
        switch ProfileSection(rawValue: section)! {
        case .avatar:  return nil
        case .stats:   return "Personal Info"
        case .account: return "Account"
        case .actions: return nil
        }
    }

    private func makeSectionHeader(title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        let label = UILabel()
        label.text      = title.uppercased()
        label.textColor = WakeWellTheme.labelTertiary
        label.font      = .systemFont(ofSize: 11, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }

    private func confirmLogout() {
        let alert = UIAlertController(title: "Log Out",
                                      message: "Are you sure you want to log out?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        present(alert, animated: true)
    }

    private func performLogout() {
        UserDefaults.standard.set(false, forKey: "ww_logged_in")
        guard let window = view.window else { return }
        let onboarding = OnboardingContainerTableViewController()
        UIView.transition(with: window, duration: 0.5,
                          options: .transitionFlipFromLeft,
                          animations: { window.rootViewController = onboarding })
    }
}

// MARK: - AvatarCell

private final class AvatarCell: UITableViewCell {
    static let reuseID = "AvatarCell"

    private let avatarContainer = UIView()
    private let initialsLabel   = UILabel()
    private let nameLabel       = UILabel()
    private let emailLabel      = UILabel()
    private let memberLabel     = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor      = .clear
        selectionStyle       = .none
        contentView.backgroundColor = .clear

        // Avatar circle
        avatarContainer.backgroundColor    = WakeWellTheme.accentPurple
        avatarContainer.layer.cornerRadius = 44
        avatarContainer.clipsToBounds      = false
        avatarContainer.layer.borderWidth  = 3
        avatarContainer.layer.borderColor  = WakeWellTheme.accentGold.cgColor
        avatarContainer.layer.shadowColor  = WakeWellTheme.shadowColor.cgColor
        avatarContainer.layer.shadowOpacity = 0.35
        avatarContainer.layer.shadowRadius = 12
        avatarContainer.layer.shadowOffset = CGSize(width: 0, height: 6)
        avatarContainer.translatesAutoresizingMaskIntoConstraints = false

        // Inner clip view so shadow is outside
        let innerClip = UIView(frame: CGRect(x: 0, y: 0, width: 88, height: 88))
        innerClip.backgroundColor    = WakeWellTheme.accentPurple
        innerClip.layer.cornerRadius = 44
        innerClip.clipsToBounds      = true
        avatarContainer.addSubview(innerClip)

        initialsLabel.textColor     = .white
        initialsLabel.font          = .systemFont(ofSize: 30, weight: .bold)
        initialsLabel.textAlignment = .center
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        innerClip.addSubview(initialsLabel)
        NSLayoutConstraint.activate([
            initialsLabel.centerXAnchor.constraint(equalTo: innerClip.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: innerClip.centerYAnchor)
        ])

        nameLabel.textColor     = WakeWellTheme.labelPrimary
        nameLabel.font          = .systemFont(ofSize: 20, weight: .bold)
        nameLabel.textAlignment = .center

        emailLabel.textColor     = WakeWellTheme.labelSecondary
        emailLabel.font          = .systemFont(ofSize: 13)
        emailLabel.textAlignment = .center

        memberLabel.textColor     = WakeWellTheme.labelTertiary
        memberLabel.font          = .systemFont(ofSize: 11)
        memberLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [nameLabel, emailLabel, memberLabel])
        stack.axis    = .vertical
        stack.spacing = 3
        stack.translatesAutoresizingMaskIntoConstraints = false

        let outerStack = UIStackView(arrangedSubviews: [avatarContainer, stack])
        outerStack.axis      = .vertical
        outerStack.alignment = .center
        outerStack.spacing   = 12
        outerStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(outerStack)

        NSLayoutConstraint.activate([
            avatarContainer.widthAnchor.constraint(equalToConstant: 88),
            avatarContainer.heightAnchor.constraint(equalToConstant: 88),
            outerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            outerStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            outerStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])

        // Gradient card background
        let grad = CAGradientLayer()
        grad.colors = [UIColor(hex: "#1C1A3A").cgColor, UIColor(hex: "#2D2B55").cgColor]
        grad.frame  = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 160)
        contentView.layer.insertSublayer(grad, at: 0)
    }

    func configure(initials: String, name: String, email: String, memberSince: String) {
        initialsLabel.text  = initials
        nameLabel.text      = name
        emailLabel.text     = email
        memberLabel.text    = memberSince.isEmpty ? "" : "Member since \(memberSince)"
    }
}

// MARK: - DetailCell

private final class DetailCell: UITableViewCell {
    static let reuseID = "DetailCell"

    private let titleLbl  = UILabel()
    private let valueLbl  = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor       = WakeWellTheme.cardBackground
        selectionStyle        = .none

        titleLbl.textColor    = WakeWellTheme.labelSecondary
        titleLbl.font         = .systemFont(ofSize: 15)
        valueLbl.textColor    = WakeWellTheme.labelPrimary
        valueLbl.font         = .systemFont(ofSize: 15, weight: .semibold)
        valueLbl.textAlignment = .right

        let stack = UIStackView(arrangedSubviews: [titleLbl, valueLbl])
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(title: String, value: String) {
        titleLbl.text = title
        valueLbl.text = value
    }
}

// MARK: - ActionCell

private final class ActionCell: UITableViewCell {
    static let reuseID = "ActionCell"

    private let actionLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = WakeWellTheme.cardBackground
        actionLabel.textAlignment = .center
        actionLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(actionLabel)
        NSLayoutConstraint.activate([
            actionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            actionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(title: String, isDestructive: Bool) {
        actionLabel.text      = title
        actionLabel.textColor = isDestructive ? UIColor(hex: "#FF6B6B") : WakeWellTheme.accentGold
    }
}
