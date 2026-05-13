
import UIKit

private enum ProfileSection: Int, CaseIterable {
    case avatar
    case stats
    case actions
}

private struct StatRow {
    let title:     String
    let sfSymbol:  String
    var value:     String
}

final class ProfileTableViewController: UITableViewController {
    private var stats: [StatRow] = [
        StatRow(title: "Wake-up Goal", sfSymbol: "alarm", value: "—"),
        StatRow(title: "Sleep Goal", sfSymbol: "moon.zzz", value: "—"),
        StatRow(title: "Biological Sex", sfSymbol: "person.text.rectangle", value: "—"),
        StatRow(title: "Age Range", sfSymbol: "calendar", value: "—"),
        StatRow(title: "Bedtime Goal", sfSymbol: "moon.stars", value: "—"),
        StatRow(title: "Wake Time Goal", sfSymbol: "sunrise", value: "—"),
        StatRow(title: "HealthKit", sfSymbol: "heart.text.square", value: "—"),
        StatRow(title: "Watch Status", sfSymbol: "applewatch", value: "—"),
        StatRow(title: "Notifications", sfSymbol: "bell", value: "—"),
        StatRow(title: "Sleep Difficulties", sfSymbol: "exclamationmark.triangle", value: "—"),
        StatRow(title: "Member Since", sfSymbol: "calendar.badge.clock", value: "—")
    ]

    private var profileName     = ""
    private var profileEmail    = ""
    private var profileInitials = "?"
    private var profileMemberSince = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        applyNavBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfile()
        tableView.reloadData()
    }
    private func setupTableView() {
        tableView.register(AvatarCell.self,  forCellReuseIdentifier: AvatarCell.reuseID)
        tableView.register(DetailCell.self,  forCellReuseIdentifier: DetailCell.reuseID)
        tableView.register(ActionCell.self,  forCellReuseIdentifier: ActionCell.reuseID)

        tableView.separatorStyle  = .none
        tableView.backgroundColor = WakeWellTheme.background
        tableView.contentInset    = UIEdgeInsets(top: 8, left: 0, bottom: 32, right: 0)
        tableView.showsVerticalScrollIndicator = false

        // Apply horizontal card spacing via table layout margins
        tableView.layoutMargins        = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.cellLayoutMarginsFollowReadableWidth = false

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

    private func applyNavBar() {
        title = "Profile"
        navigationController?.navigationBar.prefersLargeTitles = true

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hex: "#F2F1FF")
        appearance.titleTextAttributes = [
            .foregroundColor: WakeWellTheme.labelPrimary
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: WakeWellTheme.labelPrimary,
            .font: UIFont.systemFont(ofSize: 32, weight: .bold)
        ]
        navigationController?.navigationBar.standardAppearance   = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = WakeWellTheme.accentPurple
    }
    private func loadProfile() {
        guard let profile = DatabaseManager.shared.fetchUserProfile() else {
            profileName = ""
            profileEmail = ""
            profileInitials = "?"
            profileMemberSince = ""
            for index in stats.indices {
                stats[index].value = "—"
            }
            return
        }

        profileName  = profile.firstName
        profileEmail = profile.email

        let parts = profile.firstName.split(separator: " ")
        profileInitials = parts.prefix(2).compactMap { $0.first }.map { String($0) }.joined()

        let df = DateFormatter(); df.dateStyle = .medium
        profileMemberSince = df.string(from: profile.createdAt)

        stats[0].value = timeFormatter.string(from: profile.wakeUpGoalTime)
        stats[1].value = String(format: "%.1f hours", profile.sleepGoalHours)
        stats[2].value = profile.biologicalSex
        stats[3].value = profile.ageRange
        stats[4].value = timeFormatter.string(from: profile.bedtimeGoal)
        stats[5].value = timeFormatter.string(from: profile.wakeTimeGoal)
        stats[6].value = profile.healthKitPermissionGranted ? "Granted" : "Not granted"
        stats[7].value = profile.watchStatus
        stats[8].value = profile.notificationPermissionGranted ? "Granted" : "Not granted"
        stats[9].value = profile.sleepDifficultyTypes.isEmpty ? "None selected" : profile.sleepDifficultyTypes.joined(separator: ", ")
        stats[10].value = profileMemberSince
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        ProfileSection.allCases.count
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        switch ProfileSection(rawValue: section)! {
        case .avatar:  return 1
        case .stats:   return stats.count
        case .actions: return 1
        }
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch ProfileSection(rawValue: indexPath.section)! {

        case .avatar:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: AvatarCell.reuseID, for: indexPath) as! AvatarCell
            styleCard(cell, isFirst: true, isLast: true)
            cell.configure(initials: profileInitials,
                           name: profileName,
                           email: profileEmail,
                           memberSince: profileMemberSince)
            return cell

        case .stats:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: DetailCell.reuseID, for: indexPath) as! DetailCell
            let isFirst = indexPath.row == 0
            let isLast  = indexPath.row == stats.count - 1
            styleCard(cell, isFirst: isFirst, isLast: isLast)

            // Separator between rows (not after last)
            if !isLast {
                addSeparator(to: cell.contentView)
            }

            let row = stats[indexPath.row]
            cell.configure(title: row.title, value: row.value, sfSymbol: row.sfSymbol)
            return cell

        case .actions:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ActionCell.reuseID, for: indexPath) as! ActionCell
            cell.configure(title: "Log Out", isDestructive: true)
            cell.onTap = { [weak self] in self?.confirmLogout() }
            return cell
        }
    }
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch ProfileSection(rawValue: indexPath.section)! {
        case .avatar:  return 130
        case .stats:   return 58
        case .actions: return 76
        }
    }

    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        guard let title = sectionTitle(for: section) else { return nil }
        let header = UIView()
        header.backgroundColor = .clear

        let label = UILabel()
        label.text      = title.uppercased()
        label.font      = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = WakeWellTheme.labelTertiary
        label.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 24),
            label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -6)
        ])
        return header
    }

    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        sectionTitle(for: section) == nil ? 12 : 36
    }

    override func tableView(_ tableView: UITableView,
                            heightForFooterInSection section: Int) -> CGFloat { 0 }

    override func tableView(_ tableView: UITableView,
                            viewForFooterInSection section: Int) -> UIView? { nil }

    private func sectionTitle(for section: Int) -> String? {
        switch ProfileSection(rawValue: section)! {
        case .avatar:  return nil
        case .stats:   return "Details"
        case .actions: return nil
        }
    }

    private var timeFormatter: DateFormatter {
        let df = DateFormatter()
        df.timeStyle = .short
        df.dateStyle = .none
        return df
    }
    private func styleCard(_ cell: UITableViewCell, isFirst: Bool, isLast: Bool) {
        cell.backgroundColor             = .clear
        cell.contentView.backgroundColor = WakeWellTheme.cardBackground
        var corners: CACornerMask = []
        if isFirst { corners.formUnion([.layerMinXMinYCorner, .layerMaxXMinYCorner]) }
        if isLast  { corners.formUnion([.layerMinXMaxYCorner, .layerMaxXMaxYCorner]) }

        cell.contentView.layer.cornerRadius  = isFirst || isLast ? 18 : 0
        cell.contentView.layer.maskedCorners = corners
        cell.contentView.layer.masksToBounds = true
        if isLast {
            cell.layer.masksToBounds    = false
            cell.layer.shadowColor      = WakeWellTheme.shadowColor.cgColor
            cell.layer.shadowOpacity    = WakeWellTheme.shadowOpacity
            cell.layer.shadowRadius     = WakeWellTheme.shadowRadius
            cell.layer.shadowOffset     = WakeWellTheme.shadowOffset
        } else {
            cell.layer.shadowOpacity = 0
        }
    }
    override func tableView(_ tableView: UITableView,
                            willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        // Use table's layoutMargins for consistent left/right card spacing (20 pt each side)
        let hInset = tableView.layoutMargins.left
        cell.contentView.frame = cell.contentView.frame.inset(
            by: UIEdgeInsets(top: 0, left: hInset, bottom: 0, right: hInset)
        )
    }

    private func addSeparator(to view: UIView) {
        // Remove any previous separator
        view.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }

        let sep = UIView()
        sep.tag             = 999
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
        UIView.transition(with: window, duration: 0.45,
                          options: .transitionFlipFromLeft,
                          animations: { window.rootViewController = onboarding })
    }
}
