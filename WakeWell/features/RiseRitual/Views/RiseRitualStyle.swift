import SwiftUI

enum RiseRitualStyle {
    static let background = Color(riseHex: "#F2F1FF")
    static let card = Color.white
    static let elevated = Color(riseHex: "#F8F7FF")
    static let purple = Color(riseHex: "#6C63FF")
    static let gold = Color(riseHex: "#F5A623")
    static let text = Color(riseHex: "#1C1A3A")
    static let secondaryText = Color(riseHex: "#6B6990")
    static let border = Color(riseHex: "#E2E0FC")
    static let shadow = Color(riseHex: "#0A0820")

    static func titleFont(size: CGFloat = 34) -> Font {
        .system(size: size, weight: .bold)
    }

    static func headlineFont(size: CGFloat = 20) -> Font {
        .system(size: size, weight: .bold)
    }

    static func bodyFont(size: CGFloat = 15, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight)
    }

    static func buttonFont(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .bold)
    }

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [background, Color(riseHex: "#EAE8FF"), gold.opacity(0.08)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func gradient(for index: Int) -> [Color] {
        let gradients = [
            [Color(riseHex: "#6C63FF"), Color(riseHex: "#9B8FFF")],
            [Color(riseHex: "#F5A623"), Color(riseHex: "#F5C56A")],
            [Color(riseHex: "#363460"), Color(riseHex: "#6C63FF")],
            [Color(riseHex: "#6C63FF"), Color(riseHex: "#F5A623")],
            [Color(riseHex: "#9B8FFF"), Color(riseHex: "#F5A623")]
        ]
        return gradients[index % gradients.count]
    }
}

extension Color {
    init(riseHex: String) {
        let cleaned = riseHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        self.init(
            red: Double((value >> 16) & 0xff) / 255,
            green: Double((value >> 8) & 0xff) / 255,
            blue: Double(value & 0xff) / 255
        )
    }
}

struct RiseRitualPrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(RiseRitualStyle.buttonFont(size: 16))
            .foregroundStyle(RiseRitualStyle.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(RiseRitualStyle.gold.opacity(configuration.isPressed ? 0.78 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: RiseRitualStyle.gold.opacity(0.25), radius: 10, x: 0, y: 6)
    }
}

struct RiseRitualSecondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(RiseRitualStyle.buttonFont(size: 14))
            .foregroundStyle(RiseRitualStyle.purple)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(configuration.isPressed ? RiseRitualStyle.purple.opacity(0.1) : RiseRitualStyle.card)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(RiseRitualStyle.border, lineWidth: 1)
            )
    }
}

struct RiseRitualTopBar: View {
    let title: String
    var subtitle: String?
    var leadingSystemImage: String?
    var trailingText: String?
    var onLeadingTap: (() -> Void)?

    var body: some View {
        HStack {
            if let leadingSystemImage, let onLeadingTap {
                Button(action: onLeadingTap) {
                    Image(systemName: leadingSystemImage)
                        .font(RiseRitualStyle.buttonFont(size: 16))
                        .foregroundStyle(RiseRitualStyle.purple)
                        .frame(width: 44, height: 44)
                }
            } else {
                Color.clear.frame(width: 44, height: 44)
            }

            VStack(spacing: 2) {
                Text(title)
                    .font(RiseRitualStyle.headlineFont(size: 17))
                    .foregroundStyle(RiseRitualStyle.text)
                if let subtitle {
                    Text(subtitle)
                        .font(RiseRitualStyle.bodyFont(size: 12, weight: .semibold))
                        .foregroundStyle(RiseRitualStyle.secondaryText)
                }
            }
            .frame(maxWidth: .infinity)

            if let trailingText {
                Text(trailingText)
                    .font(RiseRitualStyle.buttonFont(size: 14))
                    .foregroundStyle(RiseRitualStyle.gold)
                    .frame(width: 44, alignment: .trailing)
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
}
