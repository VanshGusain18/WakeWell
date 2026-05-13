import SwiftUI

struct MoodSelectionView: View {
    @ObservedObject var viewModel: RiseRitualFeatureViewModel

    var body: some View {
        ZStack {
            RiseRitualStyle.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rise Ritual")
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundStyle(RiseRitualStyle.text)
                        Text("Choose how your morning feels. WakeWell will build one focused ritual.")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(RiseRitualStyle.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.bottom, 4)

                    VStack(spacing: 15) {
                        ForEach(Array(RiseRitualFeatureViewModel.Mood.allCases.enumerated()), id: \.element.id) { index, mood in
                            Button {
                                viewModel.selectMood(mood)
                            } label: {
                                MoodCard(mood: mood, index: index)
                            }
                            .buttonStyle(MoodPressStyle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 36)
            }
            .scrollIndicators(.hidden)
        }
    }
}

private struct MoodCard: View {
    let mood: RiseRitualFeatureViewModel.Mood
    let index: Int

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: mood.symbol)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 68, height: 68)
                .background(
                    LinearGradient(colors: RiseRitualStyle.gradient(for: index), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(mood.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(RiseRitualStyle.text)
                Text(mood.subtitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(RiseRitualStyle.secondaryText)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(RiseRitualStyle.card.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(RiseRitualStyle.border, lineWidth: 1)
        )
        .shadow(color: RiseRitualStyle.shadow.opacity(0.08), radius: 14, x: 0, y: 8)
    }
}

private struct MoodPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
