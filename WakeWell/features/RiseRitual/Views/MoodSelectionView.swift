import SwiftUI

struct MoodSelectionView: View {
    @ObservedObject var viewModel: RiseRitualFeatureViewModel
    let onMoodSelected: (RiseMood) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            RiseRitualBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rise Ritual")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Build a smoother wake-up.")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white.opacity(0.74))

                        Text("How are you feeling?")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.top, 18)
                    }

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(RiseMood.allCases) { mood in
                            Button {
                                onMoodSelected(mood)
                            } label: {
                                RiseMoodButton(mood: mood, isSelected: viewModel.selectedMood == mood)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 36)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
