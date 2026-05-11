import SwiftUI

struct RitualCompletionView: View {
    @ObservedObject var viewModel: RiseRitualFeatureViewModel

    var body: some View {
        ZStack {
            RiseRitualBackground()

            VStack(alignment: .leading, spacing: 24) {
                Spacer(minLength: 40)

                VStack(alignment: .leading, spacing: 8) {
                    Text("You're Up.")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Save how this morning feels.")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white.opacity(0.72))
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Energy")
                        .font(.headline)
                        .foregroundStyle(.white)

                    HStack {
                        Text("Sleepy")
                        Slider(value: $viewModel.energyLevel, in: 0...1)
                            .tint(Color(riseHex: "#FFD36A"))
                        Text("Charged")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.74))
                }
                .padding(18)
                .background(Color.white.opacity(0.11))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                TextField("Optional notes", text: $viewModel.notes, axis: .vertical)
                    .lineLimit(3...5)
                    .padding(16)
                    .foregroundStyle(.white)
                    .background(Color.white.opacity(0.11))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                Spacer()

                Button("Finish") {
                    viewModel.finishCompletion()
                }
                .buttonStyle(RisePrimaryButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 26)
        }
        .navigationBarBackButtonHidden(true)
    }
}
