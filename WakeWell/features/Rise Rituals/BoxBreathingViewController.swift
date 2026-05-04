//
//  BoxBreathingViewController.swift
//  WakeWell
//

import UIKit

final class BoxBreathingViewController: RoutineActivityViewController {

    private let phaseSequence: [(title: String, progress: CGFloat)] = [
        ("Breathe In", 0.25),
        ("Hold", 0.50),
        ("Exhale", 0.75),
        ("Pause", 1.0)
    ]

    private let totalCycles = 6
    private let phaseDuration: TimeInterval = 7

    private let titleLabel = UILabel()
    private let cycleLabel = UILabel()
    private let phaseLabel = UILabel()
    private let helperLabel = UILabel()
    private let boxView = UIView()
    private let dotView = UIView()
    private let skipButton = UIButton(type: .system)

    private var currentCycle = 1
    private var currentPhaseIndex = 0
    private var phaseTimer: Timer?
    private var phaseStartDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = WakeWellTheme.background
        navigationItem.title = "Step \(currentIndex + 1)/\(routineQueue.count)"
        setupUI()
        startPhase()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        phaseTimer?.invalidate()
    }

    private func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = activity?.title
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center

        cycleLabel.translatesAutoresizingMaskIntoConstraints = false
        cycleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        cycleLabel.textColor = WakeWellTheme.labelSecondary
        cycleLabel.textAlignment = .center

        phaseLabel.translatesAutoresizingMaskIntoConstraints = false
        phaseLabel.font = .boldSystemFont(ofSize: 32)
        phaseLabel.textAlignment = .center

        helperLabel.translatesAutoresizingMaskIntoConstraints = false
        helperLabel.font = .monospacedDigitSystemFont(ofSize: 20, weight: .medium)
        helperLabel.textAlignment = .center
        helperLabel.textColor = WakeWellTheme.labelSecondary

        boxView.translatesAutoresizingMaskIntoConstraints = false
        boxView.layer.cornerRadius = 24
        boxView.layer.borderWidth = 4
        boxView.layer.borderColor = WakeWellTheme.accentPurple.withAlphaComponent(0.35).cgColor
        boxView.backgroundColor = WakeWellTheme.accentPurple.withAlphaComponent(0.05)

        dotView.translatesAutoresizingMaskIntoConstraints = true
        dotView.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        dotView.backgroundColor = WakeWellTheme.accentPurple
        dotView.layer.cornerRadius = 9

        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        skipButton.backgroundColor = WakeWellTheme.accentGold
        skipButton.layer.cornerRadius = 16
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(cycleLabel)
        view.addSubview(phaseLabel)
        view.addSubview(helperLabel)
        view.addSubview(boxView)
        boxView.addSubview(dotView)
        view.addSubview(skipButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            cycleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            cycleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            cycleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            boxView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            boxView.topAnchor.constraint(equalTo: cycleLabel.bottomAnchor, constant: 36),
            boxView.widthAnchor.constraint(equalToConstant: 240),
            boxView.heightAnchor.constraint(equalToConstant: 240),

            phaseLabel.topAnchor.constraint(equalTo: boxView.bottomAnchor, constant: 28),
            phaseLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            phaseLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            helperLabel.topAnchor.constraint(equalTo: phaseLabel.bottomAnchor, constant: 8),
            helperLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            helperLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            skipButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        view.layoutIfNeeded()
        dotView.center = CGPoint(x: 18, y: boxView.bounds.height - 18)
    }

    private func startPhase() {
        phaseTimer?.invalidate()
        phaseStartDate = Date()

        let phase = phaseSequence[currentPhaseIndex]
        phaseLabel.text = phase.title
        cycleLabel.text = "Cycle \(currentCycle) of \(totalCycles)"
        updateCountdownLabel()
        animateDot(to: phase.progress)

        phaseTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self else { return }
            self.updateCountdownLabel()

            if Date().timeIntervalSince(self.phaseStartDate) >= self.phaseDuration {
                timer.invalidate()
                self.advancePhase()
            }
        }
    }

    private func updateCountdownLabel() {
        let remaining = max(phaseDuration - Date().timeIntervalSince(phaseStartDate), 0)
        helperLabel.text = "Next change in \(Int(ceil(remaining)))s"
    }

    private func advancePhase() {
        if currentPhaseIndex < phaseSequence.count - 1 {
            currentPhaseIndex += 1
            startPhase()
            return
        }

        if currentCycle < totalCycles {
            currentCycle += 1
            currentPhaseIndex = 0
            startPhase()
            return
        }

        navigateToNextActivity()
    }

    private func animateDot(to progress: CGFloat) {
        let side = boxView.bounds.width - 36
        let target: CGPoint

        switch progress {
        case 0.25:
            target = CGPoint(x: 18, y: 18)
        case 0.50:
            target = CGPoint(x: side + 18, y: 18)
        case 0.75:
            target = CGPoint(x: side + 18, y: side + 18)
        default:
            target = CGPoint(x: 18, y: side + 18)
        }

        UIView.animate(withDuration: phaseDuration, delay: 0, options: [.curveEaseInOut]) {
            self.dotView.center = target
        }
    }

    @objc private func skipTapped() {
        navigateToNextActivity()
    }
}
