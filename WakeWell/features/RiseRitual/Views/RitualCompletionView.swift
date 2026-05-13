import SwiftUI

struct RitualCompletionView: View {
    @ObservedObject var viewModel: RiseRitualFeatureViewModel
    @FocusState private var notesFocused: Bool

    var body: some View {
        ZStack {
            RiseRitualStyle.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("You're Up.")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(RiseRitualStyle.text)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("How refreshed do you feel?")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(RiseRitualStyle.text)
                        Slider(value: $viewModel.energyLevel, in: 0...1)
                            .tint(RiseRitualStyle.gold)
                    }
                    .padding(18)
                    .background(RiseRitualStyle.card)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Morning Notes")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(RiseRitualStyle.text)
                        TextField("Optional note", text: $viewModel.notes, axis: .vertical)
                            .lineLimit(4...7)
                            .focused($notesFocused)
                            .padding(16)
                            .background(RiseRitualStyle.card)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 44)
                .padding(.bottom, 120)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .safeAreaInset(edge: .bottom) {
            Button("Finish") {
                notesFocused = false
                viewModel.finishCompletion()
            }
            .buttonStyle(RiseRitualPrimaryButton())
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(.ultraThinMaterial.opacity(0.4))
        }
    }
}
