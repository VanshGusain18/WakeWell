//
//  SplashViewController.swift
//  WakeWell
//
//  Created by geu on 11/04/26.
//
// SplashViewController.swift
import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#F8F5EE")
        setupUI()
        animateAndTransition()
    }

    private func setupUI() {
        // Logo circle
        let circle = UIView()
        circle.backgroundColor = UIColor(hex: "#EDE9DF")
        circle.layer.cornerRadius = 80
        circle.translatesAutoresizingMaskIntoConstraints = false

        // App icon inside circle — use your asset or SF symbol
        let iconImage = UIImageView()
        iconImage.image = UIImage(systemName: "sailboat.fill")
        iconImage.tintColor = UIColor(hex: "#F5C842")
        iconImage.contentMode = .scaleAspectFit
        iconImage.translatesAutoresizingMaskIntoConstraints = false

        // App name
        let nameLabel = UILabel()
        nameLabel.text = "SetSail"
        nameLabel.font = UIFont.systemFont(ofSize: 38, weight: .bold)
        nameLabel.textColor = UIColor(hex: "#1B2D4F")
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        // Tagline
        let taglineLabel = UILabel()
        taglineLabel.text = "Wake refreshed. Start strong."
        taglineLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        taglineLabel.textColor = UIColor(hex: "#8A9BB0")
        taglineLabel.translatesAutoresizingMaskIntoConstraints = false

        circle.addSubview(iconImage)
        view.addSubview(circle)
        view.addSubview(nameLabel)
        view.addSubview(taglineLabel)

        NSLayoutConstraint.activate([
            circle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circle.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            circle.widthAnchor.constraint(equalToConstant: 160),
            circle.heightAnchor.constraint(equalToConstant: 160),

            iconImage.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            iconImage.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            iconImage.widthAnchor.constraint(equalToConstant: 80),
            iconImage.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: circle.bottomAnchor, constant: 28),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            taglineLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    private func animateAndTransition() {
        // Wait 2 seconds, then go to onboarding slides
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let onboarding = OnboardingPageViewController()
            onboarding.modalTransitionStyle = .crossDissolve
            onboarding.modalPresentationStyle = .fullScreen
            self.present(onboarding, animated: true)
        }
    }
}
