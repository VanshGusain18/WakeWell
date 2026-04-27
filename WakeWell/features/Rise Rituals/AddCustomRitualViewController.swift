// AddCustomRitualViewController.swift — SetSail
// Clean form to add a personal ritual to the activity library.
// Replaces the original AddActivityViewController (which had storyboard outlets).
// Works entirely programmatically — no XIB / storyboard needed.

import UIKit

class AddCustomRitualViewController: UIViewController, UITextViewDelegate {

    var onSave: (() -> Void)?

    // MARK: - UI
    private let scrollView      = UIScrollView()
    private let stack           = UIStackView()

    private let titleField      = UITextField()
    private let categoryButton  = UIButton(type: .system)
    private let descView        = UITextView()
    private let stepsView       = UITextView()
    private let durationButton  = UIButton(type: .system)

    private var selectedCategory = "Custom"
    private var selectedDuration: Int? = nil

    private let categories = ["Energy", "Calm", "Physical", "Alertness", "Mindset", "Custom"]
    private let durations  = [30, 60, 120, 300, 600, 900]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Ritual"
        view.backgroundColor = WakeWellTheme.background

        navigationItem.leftBarButtonItem  = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save", style: .done, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem?.tintColor = WakeWellTheme.accentGold

        buildUI()
        setupMenus()
    }

    // MARK: - Layout

    private func buildUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)

        stack.axis      = .vertical
        stack.spacing   = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32)
        ])

        // Title
        stack.addArrangedSubview(sectionLabel("Activity Title"))
        styleTextField(titleField, placeholder: "e.g. Morning Stretch")
        stack.addArrangedSubview(titleField)

        // Category
        stack.addArrangedSubview(sectionLabel("Category"))
        stylePickerButton(categoryButton, placeholder: "Select category")
        stack.addArrangedSubview(categoryButton)

        // Description
        stack.addArrangedSubview(sectionLabel("Description"))
        styleTextView(descView, placeholder: "What is this activity and why does it help?")
        descView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        stack.addArrangedSubview(descView)

        // Steps
        stack.addArrangedSubview(sectionLabel("Steps (one per line)"))
        styleTextView(stepsView, placeholder: "Step 1\nStep 2\nStep 3")
        stepsView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        stack.addArrangedSubview(stepsView)

        // Duration
        stack.addArrangedSubview(sectionLabel("Duration (optional)"))
        stylePickerButton(durationButton, placeholder: "Select duration")
        stack.addArrangedSubview(durationButton)
    }

    // MARK: - Styling helpers

    private func sectionLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text      = text
        l.font      = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = WakeWellTheme.labelSecondary
        return l
    }

    private func styleTextField(_ f: UITextField, placeholder: String) {
        f.placeholder   = placeholder
        f.font          = .systemFont(ofSize: 16)
        f.textColor     = WakeWellTheme.labelPrimary
        f.backgroundColor   = WakeWellTheme.cardBackground
        f.layer.cornerRadius = 14
        f.layer.borderWidth  = 0.5
        f.layer.borderColor  = WakeWellTheme.border.cgColor
        f.leftView      = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        f.leftViewMode  = .always
        f.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    private func stylePickerButton(_ btn: UIButton, placeholder: String) {
        btn.setTitle(placeholder, for: .normal)
        btn.setTitleColor(WakeWellTheme.labelTertiary, for: .normal)
        btn.titleLabel?.font    = .systemFont(ofSize: 16)
        btn.contentHorizontalAlignment = .left
        btn.contentEdgeInsets   = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        btn.backgroundColor     = WakeWellTheme.cardBackground
        btn.layer.cornerRadius  = 14
        btn.layer.borderWidth   = 0.5
        btn.layer.borderColor   = WakeWellTheme.border.cgColor
        btn.showsMenuAsPrimaryAction = true
        btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    private func styleTextView(_ tv: UITextView, placeholder: String) {
        tv.font             = .systemFont(ofSize: 16)
        tv.textColor        = WakeWellTheme.labelTertiary   // placeholder colour
        tv.text             = placeholder
        tv.backgroundColor  = WakeWellTheme.cardBackground
        tv.layer.cornerRadius = 14
        tv.layer.borderWidth  = 0.5
        tv.layer.borderColor  = WakeWellTheme.border.cgColor
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        tv.delegate         = self
    }

    // MARK: - Menus

    private func setupMenus() {
        let catActions = categories.map { cat in
            UIAction(title: cat) { [weak self] _ in
                self?.selectedCategory = cat
                self?.categoryButton.setTitle(cat, for: .normal)
                self?.categoryButton.setTitleColor(WakeWellTheme.labelPrimary, for: .normal)
            }
        }
        categoryButton.menu = UIMenu(title: "Select Category", children: catActions)

        let durActions = durations.map { dur in
            UIAction(title: dur < 60 ? "\(dur) sec" : "\(dur / 60) min") { [weak self] _ in
                self?.selectedDuration = dur
                let label = dur < 60 ? "\(dur) sec" : "\(dur / 60) min"
                self?.durationButton.setTitle(label, for: .normal)
                self?.durationButton.setTitleColor(WakeWellTheme.labelPrimary, for: .normal)
            }
        }
        let noTimer = UIAction(title: "No timer (self-paced)") { [weak self] _ in
            self?.selectedDuration = nil
            self?.durationButton.setTitle("No timer (self-paced)", for: .normal)
            self?.durationButton.setTitleColor(WakeWellTheme.labelPrimary, for: .normal)
        }
        durationButton.menu = UIMenu(title: "Select Duration",
                                      children: [noTimer] + durActions)
    }

    // MARK: - TextViewDelegate (placeholder behaviour)

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == WakeWellTheme.labelTertiary {
            textView.text      = ""
            textView.textColor = WakeWellTheme.labelPrimary
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.textColor = WakeWellTheme.labelTertiary
            textView.text = (textView == descView)
                ? "What is this activity and why does it help?"
                : "Step 1\nStep 2\nStep 3"
        }
    }

    // MARK: - Actions

    @objc private func cancelTapped() { dismiss(animated: true) }

    @objc private func saveTapped() {
        let rawTitle = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !rawTitle.isEmpty else {
            shake(titleField); return
        }

        let rawDesc  = (descView.textColor == WakeWellTheme.labelTertiary)
            ? "" : descView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let rawSteps = (stepsView.textColor == WakeWellTheme.labelTertiary)
            ? [] : stepsView.text.components(separatedBy: "\n").filter { !$0.isEmpty }

        let type: ActivityType = selectedDuration != nil ? .timerBased : .stepBased

        let newActivity = Activity(
            id:           UUID().uuidString,
            title:        rawTitle,
            description:  rawDesc,
            duration:     selectedDuration,
            category:     selectedCategory,
            imageName:    "ritual_1",     // fallback image
            activityType: type,
            steps:        rawSteps.isEmpty ? ["Follow the description above"] : rawSteps
        )

        activities.append(newActivity)
        saveActivities()
        onSave?()
        dismiss(animated: true)
    }

    private func shake(_ view: UIView) {
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.values   = [-8, 8, -6, 6, -4, 4, 0]
        anim.duration = 0.35
        view.layer.add(anim, forKey: "shake")
    }
}
