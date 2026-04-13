//
//  UserDetailViewController.swift
//  WakeWell
//
//  Created by geu on 11/04/26.
//

// UserDetailViewController.swift
import UIKit

class UserDetailViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var goalSegmentedControl: UISegmentedControl!
    @IBOutlet weak var bedtimePicker: UIDatePicker!
    @IBOutlet weak var wakeTimePicker: UIDatePicker!
    @IBOutlet weak var letsGoButton: UIButton!

    // Card views (for shadow — UIKit needs clipsToBounds OFF for shadow)
    @IBOutlet weak var nameCard: UIView!
    @IBOutlet weak var ageCard: UIView!
    @IBOutlet weak var goalCard: UIView!
    @IBOutlet weak var scheduleCard: UIView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#F8F5EE")
        styleCards()
        styleTextFields()
        styleSegmentedControl()
        setupKeyboardDismiss()
    }

    // MARK: - Styling
    private func styleCards() {
        [nameCard, ageCard, goalCard, scheduleCard].forEach { card in
            guard let card = card else { return }
            card.layer.cornerRadius = 16
            card.layer.shadowColor = UIColor.black.cgColor
            card.layer.shadowOpacity = 0.06
            card.layer.shadowOffset = CGSize(width: 0, height: 4)
            card.layer.shadowRadius = 8
            card.clipsToBounds = false   // must be false for shadow to show
        }
    }

    private func styleTextFields() {
        [nameTextField, ageTextField].forEach { field in
            guard let field = field else { return }
            field.borderStyle = .none
            field.font = UIFont.systemFont(ofSize: 17)
            field.textColor = UIColor(hex: "#1B2D4F")
            field.attributedPlaceholder = NSAttributedString(
                string: field == nameTextField ? "e.g. Alex" : "e.g. 25",
                attributes: [.foregroundColor: UIColor(hex: "#8A9BB0")]
            )
        }
        ageTextField?.keyboardType = .numberPad
    }

    private func styleSegmentedControl() {
        guard let goalSegmentedControl = goalSegmentedControl else { return }
        goalSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor(hex: "#8A9BB0")], for: .normal)
        goalSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor(hex: "#1B2D4F"),
             .font: UIFont.systemFont(ofSize: 13, weight: .semibold)],
            for: .selected)
        goalSegmentedControl.selectedSegmentTintColor = UIColor(hex: "#F5C842")
        goalSegmentedControl.backgroundColor = UIColor(hex: "#F0EDE6")
        goalSegmentedControl.selectedSegmentIndex = 0
    }

    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Validation
    private func validateInputs() -> Bool {
        guard let name = nameTextField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError("Please enter your name.")
            return false
        }
        guard let ageText = ageTextField.text,
              let age = Int(ageText), age > 0, age < 120 else {
            showError("Please enter a valid age.")
            return false
        }
        return true
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Just one thing",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Save User Data
    private func saveUserData() {
        let defaults = UserDefaults.standard
        defaults.set(nameTextField.text ?? "", forKey: "userName")
        defaults.set(Int(ageTextField.text ?? "0") ?? 0, forKey: "userAge")
        defaults.set(goalSegmentedControl.selectedSegmentIndex, forKey: "userGoal")
        defaults.set(bedtimePicker.date, forKey: "userBedtime")
        defaults.set(wakeTimePicker.date, forKey: "userWakeTime")
    }

    // MARK: - IBAction
    @IBAction func letsGoTapped(_ sender: UIButton) {
        guard validateInputs() else { return }

        // Animate the button
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }

        saveUserData()

        // ✅ Navigate to Tab Bar
        OnboardingCoordinator.completeOnboarding(from: self)
    }
}
