//
//  ShortWalkActivityViewController.swift
//  WakeWell
//

import CoreMotion
import UIKit

final class ShortWalkActivityViewController: RoutineActivityViewController {

    private let pedometer = CMPedometer()
    private let stepTarget = 100

    private let titleLabel = UILabel()
    private let progressLabel = UILabel()
    private let statusLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let stepCountLabel = UILabel()
    private let skipButton = UIButton(type: .system)

    private var sessionStartDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.title = "Step \(currentIndex + 1)/\(routineQueue.count)"
        setupUI()
        startTracking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pedometer.stopUpdates()
    }

    private func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = activity?.title
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true

        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.text = "Target: \(stepTarget) steps"
        progressLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        progressLabel.textAlignment = .center

        stepCountLabel.translatesAutoresizingMaskIntoConstraints = false
        stepCountLabel.font = .monospacedDigitSystemFont(ofSize: 42, weight: .bold)
        stepCountLabel.textAlignment = .center
        stepCountLabel.text = "0"

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 17)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.text = "Start walking and keep a steady pace."

        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = .systemGray5
        progressView.progressTintColor = .systemBlue
        progressView.transform = CGAffineTransform(scaleX: 1, y: 4)
        progressView.progress = 0

        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        skipButton.backgroundColor = .systemBlue
        skipButton.layer.cornerRadius = 16
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(progressLabel)
        view.addSubview(stepCountLabel)
        view.addSubview(statusLabel)
        view.addSubview(progressView)
        view.addSubview(skipButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            progressLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            progressLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            progressLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            stepCountLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 36),
            stepCountLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            stepCountLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            progressView.topAnchor.constraint(equalTo: stepCountLabel.bottomAnchor, constant: 28),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),

            statusLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 36),
            statusLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            skipButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func startTracking() {
        guard CMPedometer.isStepCountingAvailable() else {
            statusLabel.text = "Step tracking is unavailable on this device. You can skip this activity."
            return
        }

        sessionStartDate = Date()
        pedometer.startUpdates(from: sessionStartDate) { [weak self] data, error in
            guard let self else { return }
            DispatchQueue.main.async {
                if error != nil {
                    self.statusLabel.text = "We could not read steps right now. You can keep walking or skip."
                    return
                }

                let steps = data?.numberOfSteps.intValue ?? 0
                self.stepCountLabel.text = "\(steps)"
                self.progressView.progress = min(Float(steps) / Float(self.stepTarget), 1)

                if steps >= self.stepTarget {
                    self.statusLabel.text = "Target reached. Nice work."
                    self.pedometer.stopUpdates()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.navigateToNextActivity()
                    }
                } else {
                    let remaining = max(self.stepTarget - steps, 0)
                    self.statusLabel.text = "\(remaining) more steps to go."
                }
            }
        }
    }

    @objc private func skipTapped() {
        pedometer.stopUpdates()
        navigateToNextActivity()
    }
}
