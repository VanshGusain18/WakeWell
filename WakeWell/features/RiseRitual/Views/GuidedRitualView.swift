import SwiftUI

struct GuidedRitualView: View {
    @ObservedObject var viewModel: RiseRitualFeatureViewModel
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            RiseRitualBackground()

            VStack(spacing: 26) {
                ProgressView(value: viewModel.progress)
                    .tint(Color(riseHex: "#FFD36A"))
                    .padding(.horizontal, 24)

                Spacer(minLength: 12)

                if let block = viewModel.currentBlock {
                    VStack(spacing: 18) {
                        Image(systemName: block.sfSymbol)
                            .font(.system(size: 64, weight: .semibold))
                            .foregroundStyle(Color(riseHex: "#FFD36A"))
                            .frame(width: 118, height: 118)
                            .background(Color.white.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))

                        Text(block.title)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)

                        Text(block.instructions)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white.opacity(0.78))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 28)
                    }
                }

                Spacer()

                VStack(spacing: 10) {
                    Button("Done") {
                        if viewModel.markCurrentStepDone() {
                            onComplete()
                        }
                    }
                    .buttonStyle(RisePrimaryButtonStyle())

                    Button("Skip") {
                        if viewModel.skipCurrentStep() {
                            onComplete()
                        }
                    }
                    .buttonStyle(RiseSecondaryButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 22)
            }
            .padding(.top, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
