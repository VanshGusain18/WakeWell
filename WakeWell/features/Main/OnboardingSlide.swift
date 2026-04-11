//
//  OnboardingSlide.swift
//  WakeWell
//
//  Created by geu on 11/04/26.
//

// OnboardingSlide.swift
import UIKit

struct OnboardingSlide {
    let icon: String        // SF Symbol name
    let title: String
    let subtitle: String
    let accentColor: UIColor
}

extension OnboardingSlide {
    static let slides: [OnboardingSlide] = [
        OnboardingSlide(
            icon: "moon.zzz.fill",
            title: "Wake Refreshed.",
            subtitle: "SetSail tracks your sleep cycles and wakes you at your lightest sleep phase — so you rise naturally.",
            accentColor: UIColor(hex: "#F5C842")
        ),
        OnboardingSlide(
            icon: "bell.fill",
            title: "Smart Alarms.",
            subtitle: "Set alarms that adapt to your body. No more jarring wake-ups from deep sleep.",
            accentColor: UIColor(hex: "#8A9BB0")
        ),
        OnboardingSlide(
            icon: "waveform.path.ecg",
            title: "Track Your Rise.",
            subtitle: "Monitor your morning energy patterns and improve your wakefulness over time.",
            accentColor: UIColor(hex: "#1B2D4F")
        ),
        OnboardingSlide(
            icon: "chart.bar.fill",
            title: "See Your Stats.",
            subtitle: "Beautiful insights into your sleep quality, trends, and optimal wake windows.",
            accentColor: UIColor(hex: "#F5C842")
        )
    ]
}

// Hex color helper
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
