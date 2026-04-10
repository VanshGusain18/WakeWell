//
//  NotificationViewController.swift
//  WakeWellAlarmUI  ← This goes in a NEW Notification Content Extension target
//
//  HOW TO ADD THIS TARGET:
//  1. Xcode → File → New → Target → Notification Content Extension
//  2. Name it "WakeWellAlarmUI"
//  3. In its Info.plist set:
//       NSExtension → NSExtensionAttributes → UNNotificationExtensionCategory → "WAKEWELL_ALARM"
//       NSExtension → NSExtensionAttributes → UNNotificationExtensionDefaultContentHidden → YES
//       NSExtension → NSExtensionAttributes → UNNotificationExtensionInitialContentSizeRatio → 1
//  4. Replace the generated NotificationViewController.swift with this file.
//  5. Replace MainInterface.storyboard with the views built programmatically below
//     (or delete the storyboard and set NSExtensionPrincipalClass to this class directly).
//

import UIKit
import UserNotifications
import UserNotificationsUI
import AVFoundation

@objc(NotificationViewController)
class NotificationViewController: UIViewController, UNNotificationContentExtension {

    // MARK: - UI

    private let backgroundView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.08, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let timeLabel: UILabel = {
        let l = UILabel()
        l.font          = UIFont.monospacedDigitSystemFont(ofSize: 80, weight: .thin)
        l.textColor     = .white
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font          = UIFont.systemFont(ofSize: 16, weight: .regular)
        l.textColor     = UIColor.white.withAlphaComponent(0.6)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let smartBadge: UILabel = {
        let l = UILabel()
        l.text            = "✦ Smart Alarm — light sleep detected"
        l.font            = UIFont.systemFont(ofSize: 13, weight: .medium)
        l.textColor       = UIColor(red: 1, green: 0.85, blue: 0.4, alpha: 1)
        l.textAlignment   = .center
        l.isHidden        = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    /// The pill at the bottom with "slide to stop" affordance
    private let slideTrack: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 36
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let slideThumb: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 28
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let slideArrow: UILabel = {
        let l = UILabel()
        l.text      = "›"
        l.font      = UIFont.systemFont(ofSize: 36, weight: .thin)
        l.textColor = UIColor(red: 0.05, green: 0.05, blue: 0.08, alpha: 0.8)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let slideHint: UILabel = {
        let l = UILabel()
        l.text          = "slide to stop"
        l.font          = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor     = UIColor.white.withAlphaComponent(0.4)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Constraint we'll animate
    private var thumbLeadingConstraint: NSLayoutConstraint!

    // Pulsing layers for the ambient ring
    private var pulseLayer1: CALayer?
    private var pulseLayer2: CALayer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        setupSlideGesture()
        startPulse()
        updateClock()

        // Keep the clock live
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateClock()
        }
    }

    // MARK: - UNNotificationContentExtension

    func didReceive(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        let isSmart  = (userInfo["isSmart"] as? Bool) ?? false
        smartBadge.isHidden = !isSmart
        subtitleLabel.text  = "Rise & Shine"
    }

    func didReceive(_ response: UNNotificationResponse,
                    completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        switch response.actionIdentifier {
        case "STOP_ALARM":
            animateSlideComplete {
                completion(.dismissAndForwardAction)  // forwards to AppDelegate
            }
        case "START_RITUAL":
            completion(.dismissAndForwardAction)
        default:
            completion(.doNotDismiss)
        }
    }

    // MARK: - Layout

    private func buildLayout() {
        view.addSubview(backgroundView)
        view.addSubview(timeLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(smartBadge)
        view.addSubview(slideTrack)
        slideTrack.addSubview(slideThumb)
        slideThumb.addSubview(slideArrow)
        view.addSubview(slideHint)

        thumbLeadingConstraint = slideThumb.leadingAnchor.constraint(
            equalTo: slideTrack.leadingAnchor, constant: 8)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

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
            slideArrow.centerYAnchor.constraint(equalTo: slideThumb.centerYAnchor)
        ])
    }

    // MARK: - Slide gesture

    private func setupSlideGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleSlide(_:)))
        slideTrack.addGestureRecognizer(pan)
    }

    @objc private func handleSlide(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: slideTrack)
        let trackWidth  = slideTrack.bounds.width
        let thumbWidth: CGFloat = 56
        let maxOffset   = trackWidth - thumbWidth - 16   // 8 inset each side

        switch gesture.state {
        case .changed:
            let newLeading = max(8, min(8 + translation.x, 8 + maxOffset))
            thumbLeadingConstraint.constant = newLeading

            // Fade the hint as thumb travels right
            let progress = (newLeading - 8) / maxOffset
            slideHint.alpha = 1 - progress

        case .ended, .cancelled:
            let progress = (thumbLeadingConstraint.constant - 8) / maxOffset
            if progress > 0.75 {
                // Completed — treat as STOP
                animateSlideComplete {
                    // Notify the extension to dismiss (mimics tapping "Stop Alarm")
                    self.extensionContext?.performNotificationDefaultAction()
                }
            } else {
                // Snap back
                UIView.animate(withDuration: 0.4,
                               delay: 0,
                               usingSpringWithDamping: 0.6,
                               initialSpringVelocity: 0.5) {
                    self.thumbLeadingConstraint.constant = 8
                    self.slideHint.alpha = 1
                    self.view.layoutIfNeeded()
                }
            }
        default:
            break
        }
    }

    private func animateSlideComplete(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2) {
            self.thumbLeadingConstraint.constant = self.slideTrack.bounds.width - 56 - 8
            self.slideHint.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion()
        }
    }

    // MARK: - Pulse animation

    private func startPulse() {
        func makePulse(scale: Float, delay: Double) -> CALayer {
            let size: CGFloat = 140
            let layer = CALayer()
            layer.frame = CGRect(
                x: view.center.x - size / 2,
                y: (view.frame.height / 2 - 60) - size / 2,
                width:  size,
                height: size
            )
            layer.cornerRadius  = size / 2
            layer.borderWidth   = 1
            layer.borderColor   = UIColor.white.withAlphaComponent(0.15).cgColor
            layer.backgroundColor = UIColor.clear.cgColor
            view.layer.insertSublayer(layer, at: 0)

            let scaleAnim        = CABasicAnimation(keyPath: "transform.scale")
            scaleAnim.toValue    = scale
            scaleAnim.duration   = 2.5
            scaleAnim.beginTime  = CACurrentMediaTime() + delay
            scaleAnim.repeatCount = .infinity
            scaleAnim.autoreverses = true
            scaleAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            layer.add(scaleAnim, forKey: "pulse")
            return layer
        }

        pulseLayer1 = makePulse(scale: 1.4, delay: 0)
        pulseLayer2 = makePulse(scale: 1.7, delay: 0.8)
    }

    // MARK: - Clock

    private func updateClock() {
        let formatter        = DateFormatter()
        formatter.dateFormat = "h:mm"
        timeLabel.text       = formatter.string(from: Date())
    }
}
