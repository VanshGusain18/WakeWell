// WakeWellTheme.swift
// ─────────────────────────────────────────────────────────────────────────────
// Single source of truth for every colour, shadow and button style.
//
// Palette extracted from the screenshot:
//   Background  : deep indigo/purple  #1C1A3A (dark) / #F2F1FF (light)
//   Card surface: white / near-white  #FFFFFF (light) / #2D2B55 (dark)
//   Accent gold : amber               #F5A623  (big numbers, CTA, ring)
//   Accent purple: mid purple         #6C63FF  (ring, category, nav tint)
//   Purple tint : icon container bg   #6C63FF @ 15 % opacity
// ─────────────────────────────────────────────────────────────────────────────

import UIKit

enum WakeWellTheme {

    // MARK: - Backgrounds
    static let background = UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "#1C1A3A")
            : UIColor(hex: "#F2F1FF")
    }
    static let cardBackground = UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "#2D2B55")
            : UIColor(hex: "#FFFFFF")
    }
    static let cardElevated = UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "#363460")
            : UIColor(hex: "#F8F7FF")
    }

    // MARK: - Accent
    /// Gold / amber — big numbers, CTA buttons, ring progress, time label
    static let accentGold   = UIColor(hex: "#F5A623")
    /// Purple — ring stroke, category pills, nav bar tint, primary button
    static let accentPurple = UIColor(hex: "#6C63FF")
    /// Soft tint used for icon container backgrounds
    static let purpleTint   = UIColor(hex: "#6C63FF").withAlphaComponent(0.15)

    // MARK: - Text
    static let labelPrimary = UIColor { t in
        t.userInterfaceStyle == .dark ? UIColor(hex: "#F0EEFF") : UIColor(hex: "#1C1A3A")
    }
    static let labelSecondary = UIColor { t in
        t.userInterfaceStyle == .dark ? UIColor(hex: "#9B99BF") : UIColor(hex: "#6B6990")
    }
    static let labelTertiary = UIColor { t in
        t.userInterfaceStyle == .dark ? UIColor(hex: "#6A6890") : UIColor(hex: "#9B99BF")
    }

    // MARK: - Borders / separators
    static let border = UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "#3D3B65").withAlphaComponent(0.9)
            : UIColor(hex: "#E2E0FC").withAlphaComponent(0.9)
    }

    // MARK: - Shadow
    static let shadowColor: UIColor  = UIColor(hex: "#0A0820")
    static let shadowOpacity: Float  = 0.18
    static let shadowRadius: CGFloat = 14
    static let shadowOffset = CGSize(width: 0, height: 6)

    // MARK: - Chart colours
    static let chartLine     = UIColor(hex: "#F5A623")          // amber line / circles
    static let chartBar      = UIColor(hex: "#6C63FF")          // purple bars
    static let chartGrid     = UIColor { t in
        t.userInterfaceStyle == .dark ? UIColor(hex: "#3D3B65") : UIColor(hex: "#E8E6FF")
    }
    static let chartFillTop  = UIColor(hex: "#F5A623").withAlphaComponent(0.35)
    static let chartAxisText = UIColor { t in
        t.userInterfaceStyle == .dark ? UIColor(hex: "#9B99BF") : UIColor(hex: "#6B6990")
    }

    // MARK: - Glass card (Detail-screen cards)
    static let glassBackground = UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "#2D2B55").withAlphaComponent(0.85)
            : UIColor(hex: "#FFFFFF").withAlphaComponent(0.85)
    }
    static let glassBorder = UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(hex: "#6C63FF").withAlphaComponent(0.25)
            : UIColor(hex: "#FFFFFF").withAlphaComponent(0.6)
    }

    // MARK: - Helpers

    /// Apply standard card surface + corner radius + shadow to any UIView.
    static func styleCard(_ view: UIView, cornerRadius: CGFloat = 20) {
        view.backgroundColor        = cardBackground
        view.layer.cornerRadius     = cornerRadius
        view.layer.masksToBounds    = false
        view.layer.shadowColor      = shadowColor.cgColor
        view.layer.shadowOpacity    = shadowOpacity
        view.layer.shadowRadius     = shadowRadius
        view.layer.shadowOffset     = shadowOffset
    }

    /// Gold-filled primary CTA button.
    static func stylePrimaryButton(_ btn: UIButton, cornerRadius: CGFloat = 20) {
        btn.backgroundColor         = accentGold
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font        = .systemFont(ofSize: 15, weight: .semibold)
        btn.layer.cornerRadius      = cornerRadius
        btn.clipsToBounds           = true
    }

    /// Ghost secondary button (purple text, no fill).
    static func styleSecondaryButton(_ btn: UIButton) {
        btn.backgroundColor = .clear
        btn.setTitleColor(accentPurple, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
    }

    /// Apply glass-card styling used in detail-screen cells.
    static func styleGlassCard(_ view: UIView, cornerRadius: CGFloat = 24) {
        view.backgroundColor        = glassBackground
        view.layer.cornerRadius     = cornerRadius
        view.layer.masksToBounds    = false
        view.layer.borderWidth      = 1.0
        view.layer.borderColor      = glassBorder.cgColor
        view.layer.shadowColor      = shadowColor.cgColor
        view.layer.shadowOpacity    = 0.10
        view.layer.shadowRadius     = 12
        view.layer.shadowOffset     = CGSize(width: 0, height: 4)
    }
}

// MARK: - UIColor hex convenience init
extension UIColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h = String(h.dropFirst()) }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        self.init(
            red:   CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >>  8) & 0xFF) / 255,
            blue:  CGFloat( rgb        & 0xFF) / 255,
            alpha: 1
        )
    }
}
