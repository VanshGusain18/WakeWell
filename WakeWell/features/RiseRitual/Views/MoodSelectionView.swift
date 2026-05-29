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
                            .font(RiseRitualStyle.titleFont(size: 34))
                            .foregroundStyle(RiseRitualStyle.text)
                        Text("Choose how you want to meet the morning. SetSail will build one calm, focused ritual.")
                            .font(RiseRitualStyle.bodyFont(size: 17))
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
                .padding(.horizontal, 16)
                .padding(.top, 16)
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
                .font(RiseRitualStyle.bodyFont(size: 34, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 68, height: 68)
                .background(
                    LinearGradient(colors: RiseRitualStyle.gradient(for: index), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(mood.title)
                    .font(RiseRitualStyle.headlineFont(size: 24))
                    .foregroundStyle(RiseRitualStyle.text)
                Text(mood.subtitle)
                    .font(RiseRitualStyle.bodyFont(size: 15))
                    .foregroundStyle(RiseRitualStyle.secondaryText)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 132)
        .background(RiseRitualStyle.card.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
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
