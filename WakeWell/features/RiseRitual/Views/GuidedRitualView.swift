import SwiftUI

struct GuidedRitualView: View {
    @ObservedObject var viewModel: RiseRitualFeatureViewModel

    var body: some View {
        ZStack {
            RiseRitualBackground()

            VStack(spacing: 26) {
                VStack(spacing: 10) {
                    ProgressView(value: viewModel.ritualProgress)
                        .tint(Color(riseHex: "#FFD36A"))

                    HStack {
                        Text("Step \(viewModel.currentStepIndex + 1)")
                        Spacer()
                        Text("\(viewModel.elapsedSeconds)s elapsed")
                        Text(viewModel.timerText)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.72))
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 12)

                if let block = viewModel.currentBlock {
                    VStack(spacing: 18) {
                        ZStack {
                            Circle()
                                .stroke(.white.opacity(0.12), lineWidth: 10)
                            Circle()
                                .trim(from: 0, to: min(viewModel.blockProgress, 1))
                                .stroke(
                                    Color(riseHex: "#FFD36A"),
                                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 0.2), value: viewModel.blockProgress)

                            Image(systemName: block.sfSymbol)
                                .font(.system(size: 54, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 118, height: 118)
                                .background(
                                    LinearGradient(colors: block.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(Circle())
                                .padding(18)
                        }
                        .frame(width: 170, height: 170)

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
                        viewModel.markCurrentStepDone()
                    }
                    .buttonStyle(RisePrimaryButtonStyle())

                    Button("Skip") {
                        viewModel.skipCurrentStep()
                    }
                    .buttonStyle(RiseSecondaryButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 22)
            }
            .padding(.top, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            if viewModel.sessionState != .inProgress {
                viewModel.cancelTimer()
            }
        }
    }
}
