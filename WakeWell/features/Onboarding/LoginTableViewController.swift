// LoginTableViewController.swift
// WakeWell
//
// Handles Sign In and Create Account in a UITableViewController.
// Replaces LoginViewController + LoginView.xib.
// No IBOutlets — fully code-driven.

import UIKit

// MARK: - Section / Row models

private enum LoginMode {
    case signIn, register
}

private enum SignInRow: Int, CaseIterable {
    case email, password
    var placeholder: String {
        switch self {
        case .email:    return "Email"
        case .password: return "Password"
        }
    }
    var isSecure: Bool { self == .password }
    var keyboardType: UIKeyboardType { self == .email ? .emailAddress : .default }
}

private enum RegisterRow: Int, CaseIterable {
    case name, email, password, age, gender, sleepGoal
}

// MARK: - View Controller

final class LoginTableViewController: UITableViewController {

    // MARK: Private state

    private var mode: LoginMode = .signIn {
        didSet { guard oldValue != mode else { return }; reloadForm() }
    }
    private var sleepGoal: Double = 8.0

    // Live cell refs (weak — table recycles)
    private weak var segmentCell: ModeSegmentCell?
    private weak var errorCell:   ErrorCell?

    // Field values (captured from cells before submission)
    private var nameText     = ""
    private var emailText    = ""
    private var passwordText = ""
    private var ageText      = ""
    private var genderIndex  = 0

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        applyGradientBackground()
        setupTableView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let grad = view.layer.sublayers?.first as? CAGradientLayer {
            grad.frame = view.bounds
        }
    }

    // MARK: Setup

    private func applyGradientBackground() {
        let grad = CAGradientLayer()
        grad.frame  = view.bounds
        grad.colors = [
            UIColor(hex: "#1C1A3A").cgColor,
            UIColor(hex: "#2D2B55").cgColor
        ]
        grad.startPoint = .zero
        grad.endPoint   = CGPoint(x: 0, y: 1)
        view.layer.insertSublayer(grad, at: 0)
        tableView.backgroundColor = .clear
    }

    private func setupTableView() {
        tableView.register(ModeSegmentCell.self,  forCellReuseIdentifier: ModeSegmentCell.reuseID)
        tableView.register(FieldCell.self,         forCellReuseIdentifier: FieldCell.reuseID)
        tableView.register(GenderCell.self,        forCellReuseIdentifier: GenderCell.reuseID)
        tableView.register(SliderCell.self,        forCellReuseIdentifier: SliderCell.reuseID)
        tableView.register(PrimaryButtonCell.self, forCellReuseIdentifier: PrimaryButtonCell.reuseID)
        tableView.register(ErrorCell.self,         forCellReuseIdentifier: ErrorCell.reuseID)

        tableView.separatorStyle  = .none
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 40, right: 0)
        tableView.showsVerticalScrollIndicator = false

        // Tap to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // Keyboard avoidance
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        // mode segment + fields + button + error
        switch mode {
        case .signIn:   return 1 + SignInRow.allCases.count + 1 + 1
        case .register: return 1 + RegisterRow.allCases.count + 1 + 1
        }
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row

        // Row 0 — mode switcher
        if row == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ModeSegmentCell.reuseID, for: indexPath) as! ModeSegmentCell
            cell.configure(selected: mode == .signIn ? 0 : 1)
            cell.onChange = { [weak self] idx in
                self?.mode = idx == 0 ? .signIn : .register
            }
            segmentCell = cell
            return cell
        }

        let fieldIndex = row - 1

        switch mode {
        case .signIn:
            let signInRowCount = SignInRow.allCases.count
            if fieldIndex < signInRowCount {
                let r = SignInRow(rawValue: fieldIndex)!
                return makeFieldCell(for: indexPath,
                                     placeholder: r.placeholder,
                                     isSecure: r.isSecure,
                                     keyboardType: r.keyboardType,
                                     tag: fieldIndex,
                                     onChange: { [weak self] txt in
                    if r == .email    { self?.emailText    = txt }
                    if r == .password { self?.passwordText = txt }
                })
            } else if fieldIndex == signInRowCount {
                return makePrimaryButtonCell(for: indexPath)
            } else {
                return makeErrorCell(for: indexPath)
            }

        case .register:
            if fieldIndex < RegisterRow.allCases.count {
                return makeRegisterCell(for: indexPath, rowIndex: fieldIndex)
            } else if fieldIndex == RegisterRow.allCases.count {
                return makePrimaryButtonCell(for: indexPath)
            } else {
                return makeErrorCell(for: indexPath)
            }
        }
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        if row == 0 { return 64 }

        let fieldIndex = row - 1
        let totalFields = mode == .signIn ? SignInRow.allCases.count : RegisterRow.allCases.count
        let isButtonRow = fieldIndex == totalFields
        let isErrorRow  = fieldIndex == totalFields + 1

        if isButtonRow { return 72 }
        if isErrorRow  { return 36 }

        if mode == .register, let r = RegisterRow(rawValue: fieldIndex) {
            if r == .gender    { return 72 }
            if r == .sleepGoal { return 80 }
        }
        return 60
    }

    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat { .leastNormalMagnitude }
    override func tableView(_ tableView: UITableView,
                            heightForFooterInSection section: Int) -> CGFloat { .leastNormalMagnitude }

    // MARK: Cell factories

    private func makeFieldCell(for indexPath: IndexPath,
                                placeholder: String,
                                isSecure: Bool,
                                keyboardType: UIKeyboardType,
                                tag: Int,
                                onChange: @escaping (String) -> Void) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: FieldCell.reuseID, for: indexPath) as! FieldCell
        cell.configure(placeholder: placeholder, isSecure: isSecure,
                        keyboardType: keyboardType, tag: tag)
        cell.onChange = onChange
        return cell
    }

    private func makeRegisterCell(for indexPath: IndexPath,
                                   rowIndex: Int) -> UITableViewCell {
        let r = RegisterRow(rawValue: rowIndex)!
        switch r {
        case .name:
            return makeFieldCell(for: indexPath, placeholder: "Full Name",
                                  isSecure: false, keyboardType: .default, tag: rowIndex,
                                  onChange: { [weak self] t in self?.nameText = t })
        case .email:
            return makeFieldCell(for: indexPath, placeholder: "Email",
                                  isSecure: false, keyboardType: .emailAddress, tag: rowIndex,
                                  onChange: { [weak self] t in self?.emailText = t })
        case .password:
            return makeFieldCell(for: indexPath, placeholder: "Password (≥ 6 chars)",
                                  isSecure: true, keyboardType: .default, tag: rowIndex,
                                  onChange: { [weak self] t in self?.passwordText = t })
        case .age:
            return makeFieldCell(for: indexPath, placeholder: "Age",
                                  isSecure: false, keyboardType: .numberPad, tag: rowIndex,
                                  onChange: { [weak self] t in self?.ageText = t })
        case .gender:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: GenderCell.reuseID, for: indexPath) as! GenderCell
            cell.configure(selected: genderIndex)
            cell.onChange = { [weak self] idx in self?.genderIndex = idx }
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

    private func makePrimaryButtonCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: PrimaryButtonCell.reuseID, for: indexPath) as! PrimaryButtonCell
        cell.configure(title: mode == .signIn ? "Sign In" : "Create Account")
        cell.onTap = { [weak self] btn in self?.submit(button: btn) }
        return cell
    }

    private func makeErrorCell(for indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ErrorCell.reuseID, for: indexPath) as! ErrorCell
        errorCell = cell
        return cell
    }

    // MARK: Form logic

    private func reloadForm() {
        // Reset captured text
        nameText = ""; emailText = ""; passwordText = ""; ageText = ""; genderIndex = 0
        tableView.reloadData()
    }

    private func submit(button: UIButton) {
        view.endEditing(true)
        mode == .signIn ? handleSignIn(button: button) : handleRegister(button: button)
    }

    private func handleSignIn(button: UIButton) {
        guard !emailText.trimmingCharacters(in: .whitespaces).isEmpty,
              !passwordText.isEmpty
        else { showError("Please enter email and password.", button: button); return }

        if DatabaseManager.shared.validateLogin(email: emailText.trimmingCharacters(in: .whitespaces),
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
        else {
            showError("Please fill all fields. Password must be ≥ 6 characters.", button: button)
            return
        }

        let genderOptions = ["male", "female", "other"]
        let gender = genderOptions[genderIndex]

        guard DatabaseManager.shared.insertUserProfile(
            name: name, email: email, password: passwordText,
            age: age, gender: gender, sleepGoalHours: sleepGoal) != nil
        else {
            showError("An account with this email already exists.", button: button)
            return
        }

        UserDefaults.standard.set(true, forKey: "ww_logged_in")
        navigateToMainApp()
    }

    private func navigateToMainApp() {
        guard let window = view.window else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBar = storyboard.instantiateInitialViewController()!
        UIView.transition(with: window, duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { window.rootViewController = tabBar })
    }

    private func showError(_ msg: String, button: UIButton) {
        errorCell?.show(message: msg)
        // Shake button
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.duration = 0.4
        anim.values   = [-8, 8, -6, 6, -4, 4, 0]
        button.layer.add(anim, forKey: "shake")
    }

    // MARK: Keyboard

    @objc private func dismissKeyboard() { view.endEditing(true) }

    @objc private func keyboardWillShow(_ n: Notification) {
        guard let frame = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        tableView.contentInset.bottom = frame.height + 20
        tableView.scrollIndicatorInsets.bottom = frame.height
    }

    @objc private func keyboardWillHide(_ n: Notification) {
        tableView.contentInset.bottom = 40
        tableView.scrollIndicatorInsets.bottom = 0
    }
}

// MARK: - ModeSegmentCell

private final class ModeSegmentCell: UITableViewCell {
    static let reuseID = "ModeSegmentCell"
    var onChange: ((Int) -> Void)?

    private let segment = UISegmentedControl(items: ["Sign In", "Create Account"])

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle  = .none

        segment.selectedSegmentTintColor = WakeWellTheme.accentPurple
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segment.setTitleTextAttributes([.foregroundColor: WakeWellTheme.labelSecondary], for: .normal)
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.addTarget(self, action: #selector(changed), for: .valueChanged)
        contentView.addSubview(segment)

        NSLayoutConstraint.activate([
            segment.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            segment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            segment.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
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

    private let field = UITextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle  = .none

        field.backgroundColor    = WakeWellTheme.cardBackground.withAlphaComponent(0.5)
        field.textColor          = WakeWellTheme.labelPrimary
        field.tintColor          = WakeWellTheme.accentPurple
        field.layer.cornerRadius = 12
        field.layer.borderWidth  = 1
        field.layer.borderColor  = WakeWellTheme.border.cgColor
        field.leftView           = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        field.leftViewMode       = .always
        field.rightView          = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 1))
        field.rightViewMode      = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        field.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        contentView.addSubview(field)

        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            field.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            field.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            field.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(placeholder: String, isSecure: Bool, keyboardType: UIKeyboardType, tag: Int) {
        field.isSecureTextEntry  = isSecure
        field.keyboardType       = keyboardType
        field.tag                = tag
        field.text               = ""
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: WakeWellTheme.labelTertiary])
    }

    @objc private func textChanged() { onChange?(field.text ?? "") }
}

// MARK: - GenderCell

private final class GenderCell: UITableViewCell {
    static let reuseID = "GenderCell"
    var onChange: ((Int) -> Void)?

    private let label   = UILabel()
    private let segment = UISegmentedControl(items: ["Male", "Female", "Other"])

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle  = .none

        label.text      = "Gender"
        label.textColor = WakeWellTheme.labelSecondary
        label.font      = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false

        segment.selectedSegmentIndex    = 0
        segment.selectedSegmentTintColor = WakeWellTheme.accentGold
        segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segment.setTitleTextAttributes([.foregroundColor: WakeWellTheme.labelSecondary], for: .normal)
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.addTarget(self, action: #selector(changed), for: .valueChanged)

        contentView.addSubview(label)
        contentView.addSubview(segment)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            segment.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 6),
            segment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            segment.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(selected: Int) { segment.selectedSegmentIndex = selected }
    @objc private func changed() { onChange?(segment.selectedSegmentIndex) }
}

// MARK: - SliderCell

private final class SliderCell: UITableViewCell {
    static let reuseID = "SliderCell"
    var onChange: ((Float) -> Void)?

    private let label  = UILabel()
    private let slider = UISlider()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle  = .none

        label.textColor = WakeWellTheme.labelSecondary
        label.font      = .systemFont(ofSize: 13, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false

        slider.minimumValue      = 4
        slider.maximumValue      = 12
        slider.minimumTrackTintColor = WakeWellTheme.accentGold
        slider.maximumTrackTintColor = WakeWellTheme.labelTertiary
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

        contentView.addSubview(label)
        contentView.addSubview(slider)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            slider.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            slider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            slider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(value: Float) {
        slider.value = value
        label.text   = String(format: "Sleep Goal: %.1f hrs", value)
    }

    @objc private func sliderChanged() {
        label.text = String(format: "Sleep Goal: %.1f hrs", slider.value)
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
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle  = .none

        WakeWellTheme.stylePrimaryButton(button, cornerRadius: 26)
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

// MARK: - ErrorCell

private final class ErrorCell: UITableViewCell {
    static let reuseID = "ErrorCell"

    private let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle  = .none

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

// MARK: - Double rounding helper

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
