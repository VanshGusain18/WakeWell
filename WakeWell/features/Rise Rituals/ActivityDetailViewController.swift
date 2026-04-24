//
//  ActivityDetailViewController.swift
//  WakeWell
//
//  Created by geu on 18/03/26.
//

import UIKit

class ActivityDetailViewController: RoutineActivityViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var steps: UILabel!

    var timerLayer = CAShapeLayer()
    var backgroundLayer = CAShapeLayer()
    var timer: Timer?
    var countdownTimer: Timer?

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let timerContainerView = UIView()
    private let timerContentStack = UIStackView()
    private let timerTextLabel = UILabel()
    private let timingLabel = UILabel()
    private let skipButton = UIButton(type: .system)
    private let countdownOverlay = UIView()
    private let countdownLabel = UILabel()
    private var startTime: Date?
    private var hasLaidOutUI = false
    private var isTransitioning = false

    private var activityDuration: TimeInterval {
        TimeInterval(activity?.duration ?? 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupUI()
        setupData()
        startCountdown()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard hasLaidOutUI else { return }
        //setupCircularTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        countdownTimer?.invalidate()
    }

    private func setupData() {
        guard let activity else { return }

        navigationItem.title = "Step \(currentIndex + 1)/\(routineQueue.count)"
        titleLabel.text = activity.title

        instructionLabel.text = activity.description
        steps.text = activity.steps.enumerated()
            .map { index, step in "\(index + 1). \(step)" }
            .joined(separator: "\n\n")

        timingLabel.text = formattedTimingText(for: activity)
        timerTextLabel.text = activityDuration > 0 ? formattedTime(activityDuration) : "Ready"
    }

    private func setupUI() {
        hasLaidOutUI = true

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 22

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 26)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75

        timerContainerView.translatesAutoresizingMaskIntoConstraints = false
        timerContainerView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.55)
        timerContainerView.layer.cornerRadius = 110
        timerContainerView.clipsToBounds = false

        timerContentStack.translatesAutoresizingMaskIntoConstraints = false
        timerContentStack.axis = .vertical
        timerContentStack.alignment = .center
        timerContentStack.spacing = 12

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24
        imageView.isHidden = true

        timerTextLabel.translatesAutoresizingMaskIntoConstraints = false
        timerTextLabel.font = .monospacedDigitSystemFont(ofSize: 36, weight: .bold)
        timerTextLabel.textAlignment = .center
        timerTextLabel.textColor = .label

        timingLabel.translatesAutoresizingMaskIntoConstraints = false
        timingLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        timingLabel.textAlignment = .center
        timingLabel.textColor = .secondaryLabel
        timingLabel.numberOfLines = 0

        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.textAlignment = .left
        instructionLabel.numberOfLines = 0
        instructionLabel.font = .systemFont(ofSize: 18)
        instructionLabel.textColor = .label

        steps.translatesAutoresizingMaskIntoConstraints = false
        steps.textAlignment = .left
        steps.numberOfLines = 0
        steps.font = .systemFont(ofSize: 17)
        steps.textColor = .secondaryLabel

        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        skipButton.backgroundColor = .systemBlue
        skipButton.layer.cornerRadius = 14
        skipButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 28, bottom: 14, right: 28)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        timerContainerView.addSubview(timerContentStack)
        timerContentStack.addArrangedSubview(titleLabel)
        timerContentStack.addArrangedSubview(timerTextLabel)

        stackView.addArrangedSubview(timerContainerView)
        stackView.addArrangedSubview(timingLabel)
        stackView.addArrangedSubview(instructionLabel)
        stackView.addArrangedSubview(steps)
        stackView.addArrangedSubview(skipButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),

            timerContainerView.heightAnchor.constraint(equalToConstant: 220),
            timerContainerView.widthAnchor.constraint(equalToConstant: 220),
            timerContainerView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),

            timerContentStack.centerXAnchor.constraint(equalTo: timerContainerView.centerXAnchor),
            timerContentStack.centerYAnchor.constraint(equalTo: timerContainerView.centerYAnchor),
            timerContentStack.leadingAnchor.constraint(greaterThanOrEqualTo: timerContainerView.leadingAnchor, constant: 20),
            timerContentStack.trailingAnchor.constraint(lessThanOrEqualTo: timerContainerView.trailingAnchor, constant: -20),

            skipButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 52)
        ])

        countdownOverlay.translatesAutoresizingMaskIntoConstraints = false
        countdownOverlay.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        countdownOverlay.alpha = 0

        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        countdownLabel.font = .boldSystemFont(ofSize: 34)
        countdownLabel.textAlignment = .center
        countdownLabel.textColor = .label

        countdownOverlay.addSubview(countdownLabel)
        view.addSubview(countdownOverlay)

        NSLayoutConstraint.activate([
            countdownOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            countdownOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            countdownOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            countdownOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            countdownLabel.centerXAnchor.constraint(equalTo: countdownOverlay.centerXAnchor),
            countdownLabel.centerYAnchor.constraint(equalTo: countdownOverlay.centerYAnchor),
            countdownLabel.leadingAnchor.constraint(greaterThanOrEqualTo: countdownOverlay.leadingAnchor, constant: 24),
            countdownLabel.trailingAnchor.constraint(lessThanOrEqualTo: countdownOverlay.trailingAnchor, constant: -24)
        ])
    }

    private func startCountdown() {
        countdownTimer?.invalidate()
        skipButton.isEnabled = false
        countdownLabel.text = "3"

        UIView.animate(withDuration: 0.25) {
            self.countdownOverlay.alpha = 1
        }

        var countdownValue = 3
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else { return }

            countdownValue -= 1
            switch countdownValue {
            case 2, 1:
                self.countdownLabel.text = "\(countdownValue)"
            case 0:
                self.countdownLabel.text = "Start"
            default:
                timer.invalidate()
                self.countdownTimer = nil
                UIView.animate(withDuration: 0.25, animations: {
                    self.countdownOverlay.alpha = 0
                }, completion: { _ in
                    self.skipButton.isEnabled = true
                    self.startTimerIfNeeded()
                })
            }
        }
    }

    private func startTimerIfNeeded() {
        guard activityDuration > 0 else {
            timerTextLabel.text = "Ready"
            return
        }

        progressReset()
        startTime = Date()
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self, let startTime = self.startTime else { return }

            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(elapsed / self.activityDuration, 1)
            let remaining = max(self.activityDuration - elapsed, 0)

            self.timerLayer.strokeEnd = CGFloat(progress)
            self.timerTextLabel.text = self.formattedTime(remaining)

            if progress >= 1 {
                timer.invalidate()
                self.timer = nil
                self.handleActivityCompletion()
            }
        }
    }

    private func progressReset() {
        timerLayer.strokeEnd = 0
        timerTextLabel.text = formattedTime(activityDuration)
    }

    private func handleActivityCompletion() {
        guard !isTransitioning else { return }
        isTransitioning = true
        skipButton.isEnabled = false
        showCompletionOverlay()
    }

    @objc private func skipTapped() {
        timer?.invalidate()
        timer = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
        goToNextActivity()
    }

    private func goToNextActivity() {
        guard !isTransitioning else { return }
        isTransitioning = true

        super.navigateToNextActivity()
    }

    private func showCompletionOverlay() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.96)
        overlay.alpha = 0
        overlay.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 28)
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "Great job\nMoving to the next activity"

        overlay.addSubview(label)
        view.addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -24)
        ])

        UIView.animate(withDuration: 0.25, animations: {
            overlay.alpha = 1
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                overlay.removeFromSuperview()
                self.isTransitioning = false
                self.goToNextActivity()
            }
        })
    }

//    private func setupCircularTimer() {
//        timerLayer.removeFromSuperlayer()
//        backgroundLayer.removeFromSuperlayer()
//
//        let center = timerContainerView.center
//        let radius = (timerContainerView.bounds.width / 2) - 8
//        let circularPath = UIBezierPath(
//            arcCenter: .zero,
//            radius: radius,
//            startAngle: -.pi / 2,
//            endAngle: 1.5 * .pi,
//            clockwise: true
//        )
//
//        backgroundLayer = CAShapeLayer()
//        backgroundLayer.path = circularPath.cgPath
//        backgroundLayer.strokeColor = UIColor.systemGray4.cgColor
//        backgroundLayer.lineWidth = 6
//        backgroundLayer.fillColor = UIColor.clear.cgColor
//        backgroundLayer.position = center
//
//        timerLayer = CAShapeLayer()
//        timerLayer.path = circularPath.cgPath
//        timerLayer.strokeColor = UIColor.systemBlue.cgColor
//        timerLayer.lineWidth = 6
//        timerLayer.fillColor = UIColor.clear.cgColor
//        timerLayer.lineCap = .round
//        timerLayer.strokeEnd = 0
//        timerLayer.position = center
//
//        view.layer.insertSublayer(backgroundLayer, below: timerContainerView.layer)
//        view.layer.insertSublayer(timerLayer, above: backgroundLayer)
//    }

    private func formattedTimingText(for activity: Activity) -> String {
        guard let duration = activity.duration, duration > 0 else {
            return activity.activityType == .timerBased ? "No duration set" : "Self-paced activity"
        }

        let durationText = formattedDurationSummary(TimeInterval(duration))
        switch activity.activityType {
        case .timerBased:
            return "Duration: \(durationText)"
        case .stepBased:
            return "Suggested time: \(durationText)"
        case .informational:
            return "Read through in about \(durationText)"
        }
    }

    private func formattedDurationSummary(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        if minutes > 0 && seconds > 0 {
            return "\(minutes)m \(seconds)s"
        }
        if minutes > 0 {
            return "\(minutes) min"
        }
        return "\(seconds) sec"
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let totalSeconds = max(Int(ceil(time)), 0)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
