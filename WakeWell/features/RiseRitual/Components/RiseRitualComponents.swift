import SwiftUI

struct RiseRitualBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(riseHex: "#1A1734"),
                Color(riseHex: "#352551"),
                Color(riseHex: "#FFB15C").opacity(0.72)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct RiseMoodButton: View {
    let mood: RiseMood
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: mood.sfSymbol)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(
                    LinearGradient(colors: mood.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(mood.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(mood.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 136, alignment: .topLeading)
        .padding(14)
        .background(Color.white.opacity(isSelected ? 0.18 : 0.11))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(isSelected ? Color(riseHex: "#FFD36A") : .white.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 8)
    }
}

struct RitualBlockCard: View {
    let block: RitualBlock

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: block.sfSymbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color(riseHex: "#FFD36A"))
                .frame(width: 46, height: 46)
                .background(Color(riseHex: "#FFD36A").opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(block.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer(minLength: 8)
                    Text("\(block.duration)m")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(riseHex: "#FFD36A"))
                }

                Text(block.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct RisePrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(Color(riseHex: "#201735"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color(riseHex: "#FFD36A").opacity(configuration.isPressed ? 0.78 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct RiseSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(Color.white.opacity(configuration.isPressed ? 0.13 : 0.1))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
    }
}
