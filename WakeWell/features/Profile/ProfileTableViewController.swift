import UIKit

private enum ProfileSection: Int, CaseIterable {
    case account
    case sleepPreferences
    case personalInformation
    case integrations
    case actions

    var title: String {
        switch self {
        case .account: return "Account"
        case .sleepPreferences: return "Sleep Preferences"
        case .personalInformation: return "Personal Information"
        case .integrations: return "Integrations & Permissions"
        case .actions: return ""
        }
    }

    var subtitle: String? {
        switch self {
        case .account: return "Your identity and membership"
        case .sleepPreferences: return "Sleep schedule and targets"
        case .personalInformation: return "Basic profile details"
        case .integrations: return "Connected services and permissions"
        case .actions: return nil
        }
    }
}

private struct ProfileDetailRow {
    let title: String
    let sfSymbol: String
    let value: String
}

final class ProfileTableViewController: UITableViewController {

    private var profile: UserProfile?
    private var sections: [ProfileSection: [ProfileDetailRow]] = [:]
    private var profileName = ""
    private var profileEmail = ""
    private var profileMemberSince = ""
    private var profileInitials = "?"
    private var profilePhotoURL: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        applyNavBar()
        reloadProfile()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authStateChanged),
            name: .authStateDidChange,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyNavBar()
        reloadProfile()
        tableView.reloadData()
    }

    private func setupTableView() {
        tableView.register(AvatarCell.self, forCellReuseIdentifier: AvatarCell.reuseID)
        tableView.register(DetailCell.self, forCellReuseIdentifier: DetailCell.reuseID)
        tableView.register(ActionCell.self, forCellReuseIdentifier: ActionCell.reuseID)

        tableView.separatorStyle = .none
        tableView.backgroundColor = WakeWellTheme.background
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 32, right: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.cellLayoutMarginsFollowReadableWidth = false

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

    private func applyNavBar() {
        title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = WakeWellTheme.background
        appearance.titleTextAttributes = [.foregroundColor: WakeWellTheme.labelPrimary]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = WakeWellTheme.accentPurple
    }

    private func reloadProfile() {
        guard let profile = ProfileRepository.shared.currentProfile() else {
            self.profile = nil
            profileName = ""
            profileEmail = ""
            profileMemberSince = ""
            profileInitials = "?"
            profilePhotoURL = nil
            sections = [:]
            return
        }

        self.profile = profile
        profileName = profile.displayName
        profileEmail = profile.email
        profileMemberSince = Self.memberSinceFormatter.string(from: profile.memberSince)
        profileInitials = profile.initials
        profilePhotoURL = profile.profilePhotoURL

        sections = [
            .sleepPreferences: [
                ProfileDetailRow(
                    title: "Sleep Goal",
                    sfSymbol: "moon.zzz",
                    value: (Self.hoursFormatter.string(from: profile.sleepPreferences.sleepGoalHours as NSNumber).map { "\($0) hrs" }) ?? "—"
                ),
                ProfileDetailRow(
                    title: "Bedtime Goal",
                    sfSymbol: "moon.stars",
                    value: Self.timeFormatter.string(from: profile.sleepPreferences.bedtimeGoal)
                ),
                ProfileDetailRow(
                    title: "Wake Time Goal",
                    sfSymbol: "sunrise",
                    value: Self.timeFormatter.string(from: profile.sleepPreferences.wakeTimeGoal)
                )
            ],
            .personalInformation: [
                ProfileDetailRow(title: "Biological Sex", sfSymbol: "person.text.rectangle", value: profile.onboardingPreferences.biologicalSex),
                ProfileDetailRow(title: "Age Range", sfSymbol: "calendar", value: profile.onboardingPreferences.ageRange)
            ],
            .integrations: [
                ProfileDetailRow(title: "HealthKit", sfSymbol: "heart.text.square", value: profile.permissionState.healthKitGranted ? "Connected" : "Not connected"),
                ProfileDetailRow(title: "Apple Watch Status", sfSymbol: "applewatch", value: profile.permissionState.watchStatus),
                ProfileDetailRow(title: "Notifications", sfSymbol: "bell", value: profile.permissionState.notificationsGranted ? "Enabled" : "Disabled")
            ]
        ]
    }

    @objc private func authStateChanged() {
        reloadProfile()
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        ProfileSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard profile != nil else { return 0 }
        guard let sectionType = ProfileSection(rawValue: section) else { return 0 }
        switch sectionType {
        case .account: return 1
        case .sleepPreferences: return sections[.sleepPreferences]?.count ?? 0
        case .personalInformation: return sections[.personalInformation]?.count ?? 0
        case .integrations: return sections[.integrations]?.count ?? 0
        case .actions: return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = ProfileSection(rawValue: indexPath.section) else { return UITableViewCell() }

        switch sectionType {
        case .account:
            let cell = tableView.dequeueReusableCell(withIdentifier: AvatarCell.reuseID, for: indexPath) as! AvatarCell
            styleCard(cell, isFirst: true, isLast: true)
            cell.configure(
                initials: profileInitials,
                name: profileName,
                email: profileEmail,
                memberSince: profileMemberSince,
                avatarURL: profilePhotoURL
            )
            return cell

        case .sleepPreferences, .personalInformation, .integrations:
            let rows = sections[sectionType] ?? []
            let row = rows[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.reuseID, for: indexPath) as! DetailCell
            let isFirst = indexPath.row == 0
            let isLast = indexPath.row == rows.count - 1
            styleCard(cell, isFirst: isFirst, isLast: isLast)
            if !isLast {
                addSeparator(to: cell.contentView)
            }
            cell.configure(title: row.title, value: row.value, sfSymbol: row.sfSymbol)
            return cell

        case .actions:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.reuseID, for: indexPath) as! ActionCell
            styleActionCard(cell)
            cell.configure(title: "Log Out", isDestructive: true)
            cell.onTap = { [weak self] in self?.confirmLogout() }
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionType = ProfileSection(rawValue: indexPath.section) else { return 44 }
        switch sectionType {
        case .account: return 134
        case .sleepPreferences, .personalInformation, .integrations: return 58
        case .actions: return 76
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard profile != nil else { return nil }
        guard let sectionType = ProfileSection(rawValue: section),
              sectionType != .actions else { return nil }

        let container = UIView()
        container.backgroundColor = .clear

        let titleLabel = UILabel()
        titleLabel.text = sectionType.title.uppercased()
        titleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        titleLabel.textColor = WakeWellTheme.labelTertiary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(titleLabel)

        var subtitleLabel: UILabel?
        if let subtitle = sectionType.subtitle {
            let label = UILabel()
            label.text = subtitle
            label.font = .systemFont(ofSize: 13, weight: .regular)
            label.textColor = WakeWellTheme.labelSecondary
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)
            subtitleLabel = label
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 4)
        ])

        if let subtitleLabel {
            NSLayoutConstraint.activate([
                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
                subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
                subtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
            ])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
            ])
        }

        return container
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard profile != nil else { return 0.01 }
        guard let sectionType = ProfileSection(rawValue: section), sectionType != .actions else { return 12 }
        switch sectionType {
        case .account: return 38
        case .sleepPreferences, .personalInformation, .integrations: return 54
        case .actions: return 12
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 0.01 }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { nil }

    private func styleCard(_ cell: UITableViewCell, isFirst: Bool, isLast: Bool) {
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = WakeWellTheme.cardBackground
        var corners: CACornerMask = []
        if isFirst { corners.formUnion([.layerMinXMinYCorner, .layerMaxXMinYCorner]) }
        if isLast { corners.formUnion([.layerMinXMaxYCorner, .layerMaxXMaxYCorner]) }

        cell.contentView.layer.cornerRadius = isFirst || isLast ? 18 : 0
        cell.contentView.layer.maskedCorners = corners
        cell.contentView.layer.masksToBounds = true
        if isLast {
            cell.layer.masksToBounds = false
            cell.layer.shadowColor = WakeWellTheme.shadowColor.cgColor
            cell.layer.shadowOpacity = WakeWellTheme.shadowOpacity
            cell.layer.shadowRadius = WakeWellTheme.shadowRadius
            cell.layer.shadowOffset = WakeWellTheme.shadowOffset
        } else {
            cell.layer.shadowOpacity = 0
        }
    }

    private func styleActionCard(_ cell: UITableViewCell) {
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = WakeWellTheme.cardBackground
        cell.contentView.layer.cornerRadius = 18
        cell.contentView.layer.masksToBounds = true
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = WakeWellTheme.shadowColor.cgColor
        cell.layer.shadowOpacity = WakeWellTheme.shadowOpacity
        cell.layer.shadowRadius = WakeWellTheme.shadowRadius
        cell.layer.shadowOffset = WakeWellTheme.shadowOffset
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard profile != nil else { return }
        let hInset = tableView.layoutMargins.left
        cell.contentView.frame = cell.contentView.frame.inset(
            by: UIEdgeInsets(top: 0, left: hInset, bottom: 0, right: hInset)
        )
    }

    private func addSeparator(to view: UIView) {
        view.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }

        let sep = UIView()
        sep.tag = 999
        sep.backgroundColor = WakeWellTheme.border
        sep.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sep)
        NSLayoutConstraint.activate([
            sep.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 62),
            sep.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sep.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sep.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    private func confirmLogout() {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        present(alert, animated: true)
    }

    private func performLogout() {
        ProfileRepository.shared.signOut()
    }

    private static let memberSinceFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    private static let hoursFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
}
