//
//  ReactionTapViewController.swift
//  WakeWell
//

import UIKit

final class ReactionTapViewController: RoutineActivityViewController {

    private let sessionDuration: TimeInterval = 300
    private let titleLabel = UILabel()
    private let scoreLabel = UILabel()
    private let timerLabel = UILabel()
    private let arenaView = UIView()
    private let statusLabel = UILabel()
    private let skipButton = UIButton(type: .system)
    private let targetButton = UIButton(type: .custom)

    private var score = 0
    private var attempts = 0
    private var gameStartDate = Date()
    private var roundTimer: Timer?
    private var countdownTimer: Timer?
    private var activeRoundToken = UUID()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.title = "Step \(currentIndex + 1)/\(routineQueue.count)"
        setupUI()
        startGame()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        roundTimer?.invalidate()
        countdownTimer?.invalidate()
    }

    private func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = activity?.title
        titleLabel.font = .boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true

        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.font = .boldSystemFont(ofSize: 22)
        scoreLabel.textAlignment = .center
        scoreLabel.text = "Score: 0"

        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.font = .monospacedDigitSystemFont(ofSize: 18, weight: .semibold)
        timerLabel.textAlignment = .center
        timerLabel.textColor = .secondaryLabel

        arenaView.translatesAutoresizingMaskIntoConstraints = false
        arenaView.backgroundColor = UIColor.secondarySystemBackground
        arenaView.layer.cornerRadius = 28
        arenaView.clipsToBounds = true

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 16)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.text = "Tap the dot as soon as it appears. Missed dots score 0."

        targetButton.frame = CGRect(x: 0, y: 0, width: 54, height: 54)
        targetButton.backgroundColor = .systemPink
        targetButton.layer.cornerRadius = 27
        targetButton.isHidden = true
        targetButton.addTarget(self, action: #selector(targetTapped), for: .touchUpInside)

        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        skipButton.backgroundColor = .systemBlue
        skipButton.layer.cornerRadius = 16
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(scoreLabel)
        view.addSubview(timerLabel)
        view.addSubview(arenaView)
        arenaView.addSubview(targetButton)
        view.addSubview(statusLabel)
        view.addSubview(skipButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            scoreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scoreLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            timerLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 8),
            timerLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timerLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            arenaView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 28),
            arenaView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            arenaView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            arenaView.heightAnchor.constraint(equalToConstant: 380),

            statusLabel.topAnchor.constraint(equalTo: arenaView.bottomAnchor, constant: 18),
            statusLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            skipButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func startGame() {
        gameStartDate = Date()
        updateTimerLabel()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self else { return }
            self.updateTimerLabel()
            if Date().timeIntervalSince(self.gameStartDate) >= self.sessionDuration {
                timer.invalidate()
                self.finishGame()
            }
        }

        scheduleNextRound()
    }

    private func updateTimerLabel() {
        let remaining = max(sessionDuration - Date().timeIntervalSince(gameStartDate), 0)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        timerLabel.text = String(format: "Time Left %02d:%02d", minutes, seconds)
    }

    private func scheduleNextRound() {
        roundTimer?.invalidate()
        activeRoundToken = UUID()
        let roundToken = activeRoundToken

        let interval = max(0.45, 1.4 - (Double(attempts) * 0.03))
        showTarget()

        roundTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self, self.activeRoundToken == roundToken else { return }
            if !self.targetButton.isHidden {
                self.targetButton.isHidden = true
                self.statusLabel.text = "Missed. Stay ready for the next dot."
                self.attempts += 1
            }
            self.scheduleNextRound()
        }
    }

    private func showTarget() {
        let buttonSize = targetButton.bounds.width
        let maxX = arenaView.bounds.width - buttonSize - 20
        let maxY = arenaView.bounds.height - buttonSize - 20

        guard maxX > 20, maxY > 20 else { return }

        let randomX = CGFloat.random(in: 20...maxX)
        let randomY = CGFloat.random(in: 20...maxY)
        targetButton.frame.origin = CGPoint(x: randomX, y: randomY)
        targetButton.isHidden = false
    }

    @objc private func targetTapped() {
        guard !targetButton.isHidden else { return }
        score += 1
        attempts += 1
        scoreLabel.text = "Score: \(score)"
        statusLabel.text = "Nice tap. The next dot will be faster."
        targetButton.isHidden = true
        scheduleNextRound()
    }

    private func finishGame() {
        roundTimer?.invalidate()
        countdownTimer?.invalidate()
        targetButton.isHidden = true
        statusLabel.text = "Session complete. Final score: \(score)"

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.navigateToNextActivity()
        }
    }

    @objc private func skipTapped() {
        finishGame()
    }
}
