//
//  NotificationViewController.swift
//  SetSailAlarmUI  ← Notification Content Extension target
//
//  Notification content extension for SetSail alarm alerts.
//

import UIKit
import UserNotifications
import UserNotificationsUI

@objc(NotificationViewController)
final class NotificationViewController: UIViewController, UNNotificationContentExtension {

    // MARK: - UI components

    private let timeLabel: UILabel = {
        let l = UILabel()
        l.font          = .monospacedDigitSystemFont(ofSize: 80, weight: .thin)
        l.textColor     = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 16, weight: .regular)
        l.textColor     = WakeWellTheme.labelSecondary
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let smartBadge: UILabel = {
        let l = UILabel()
        l.text          = "✦ Smart Alarm — light sleep detected"
        l.font          = .systemFont(ofSize: 13, weight: .medium)
        l.textColor     = WakeWellTheme.accentGold
        l.textAlignment = .center
        l.isHidden      = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let slideTrack: UIView = {
        let v = UIView()
        v.backgroundColor    = WakeWellTheme.cardElevated
        v.layer.cornerRadius = 36
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let slideThumb: UIView = {
        let v = UIView()
        v.backgroundColor    = WakeWellTheme.cardBackground
        v.layer.cornerRadius = 28
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let slideArrow: UILabel = {
        let l = UILabel()
        l.text      = "›"
        l.font      = .systemFont(ofSize: 36, weight: .thin)
        l.textColor = WakeWellTheme.labelPrimary
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let slideHint: UILabel = {
        let l = UILabel()
        l.text          = "slide to stop"
        l.font          = .systemFont(ofSize: 14, weight: .regular)
        l.textColor     = WakeWellTheme.labelSecondary
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var thumbLeadingConstraint: NSLayoutConstraint!

    // Pulse layers
    private var pulseLayer1: CALayer?
    private var pulseLayer2: CALayer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = WakeWellTheme.background
        buildLayout()
        setupSlideGesture()
        startPulse()
        updateClock()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateClock()
        }
    }

    // MARK: - UNNotificationContentExtension

    func didReceive(_ notification: UNNotification) {
        let info   = notification.request.content.userInfo
        let isSmart = (info["source"] as? String) == "smartAlarm"
        smartBadge.isHidden  = !isSmart
        subtitleLabel.text   = "Rise & Shine"
    }

    func didReceive(_ response: UNNotificationResponse,
                    completionHandler done: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        switch response.actionIdentifier {
        case "STOP_ALARM":
            animateSlideComplete { done(.dismissAndForwardAction) }
        case "OPEN_SETSAIL_ALARM", "SNOOZE_ALARM":
            done(.dismissAndForwardAction)
        default:
            done(.doNotDismiss)
        }
    }

    // MARK: - Layout

    private func buildLayout() {
        [timeLabel, subtitleLabel, smartBadge, slideTrack, slideHint].forEach {
            view.addSubview($0)
        }
        slideTrack.addSubview(slideThumb)
        slideThumb.addSubview(slideArrow)

        thumbLeadingConstraint = slideThumb.leadingAnchor.constraint(
            equalTo: slideTrack.leadingAnchor, constant: 8)

        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),

            subtitleLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            smartBadge.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            smartBadge.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            slideTrack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            slideTrack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            slideTrack.widthAnchor.constraint(equalToConstant: 280),
            slideTrack.heightAnchor.constraint(equalToConstant: 72),

            slideHint.bottomAnchor.constraint(equalTo: slideTrack.topAnchor, constant: -10),
            slideHint.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            thumbLeadingConstraint,
            slideThumb.centerYAnchor.constraint(equalTo: slideTrack.centerYAnchor),
            slideThumb.widthAnchor.constraint(equalToConstant: 56),
            slideThumb.heightAnchor.constraint(equalToConstant: 56),

            slideArrow.centerXAnchor.constraint(equalTo: slideThumb.centerXAnchor),
            slideArrow.centerYAnchor.constraint(equalTo: slideThumb.centerYAnchor),
        ])
    }

    // MARK: - Slide gesture

    private func setupSlideGesture() {
        slideTrack.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(handleSlide(_:)))
        )
    }

    @objc private func handleSlide(_ gesture: UIPanGestureRecognizer) {
        let tx        = gesture.translation(in: slideTrack).x
        let trackW    = slideTrack.bounds.width
        let thumbW: CGFloat = 56
        let maxOffset = trackW - thumbW - 16

        switch gesture.state {
        case .changed:
            thumbLeadingConstraint.constant = max(8, min(8 + tx, 8 + maxOffset))
            slideHint.alpha = 1 - (thumbLeadingConstraint.constant - 8) / maxOffset

        case .ended, .cancelled:
            let progress = (thumbLeadingConstraint.constant - 8) / maxOffset
            if progress > 0.75 {
                animateSlideComplete { self.extensionContext?.performNotificationDefaultAction() }
            } else {
                UIView.animate(withDuration: 0.4, delay: 0,
                               usingSpringWithDamping: 0.6,
                               initialSpringVelocity: 0.5) {
                    self.thumbLeadingConstraint.constant = 8
                    self.slideHint.alpha = 1
                    self.view.layoutIfNeeded()
                }
            }
        default: break
        }
    }

    private func animateSlideComplete(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2) {
            self.thumbLeadingConstraint.constant = self.slideTrack.bounds.width - 56 - 8
            self.slideHint.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in completion() }
    }

    // MARK: - Pulse animation

    private func startPulse() {
        func makePulse(scale: Float, delay: Double) -> CALayer {
            let size: CGFloat = 140
            let layer = CALayer()
            layer.frame = CGRect(
                x: view.center.x - size / 2,
                y: view.frame.height / 2 - 60 - size / 2,
                width: size, height: size
            )
            layer.cornerRadius    = size / 2
            layer.borderWidth     = 1
            layer.borderColor     = UIColor.white.withAlphaComponent(0.15).cgColor
            layer.backgroundColor = UIColor.clear.cgColor
            view.layer.insertSublayer(layer, at: 0)

            let anim           = CABasicAnimation(keyPath: "transform.scale")
            anim.toValue       = scale
            anim.duration      = 2.5
            anim.beginTime     = CACurrentMediaTime() + delay
            anim.repeatCount   = .infinity
            anim.autoreverses  = true
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            layer.add(anim, forKey: "pulse")
            return layer
        }
        pulseLayer1 = makePulse(scale: 1.4, delay: 0)
        pulseLayer2 = makePulse(scale: 1.7, delay: 0.8)
    }

    // MARK: - Clock

    private func updateClock() {
        let f = DateFormatter()
        f.dateFormat  = "h:mm"
        timeLabel.text = f.string(from: Date())
    }
}
