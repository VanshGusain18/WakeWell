// LoginTableViewController.swift
// SetSail
//
// Handles Sign In and Create Account. Fully code-driven.

import UIKit

// MARK: - Models

private enum LoginMode {
    case signIn, register
}

private enum BiologicalSexOption: String, CaseIterable {
    case male = "Male"
    case female = "Female"
    case preferNotToSay = "Prefer not to say"
}

private enum AgeRangeOption: String, CaseIterable {
    case teens = "13-18"
    case youngAdult = "18-25"
    case adult = "26-35"
    case midLife = "36-50"
    case senior = "50+"
}

private enum SleepDifficultyOption: String, CaseIterable {
    case fallingAsleep = "Falling asleep"
    case wakingUp = "Waking up"
    case oversleeping = "Oversleeping"
    case lightSleep = "Light sleep"
    case irregularSchedule = "Irregular schedule"
    case stress = "Stress"
}

private enum SignInRow: Int, CaseIterable {
    case email, password
    var placeholder: String {
        switch self {
        case .email:    return "Email address"
        case .password: return "Password"
        }
    }
    var isSecure: Bool { self == .password }
    var keyboardType: UIKeyboardType { self == .email ? .emailAddress : .default }
    var sfSymbol: String {
        switch self {
        case .email:    return "envelope"
        case .password: return "lock"
        }
    }
}

private enum RegisterRow: Int, CaseIterable {
    case firstName
    case email
    case password
    case wakeUpGoalTime
    case sleepGoalDuration
    case healthKitPermissions
    case watchConnectivity
    case notificationPermission
    case biologicalSex
    case ageRange
    case bedtime
    case wakeTime
    case sleepDifficulty
}

// MARK: - View Controller

final class LoginTableViewController: UITableViewController {

    private var mode: LoginMode = .signIn {
        didSet { guard oldValue != mode else { return }; reloadForm() }
    }
    private var sleepGoal: Double = 8.0
    private var wakeUpGoalTime: Date = Date()
    private var bedtimeGoal: Date = Date()
    private var wakeTimeGoal: Date = Date()
    private var firstNameText = ""
    private var emailText    = ""
    private var passwordText = ""
    private var healthKitGranted = false
    private var notificationGranted = false
    private var watchStatusText = WatchConnectionMonitor.shared.displayStatus
    private var biologicalSex = BiologicalSexOption.preferNotToSay.rawValue
    private var ageRange = AgeRangeOption.youngAdult.rawValue
    private var selectedSleepDifficulties: Set<String> = []
    private var keyboardBottomInset: CGFloat = 40

    private weak var segmentCell: ModeSegmentCell?
    private weak var errorCell:   ErrorLabelCell?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        applyBackground()
        setupTableView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContentInsets()
        if let grad = view.layer.sublayers?.first as? CAGradientLayer {
            grad.frame = view.bounds
        }
    }

    // MARK: Setup

    private func applyBackground() {
        // Light gradient matching WakeWellTheme light palette — consistent with onboarding
        let grad = CAGradientLayer()
        grad.frame  = view.bounds
        grad.colors = [
            UIColor(hex: "#F2F1FF").cgColor,
            UIColor(hex: "#EAE8FF").cgColor,
            UIColor(hex: "#E0DEFF").cgColor
        ]
        grad.locations  = [0.0, 0.5, 1.0]
        grad.startPoint = CGPoint(x: 0.5, y: 0)
        grad.endPoint   = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(grad, at: 0)
        tableView.backgroundColor = WakeWellTheme.background
    }

    private func setupTableView() {
        tableView.register(HeaderCell.self,        forCellReuseIdentifier: HeaderCell.reuseID)
        tableView.register(ModeSegmentCell.self,   forCellReuseIdentifier: ModeSegmentCell.reuseID)
        tableView.register(FieldCell.self,          forCellReuseIdentifier: FieldCell.reuseID)
        tableView.register(SliderCell.self,         forCellReuseIdentifier: SliderCell.reuseID)
        tableView.register(TimePickerCell.self,     forCellReuseIdentifier: TimePickerCell.reuseID)
        tableView.register(StatusActionCell.self,   forCellReuseIdentifier: StatusActionCell.reuseID)
        tableView.register(ChoiceCell.self,         forCellReuseIdentifier: ChoiceCell.reuseID)
        tableView.register(MultiSelectCell.self,    forCellReuseIdentifier: MultiSelectCell.reuseID)
        tableView.register(PrimaryButtonCell.self,  forCellReuseIdentifier: PrimaryButtonCell.reuseID)
        tableView.register(ErrorLabelCell.self,     forCellReuseIdentifier: ErrorLabelCell.reuseID)

        tableView.separatorStyle              = .none
        tableView.allowsSelection             = true
        tableView.keyboardDismissMode         = .onDrag
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: DataSource

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        // header + segment + fields + button + error
        let fieldCount = mode == .signIn ? SignInRow.allCases.count : RegisterRow.allCases.count
        return 2 + fieldCount + 1 + 1
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row

        if row == 0 {
            return tableView.dequeueReusableCell(
                withIdentifier: HeaderCell.reuseID, for: indexPath)
        }

        if row == 1 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ModeSegmentCell.reuseID, for: indexPath) as! ModeSegmentCell
            cell.configure(selected: mode == .signIn ? 0 : 1)
            cell.onChange = { [weak self] idx in
                self?.mode = idx == 0 ? .signIn : .register
            }
            segmentCell = cell
            return cell
        }

        let fieldIndex = row - 2
        let fieldCount = mode == .signIn ? SignInRow.allCases.count : RegisterRow.allCases.count

        if fieldIndex < fieldCount {
            return mode == .signIn
                ? makeSignInFieldCell(for: indexPath, fieldIndex: fieldIndex)
                : makeRegisterCell(for: indexPath, rowIndex: fieldIndex)
        } else if fieldIndex == fieldCount {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PrimaryButtonCell.reuseID, for: indexPath) as! PrimaryButtonCell
            cell.configure(title: mode == .signIn ? "Sign In" : "Create Account")
            cell.onTap = { [weak self] btn in self?.submit(button: btn) }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ErrorLabelCell.reuseID, for: indexPath) as! ErrorLabelCell
            errorCell = cell
            return cell
        }
    }

    // MARK: Delegate

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        if row == 0 { return 140 }
        if row == 1 { return 60 }

        let fieldIndex = row - 2
        let fieldCount = mode == .signIn ? SignInRow.allCases.count : RegisterRow.allCases.count
        let isButton = fieldIndex == fieldCount
        let isError  = fieldIndex == fieldCount + 1

        if isButton { return 76 }
        if isError  { return 34 }

        if mode == .register, let r = RegisterRow(rawValue: fieldIndex) {
            switch r {
            case .sleepGoalDuration:
                return 84
            case .wakeUpGoalTime, .bedtime, .wakeTime:
                return 88
            case .healthKitPermissions, .watchConnectivity, .notificationPermission:
                return 72
            case .sleepDifficulty:
                return 184
            default:
                return 64
            }
        }
        return 64
    }

    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat { .leastNormalMagnitude }
    override func tableView(_ tableView: UITableView,
                            heightForFooterInSection section: Int) -> CGFloat { .leastNormalMagnitude }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        guard mode == .register else { return }
        guard let row = RegisterRow(rawValue: indexPath.row - 2) else { return }

        switch row {
        case .biologicalSex:
            presentChoiceSheet(
                title: "Biological Sex",
                options: BiologicalSexOption.allCases.map(\.rawValue),
                currentValue: biologicalSex
            ) { [weak self] choice in
                self?.biologicalSex = choice
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
        case .ageRange:
            presentChoiceSheet(
                title: "Age Range",
                options: AgeRangeOption.allCases.map(\.rawValue),
                currentValue: ageRange
            ) { [weak self] choice in
                self?.ageRange = choice
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
        default:
            break
        }
    }

    // MARK: Cell factories

    private func makeSignInFieldCell(for indexPath: IndexPath,
                                     fieldIndex: Int) -> UITableViewCell {
        let r = SignInRow(rawValue: fieldIndex)!
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FieldCell.reuseID, for: indexPath) as! FieldCell
        cell.configure(placeholder: r.placeholder, sfSymbol: r.sfSymbol,
                        isSecure: r.isSecure, keyboardType: r.keyboardType)
        cell.onChange = { [weak self] txt in
            if r == .email    { self?.emailText    = txt }
            if r == .password { self?.passwordText = txt }
        }
        return cell
    }

    private func makeRegisterCell(for indexPath: IndexPath, rowIndex: Int) -> UITableViewCell {
        let r = RegisterRow(rawValue: rowIndex)!
        switch r {
        case .firstName:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FieldCell.reuseID, for: indexPath) as! FieldCell
            cell.configure(placeholder: "First name", sfSymbol: "person",
                            isSecure: false, keyboardType: .default)
            cell.onChange = { [weak self] t in self?.firstNameText = t }
            return cell
        case .email:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FieldCell.reuseID, for: indexPath) as! FieldCell
            cell.configure(placeholder: "Email address", sfSymbol: "envelope",
                            isSecure: false, keyboardType: .emailAddress)
            cell.onChange = { [weak self] t in self?.emailText = t }
            return cell
        case .password:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FieldCell.reuseID, for: indexPath) as! FieldCell
            cell.configure(placeholder: "Password (≥ 6 chars)", sfSymbol: "lock",
                            isSecure: true, keyboardType: .default)
            cell.onChange = { [weak self] t in self?.passwordText = t }
            return cell
        case .wakeUpGoalTime:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TimePickerCell.reuseID, for: indexPath) as! TimePickerCell
            cell.configure(title: "Wake-up Goal Time", value: wakeUpGoalTime, icon: "alarm")
            cell.onChange = { [weak self] value in self?.wakeUpGoalTime = value }
            return cell
        case .sleepGoalDuration:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SliderCell.reuseID, for: indexPath) as! SliderCell
            cell.configure(title: "Sleep Goal Duration", value: Float(sleepGoal), icon: "moon.zzz")
            cell.onChange = { [weak self] val in
                self?.sleepGoal = Double(val).rounded(toPlaces: 1)
            }
            return cell
        case .healthKitPermissions:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: StatusActionCell.reuseID, for: indexPath) as! StatusActionCell
            cell.configure(title: "Apple Health Permissions",
                           detail: healthKitGranted ? "Granted" : "Not granted",
                           actionTitle: healthKitGranted ? "Granted" : "Request")
            cell.onAction = { [weak self, weak cell] in
                guard let self, let cell else { return }
                self.requestHealthKitPermissions(in: cell)
            }
            return cell
        case .watchConnectivity:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: StatusActionCell.reuseID, for: indexPath) as! StatusActionCell
            cell.configure(title: "Apple Watch Setup",
                           detail: watchStatusText,
                           actionTitle: "Refresh")
            cell.onAction = { [weak self, weak cell] in
                guard let self, let cell else { return }
                self.refreshWatchStatus(cell)
            }
            return cell
        case .notificationPermission:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: StatusActionCell.reuseID, for: indexPath) as! StatusActionCell
            cell.configure(title: "Notification Permission",
                           detail: notificationGranted ? "Granted" : "Not granted",
                           actionTitle: notificationGranted ? "Granted" : "Request")
            cell.onAction = { [weak self, weak cell] in
                guard let self, let cell else { return }
                self.requestNotificationPermission(in: cell)
            }
            return cell
        case .biologicalSex:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ChoiceCell.reuseID, for: indexPath) as! ChoiceCell
            cell.configure(title: "Biological Sex", value: biologicalSex, icon: "person.text.rectangle")
            return cell
        case .ageRange:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ChoiceCell.reuseID, for: indexPath) as! ChoiceCell
            cell.configure(title: "Age Range", value: ageRange, icon: "calendar")
            return cell
        case .bedtime:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TimePickerCell.reuseID, for: indexPath) as! TimePickerCell
            cell.configure(title: "Usual Bedtime", value: bedtimeGoal, icon: "moon.stars")
            cell.onChange = { [weak self] value in self?.bedtimeGoal = value }
            return cell
        case .wakeTime:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TimePickerCell.reuseID, for: indexPath) as! TimePickerCell
            cell.configure(title: "Usual Wake Time", value: wakeTimeGoal, icon: "sunrise")
            cell.onChange = { [weak self] value in self?.wakeTimeGoal = value }
            return cell
        case .sleepDifficulty:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: MultiSelectCell.reuseID, for: indexPath) as! MultiSelectCell
            cell.configure(
                title: "Sleep Difficulty Type",
                options: SleepDifficultyOption.allCases.map(\.rawValue),
                selected: selectedSleepDifficulties
            )
            cell.onChange = { [weak self] values in self?.selectedSleepDifficulties = values }
            return cell
        }
    }

    // MARK: Form logic

    private func reloadForm() {
        firstNameText = ""
        emailText = ""
        passwordText = ""
        wakeUpGoalTime = defaultTime(hour: 7, minute: 0)
        bedtimeGoal = defaultTime(hour: 22, minute: 30)
        wakeTimeGoal = defaultTime(hour: 7, minute: 0)
        sleepGoal = 8.0
        healthKitGranted = false
        notificationGranted = false
        watchStatusText = WatchConnectionMonitor.shared.displayStatus
        biologicalSex = BiologicalSexOption.preferNotToSay.rawValue
        ageRange = AgeRangeOption.youngAdult.rawValue
        selectedSleepDifficulties.removeAll()
        tableView.reloadData()
        updateContentInsets()
    }

    private func submit(button: UIButton) {
        view.endEditing(true)
        mode == .signIn ? handleSignIn(button: button) : handleRegister(button: button)
    }

    private func handleSignIn(button: UIButton) {
        guard !emailText.trimmingCharacters(in: .whitespaces).isEmpty,
              !passwordText.isEmpty
        else { showError("Please enter your email and password.", button: button); return }

        if DatabaseManager.shared.validateLogin(
            email: emailText.trimmingCharacters(in: .whitespaces),
            password: passwordText) {
            if let profile = DatabaseManager.shared.authenticateUser(
                email: emailText.trimmingCharacters(in: .whitespaces),
                password: passwordText
            ) {
                ProfileRepository.shared.signIn(model: profile)
            } else {
                UserDefaults.standard.set(true, forKey: "ww_logged_in")
            }
            navigateToMainApp()
        } else {
            showError("Invalid email or password.", button: button)
        }
    }

    private func handleRegister(button: UIButton) {
        let firstName  = firstNameText.trimmingCharacters(in: .whitespaces)
        let email = emailText.trimmingCharacters(in: .whitespaces)
        guard !firstName.isEmpty, !email.isEmpty,
              passwordText.count >= 6
        else { showError("Please fill all required fields. Password must be >= 6 chars.", button: button); return }

        requestHealthKitPermissions(in: button) { [weak self] healthGranted in
            guard let self else { return }
            self.requestNotificationPermission(in: button) { [weak self] notificationGranted in
                guard let self else { return }
                self.healthKitGranted = healthGranted
                self.notificationGranted = notificationGranted
                self.watchStatusText = WatchConnectionMonitor.shared.displayStatus

                let wakeUpDate = self.normalizedWakeTime(from: self.wakeUpGoalTime)
                let bedtimeDate = self.normalizedWakeTime(from: self.bedtimeGoal)
                let wakeTimeDate = self.normalizedWakeTime(from: self.wakeTimeGoal)

                let input = UserProfileInput(
                    authProvider: .email,
                    firstName: firstName,
                    email: email,
                    password: self.passwordText,
                    profilePhotoURL: nil,
                    wakeUpGoalTime: wakeUpDate,
                    sleepGoalHours: self.sleepGoal,
                    biologicalSex: self.biologicalSex,
                    ageRange: self.ageRange,
                    bedtimeGoal: bedtimeDate,
                    wakeTimeGoal: wakeTimeDate,
                    sleepDifficultyTypes: Array(self.selectedSleepDifficulties).sorted(),
                    healthKitPermissionGranted: healthGranted,
                    watchStatus: self.watchStatusText,
                    notificationPermissionGranted: notificationGranted
                )

                switch DatabaseManager.shared.insertUserProfile(input) {
                case .success(let userID):
                    if let profile = DatabaseManager.shared.fetchUserProfile(id: userID) {
                        ProfileRepository.shared.signIn(model: profile)
                    }
                case .failure(let error):
                    self.showError(error.localizedDescription, button: button)
                    return
                }

                UserDefaults.standard.set(wakeUpDate, forKey: "wakewell.savedAlarmTime")
                AlarmManager.shared.setAlarm(AlarmModel(time: wakeUpDate))
                self.navigateToMainApp()
            }
        }
    }

    private func navigateToMainApp() {
        guard let window = view.window else { return }
        let tabBar = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
        UIView.transition(with: window, duration: 0.45,
                          options: .transitionCrossDissolve,
                          animations: { window.rootViewController = tabBar })
    }

    private func showError(_ msg: String, button: UIButton) {
        errorCell?.show(message: msg)
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.duration = 0.38
        anim.values   = [-7, 7, -5, 5, -3, 3, 0]
        button.layer.add(anim, forKey: "shake")
    }

    // MARK: Keyboard

    @objc private func dismissKeyboard() { view.endEditing(true) }

    @objc private func keyboardWillShow(_ n: Notification) {
        guard let frame = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        keyboardBottomInset = frame.height + 20
        updateContentInsets()
    }

    @objc private func keyboardWillHide(_ n: Notification) {
        keyboardBottomInset = 40
        updateContentInsets()
    }

    private func updateContentInsets() {
        let available = tableView.bounds.height
        guard available > 0 else { return }
        let headerH: CGFloat = 140
        let segH: CGFloat    = 60
        let fieldH: CGFloat  = mode == .signIn
            ? CGFloat(SignInRow.allCases.count) * 64
            : registerContentHeight()
        let btnH: CGFloat = 76
        let errH: CGFloat = 34
        let total = headerH + segH + fieldH + btnH + errH
        let visible = max(0, available - keyboardBottomInset)
        let topInset = max(24, (visible - total) / 2)
        let inset = UIEdgeInsets(top: topInset, left: 0,
                                  bottom: topInset + keyboardBottomInset, right: 0)
        if tableView.contentInset != inset { tableView.contentInset = inset }
    }

    private func registerContentHeight() -> CGFloat {
        RegisterRow.allCases.reduce(0) { total, row in
            switch row {
            case .sleepGoalDuration:
                return total + 84
            case .wakeUpGoalTime, .bedtime, .wakeTime:
                return total + 88
            case .healthKitPermissions, .watchConnectivity, .notificationPermission:
                return total + 72
            case .sleepDifficulty:
                return total + 184
            default:
                return total + 64
            }
        }
    }

    private func defaultTime(hour: Int, minute: Int) -> Date {
        let cal = Calendar.current
        let now = Date()
        return cal.date(bySettingHour: hour, minute: minute, second: 0, of: now) ?? now
    }

    private func normalizedWakeTime(from date: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute], from: date)
        return cal.nextDate(
            after: Date(),
            matching: comps,
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .forward
        ) ?? date
    }

    private func presentChoiceSheet(title: String,
                                    options: [String],
                                    currentValue: String,
                                    onSelect: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        options.forEach { option in
            let style: UIAlertAction.Style = option == currentValue ? .default : .default
            let action = UIAlertAction(title: option, style: style) { _ in onSelect(option) }
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let pop = alert.popoverPresentationController {
            pop.sourceView = view
            pop.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        present(alert, animated: true)
    }

    private func refreshWatchStatus(_ cell: StatusActionCell) {
        watchStatusText = WatchConnectionMonitor.shared.displayStatus
        cell.configure(title: "Apple Watch Setup",
                       detail: watchStatusText,
                       actionTitle: "Refresh")
    }

    private func requestHealthKitPermissions(in cell: StatusActionCell,
                                             completion: ((Bool) -> Void)? = nil) {
        HealthKitManager.shared.requestAuthorization { [weak self] granted in
            self?.healthKitGranted = granted
            DispatchQueue.main.async {
                cell.configure(title: "Apple Health Permissions",
                               detail: granted ? "Granted" : "Not granted",
                               actionTitle: granted ? "Granted" : "Request")
                completion?(granted)
            }
        }
    }

    private func requestHealthKitPermissions(in button: UIButton,
                                             completion: ((Bool) -> Void)? = nil) {
        let tempCell = StatusActionCell(style: .default, reuseIdentifier: nil)
        requestHealthKitPermissions(in: tempCell) { granted in
            completion?(granted)
            button.isEnabled = true
        }
    }

    private func requestNotificationPermission(in cell: StatusActionCell,
                                               completion: ((Bool) -> Void)? = nil) {
        NotificationManager.shared.requestAuthorizationIfNeeded { [weak self] granted in
            self?.notificationGranted = granted
            DispatchQueue.main.async {
                cell.configure(title: "Notification Permission",
                               detail: granted ? "Granted" : "Not granted",
                               actionTitle: granted ? "Granted" : "Request")
                completion?(granted)
            }
        }
    }

    private func requestNotificationPermission(in button: UIButton,
                                               completion: ((Bool) -> Void)? = nil) {
        let tempCell = StatusActionCell(style: .default, reuseIdentifier: nil)
        requestNotificationPermission(in: tempCell) { granted in
            completion?(granted)
            button.isEnabled = true
        }
    }
}

// MARK: - HeaderCell

private final class HeaderCell: UITableViewCell {
    static let reuseID = "HeaderCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor             = .clear
        contentView.backgroundColor = .clear
        selectionStyle              = .none

        let logoImageView = UIImageView()
        if let logoImage = UIImage(named: "SetSailLogo") ?? UIImage(named: "AppIcon") {
            logoImageView.image = logoImage
        } else {
            // Fallback: styled badge with sailboat symbol if asset not found
            logoImageView.image = UIImage(systemName: "sailboat.fill")?
                .withTintColor(WakeWellTheme.accentPurple, renderingMode: .alwaysOriginal)
        }
        logoImageView.contentMode       = .scaleAspectFit
        logoImageView.layer.cornerRadius = 18
        logoImageView.clipsToBounds     = true
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        // Title
        let title = UILabel()
        title.text          = "SetSail"
        title.font          = .systemFont(ofSize: 32, weight: .bold)
        title.textColor     = WakeWellTheme.labelPrimary   // dark on light background
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(logoImageView)
        contentView.addSubview(title)

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 64),
            logoImageView.heightAnchor.constraint(equalToConstant: 64),

            title.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10),
            title.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ModeSegmentCell

private final class ModeSegmentCell: UITableViewCell {
    static let reuseID = "ModeSegmentCell"
    var onChange: ((Int) -> Void)?

    private let segment = UISegmentedControl(items: ["Sign In", "Create Account"])

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor             = .clear
        contentView.backgroundColor = .clear
        selectionStyle              = .none

        segment.selectedSegmentIndex    = 0
        segment.selectedSegmentTintColor = WakeWellTheme.accentPurple
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segment.setTitleTextAttributes([.foregroundColor: WakeWellTheme.labelSecondary], for: .normal)
        segment.backgroundColor = WakeWellTheme.cardBackground
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.addTarget(self, action: #selector(changed), for: .valueChanged)
        contentView.addSubview(segment)

        NSLayoutConstraint.activate([
            segment.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            segment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            segment.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            segment.heightAnchor.constraint(equalToConstant: 38)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(selected: Int) { segment.selectedSegmentIndex = selected }
    @objc private func changed() { onChange?(segment.selectedSegmentIndex) }
}

// MARK: - FieldCell

private final class FieldCell: UITableViewCell {
    static let reuseID = "FieldCell"
    var onChange: ((String) -> Void)?

    private let containerView = UIView()
    private let iconView      = UIImageView()
    private let field         = UITextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor             = .clear
        contentView.backgroundColor = .clear
        selectionStyle              = .none

        // Container card
        containerView.backgroundColor    = WakeWellTheme.cardBackground
        containerView.layer.cornerRadius = 14
        containerView.layer.borderWidth  = 1
        containerView.layer.borderColor  = WakeWellTheme.border.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // Icon
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor   = WakeWellTheme.accentPurple
        iconView.translatesAutoresizingMaskIntoConstraints = false

        // Text field
        field.textColor           = WakeWellTheme.labelPrimary
        field.tintColor           = WakeWellTheme.accentPurple
        field.font                = .systemFont(ofSize: 15, weight: .regular)
        field.autocapitalizationType = .none
        field.autocorrectionType  = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        field.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        containerView.addSubview(iconView)
        containerView.addSubview(field)
        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 50),

            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            field.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            field.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            field.topAnchor.constraint(equalTo: containerView.topAnchor),
            field.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(placeholder: String, sfSymbol: String,
                   isSecure: Bool, keyboardType: UIKeyboardType) {
        field.isSecureTextEntry  = isSecure
        field.keyboardType       = keyboardType
        field.text               = ""
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: WakeWellTheme.labelTertiary])
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        iconView.image = UIImage(systemName: sfSymbol, withConfiguration: cfg)
    }

    @objc private func textChanged() { onChange?(field.text ?? "") }
}

// MARK: - SliderCell

private final class SliderCell: UITableViewCell {
    static let reuseID = "SliderCell"
    var onChange: ((Float) -> Void)?

    private let iconView = UIImageView()
    private let label  = UILabel()
    private let valueLabel = UILabel()
    private let slider = UISlider()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor             = .clear
        contentView.backgroundColor = .clear
        selectionStyle              = .none

        label.text      = "Sleep Goal"
        label.textColor = WakeWellTheme.labelSecondary
        label.font      = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.textColor = WakeWellTheme.accentPurple
        valueLabel.font      = .systemFont(ofSize: 12, weight: .semibold)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        iconView.tintColor = WakeWellTheme.accentPurple
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        slider.minimumValue          = 4
        slider.maximumValue          = 12
        slider.minimumTrackTintColor = WakeWellTheme.accentGold
        slider.maximumTrackTintColor = WakeWellTheme.border
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

        contentView.addSubview(iconView)
        contentView.addSubview(label)
        contentView.addSubview(valueLabel)
        contentView.addSubview(slider)
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 11),
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            label.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(lessThanOrEqualTo: valueLabel.leadingAnchor, constant: -8),

            valueLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            slider.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            slider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            slider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, value: Float, icon: String) {
        label.text = title
        iconView.image = UIImage(systemName: icon)
        slider.value   = value
        valueLabel.text = String(format: "%.1f hrs", value)
    }

    @objc private func sliderChanged() {
        valueLabel.text = String(format: "%.1f hrs", slider.value)
        onChange?(slider.value)
    }
}

// MARK: - TimePickerCell

private final class TimePickerCell: UITableViewCell {
    static let reuseID = "TimePickerCell"
    var onChange: ((Date) -> Void)?

    private let containerView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let spacerView = UIView()
    private let titleStack = UIStackView()
    private let rowStack = UIStackView()
    private let timePicker = UIDatePicker()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        containerView.backgroundColor = WakeWellTheme.cardBackground
        containerView.layer.cornerRadius = 14
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = WakeWellTheme.border.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false

        iconView.tintColor = WakeWellTheme.accentPurple
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = WakeWellTheme.labelPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        timePicker.datePickerMode = .time
        if #available(iOS 14.0, *) {
            timePicker.preferredDatePickerStyle = .compact
        }
        timePicker.locale = Locale.current
        timePicker.tintColor = WakeWellTheme.accentPurple
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.setContentCompressionResistancePriority(.required, for: .horizontal)
        timePicker.setContentHuggingPriority(.required, for: .horizontal)
        timePicker.addTarget(self, action: #selector(changed), for: .valueChanged)

        titleStack.axis = .horizontal
        titleStack.alignment = .center
        titleStack.spacing = 8
        titleStack.translatesAutoresizingMaskIntoConstraints = false

        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.spacing = 12
        rowStack.translatesAutoresizingMaskIntoConstraints = false

        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        titleStack.addArrangedSubview(iconView)
        titleStack.addArrangedSubview(titleLabel)
        rowStack.addArrangedSubview(titleStack)
        rowStack.addArrangedSubview(spacerView)
        rowStack.addArrangedSubview(timePicker)

        containerView.addSubview(rowStack)
        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            rowStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            rowStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            rowStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            rowStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),

            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, value: Date, icon: String) {
        titleLabel.text = title
        iconView.image = UIImage(systemName: icon)
        timePicker.date = value
    }

    @objc private func changed() {
        onChange?(timePicker.date)
    }
}

// MARK: - StatusActionCell

private final class StatusActionCell: UITableViewCell {
    static let reuseID = "StatusActionCell"
    var onAction: (() -> Void)?

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let actionButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        containerView.backgroundColor = WakeWellTheme.cardBackground
        containerView.layer.cornerRadius = 14
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = WakeWellTheme.border.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = WakeWellTheme.labelPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        detailLabel.font = .systemFont(ofSize: 12)
        detailLabel.textColor = WakeWellTheme.labelSecondary
        detailLabel.translatesAutoresizingMaskIntoConstraints = false

        actionButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        actionButton.setTitleColor(WakeWellTheme.accentPurple, for: .normal)
        actionButton.setTitleColor(WakeWellTheme.labelTertiary, for: .disabled)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(stack)
        containerView.addSubview(actionButton)
        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),

            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            stack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -12),

            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            actionButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, detail: String, actionTitle: String) {
        titleLabel.text = title
        detailLabel.text = detail
        actionButton.setTitle(actionTitle, for: .normal)
    }

    @objc private func actionTapped() {
        onAction?()
    }
}

// MARK: - ChoiceCell

private final class ChoiceCell: UITableViewCell {
    static let reuseID = "ChoiceCell"

    private let containerView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevronView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .default

        containerView.backgroundColor = WakeWellTheme.cardBackground
        containerView.layer.cornerRadius = 14
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = WakeWellTheme.border.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false

        iconView.tintColor = WakeWellTheme.accentPurple
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = WakeWellTheme.labelPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        valueLabel.font = .systemFont(ofSize: 12)
        valueLabel.textColor = WakeWellTheme.labelSecondary
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        chevronView.image = UIImage(systemName: "chevron.right")
        chevronView.tintColor = WakeWellTheme.labelTertiary
        chevronView.contentMode = .scaleAspectFit
        chevronView.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(iconView)
        containerView.addSubview(stack)
        containerView.addSubview(chevronView)
        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),

            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            stack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            stack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            chevronView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            chevronView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 12),
            chevronView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, value: String, icon: String) {
        titleLabel.text = title
        valueLabel.text = value
        iconView.image = UIImage(systemName: icon)
    }
}

// MARK: - MultiSelectCell

private final class MultiSelectCell: UITableViewCell {
    static let reuseID = "MultiSelectCell"
    var onChange: ((Set<String>) -> Void)?

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let chipsContainerView = UIView()
    private var options: [String] = []
    private var selectedValues: Set<String> = []
    private var buttons: [UIButton] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        containerView.backgroundColor = WakeWellTheme.cardBackground
        containerView.layer.cornerRadius = 14
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = WakeWellTheme.border.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = WakeWellTheme.labelPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 1

        chipsContainerView.translatesAutoresizingMaskIntoConstraints = false
        chipsContainerView.clipsToBounds = false

        containerView.addSubview(titleLabel)
        containerView.addSubview(chipsContainerView)
        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),

            chipsContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            chipsContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            chipsContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            chipsContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, options: [String], selected: Set<String>) {
        self.options = options
        self.selectedValues = selected
        titleLabel.text = title
        rebuildButtons()
    }

    private func rebuildButtons() {
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()

        for (index, option) in options.enumerated() {
            let button = UIButton(type: .system)
            var configuration = UIButton.Configuration.plain()
            var title = AttributedString(option)
            title.font = .systemFont(ofSize: 12, weight: .semibold)
            configuration.attributedTitle = title
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
            button.tag = index
            button.configuration = configuration
            button.layer.cornerRadius = 12
            button.contentHorizontalAlignment = .center
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.addTarget(self, action: #selector(toggleOption(_:)), for: .touchUpInside)
            chipsContainerView.addSubview(button)
            buttons.append(button)
            style(button, selected: selectedValues.contains(option))
        }
        setNeedsLayout()
    }

    private func style(_ button: UIButton, selected: Bool) {
        var configuration = button.configuration ?? .plain()
        configuration.baseForegroundColor = selected ? WakeWellTheme.accentPurple : WakeWellTheme.labelPrimary
        button.configuration = configuration
        button.backgroundColor = selected ? WakeWellTheme.purpleTint : WakeWellTheme.background
        button.layer.borderWidth = 1
        button.layer.borderColor = (selected ? WakeWellTheme.accentPurple : WakeWellTheme.border).cgColor
    }

    @objc private func toggleOption(_ sender: UIButton) {
        let option = options[sender.tag]
        if selectedValues.contains(option) {
            selectedValues.remove(option)
        } else {
            selectedValues.insert(option)
        }
        style(sender, selected: selectedValues.contains(option))
        onChange?(selectedValues)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutChips()
    }

    private func layoutChips() {
        let availableWidth = chipsContainerView.bounds.width
        guard availableWidth > 0 else { return }

        let horizontalSpacing: CGFloat = 8
        let verticalSpacing: CGFloat = 8
        let chipHeight: CGFloat = 34
        var x: CGFloat = 0
        var y: CGFloat = 0

        for button in buttons {
            let fittingSize = button.sizeThatFits(CGSize(width: availableWidth, height: chipHeight))
            let chipWidth = min(fittingSize.width, availableWidth)

            if x > 0, x + chipWidth > availableWidth {
                x = 0
                y += chipHeight + verticalSpacing
            }

            button.frame = CGRect(x: x, y: y, width: chipWidth, height: chipHeight)
            x += chipWidth + horizontalSpacing
        }
    }
}

// MARK: - PrimaryButtonCell

private final class PrimaryButtonCell: UITableViewCell {
    static let reuseID = "PrimaryButtonCell"
    var onTap: ((UIButton) -> Void)?

    private let button = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor             = .clear
        contentView.backgroundColor = .clear
        selectionStyle              = .none

        button.backgroundColor      = WakeWellTheme.accentGold
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font     = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius   = 26
        button.clipsToBounds        = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        contentView.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            button.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String) { button.setTitle(title, for: .normal) }
    @objc private func tapped() { onTap?(button) }
}

// MARK: - ErrorLabelCell

private final class ErrorLabelCell: UITableViewCell {
    static let reuseID = "ErrorLabelCell"

    private let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor             = .clear
        contentView.backgroundColor = .clear
        selectionStyle              = .none

        label.textColor     = UIColor(hex: "#FF6B6B")
        label.font          = .systemFont(ofSize: 13)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha         = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func show(message: String) {
        label.text  = message
        label.alpha = 0
        UIView.animate(withDuration: 0.25) { self.label.alpha = 1 }
    }
}

// MARK: - Double rounding

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
