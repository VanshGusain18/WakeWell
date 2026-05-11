// LoginTableViewController.swift
// SetSail
//
// Handles Sign In and Create Account. Fully code-driven.

import UIKit

// MARK: - Models

private enum LoginMode {
    case signIn, register
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
    case name, email, password, age, sleepGoal
}

// MARK: - View Controller

final class LoginTableViewController: UITableViewController {

    private var mode: LoginMode = .signIn {
        didSet { guard oldValue != mode else { return }; reloadForm() }
    }
    private var sleepGoal: Double = 8.0
    private var keyboardBottomInset: CGFloat = 40

    private weak var segmentCell: ModeSegmentCell?
    private weak var errorCell:   ErrorLabelCell?

    private var nameText     = ""
    private var emailText    = ""
    private var passwordText = ""
    private var ageText      = ""

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
        tableView.register(PrimaryButtonCell.self,  forCellReuseIdentifier: PrimaryButtonCell.reuseID)
        tableView.register(ErrorLabelCell.self,     forCellReuseIdentifier: ErrorLabelCell.reuseID)

        tableView.separatorStyle              = .none
        tableView.allowsSelection             = false
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
            if r == .sleepGoal { return 84 }
        }
        return 64
    }

    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat { .leastNormalMagnitude }
    override func tableView(_ tableView: UITableView,
                            heightForFooterInSection section: Int) -> CGFloat { .leastNormalMagnitude }

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
        case .name:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FieldCell.reuseID, for: indexPath) as! FieldCell
            cell.configure(placeholder: "Full name", sfSymbol: "person",
                            isSecure: false, keyboardType: .default)
            cell.onChange = { [weak self] t in self?.nameText = t }
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
        case .age:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: FieldCell.reuseID, for: indexPath) as! FieldCell
            cell.configure(placeholder: "Age", sfSymbol: "calendar",
                            isSecure: false, keyboardType: .numberPad)
            cell.onChange = { [weak self] t in self?.ageText = t }
            return cell
        case .sleepGoal:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SliderCell.reuseID, for: indexPath) as! SliderCell
            cell.configure(value: Float(sleepGoal))
            cell.onChange = { [weak self] val in
                self?.sleepGoal = Double(val).rounded(toPlaces: 1)
            }
            return cell
        }
    }

    // MARK: Form logic

    private func reloadForm() {
        nameText = ""; emailText = ""; passwordText = ""; ageText = ""
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
            UserDefaults.standard.set(true, forKey: "ww_logged_in")
            navigateToMainApp()
        } else {
            showError("Invalid email or password.", button: button)
        }
    }

    private func handleRegister(button: UIButton) {
        let name  = nameText.trimmingCharacters(in: .whitespaces)
        let email = emailText.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, !email.isEmpty,
              passwordText.count >= 6,
              let age = Int(ageText), age > 0
        else { showError("Please fill all fields. Password must be ≥ 6 chars.", button: button); return }

        let genderOptions = ["male", "female", "other"]
        switch DatabaseManager.shared.insertUserProfile(
            name: name, email: email, password: passwordText,
            age: age, gender: genderOptions[0], sleepGoalHours: sleepGoal) {
        case .success:
            break
        case .failure(let error):
            showError(error.localizedDescription, button: button)
            return
        }

        UserDefaults.standard.set(true, forKey: "ww_logged_in")
        navigateToMainApp()
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
            : CGFloat(RegisterRow.allCases.count - 1) * 64 + 84
        let btnH: CGFloat = 76
        let errH: CGFloat = 34
        let total = headerH + segH + fieldH + btnH + errH
        let visible = max(0, available - keyboardBottomInset)
        let topInset = max(24, (visible - total) / 2)
        let inset = UIEdgeInsets(top: topInset, left: 0,
                                  bottom: topInset + keyboardBottomInset, right: 0)
        if tableView.contentInset != inset { tableView.contentInset = inset }
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

        slider.minimumValue          = 4
        slider.maximumValue          = 12
        slider.minimumTrackTintColor = WakeWellTheme.accentGold
        slider.maximumTrackTintColor = WakeWellTheme.border
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

        contentView.addSubview(label)
        contentView.addSubview(valueLabel)
        contentView.addSubview(slider)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            valueLabel.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            slider.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            slider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            slider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(value: Float) {
        slider.value   = value
        valueLabel.text = String(format: "%.1f hrs", value)
    }

    @objc private func sliderChanged() {
        valueLabel.text = String(format: "%.1f hrs", slider.value)
        onChange?(slider.value)
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
