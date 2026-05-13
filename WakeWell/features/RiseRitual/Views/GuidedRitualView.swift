import SwiftUI

struct GuidedRitualView: View {
    @ObservedObject var viewModel: RiseRitualFeatureViewModel

    var body: some View {
        ZStack {
            RiseRitualStyle.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                RiseRitualTopBar(
                    title: "Guided Ritual",
                    subtitle: viewModel.timerText,
                    leadingSystemImage: "xmark",
                    trailingText: stepText,
                    onLeadingTap: viewModel.backToCarousel
                )

                ProgressView(value: viewModel.progress)
                    .tint(RiseRitualStyle.gold)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                Spacer(minLength: 24)

                if let block = viewModel.currentBlock {
                    VStack(spacing: 26) {
                        Image(systemName: block.sfSymbol)
                            .font(.system(size: 78, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 154, height: 154)
                            .background(
                                LinearGradient(colors: RiseRitualStyle.gradient(for: viewModel.currentCardIndex), startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))

                        VStack(spacing: 12) {
                            Text(block.title)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(RiseRitualStyle.text)
                                .multilineTextAlignment(.center)
                            Text(block.subtitle)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(RiseRitualStyle.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)

                        Text(viewModel.timerText)
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(RiseRitualStyle.purple)
                    }
                }

                Spacer(minLength: 20)
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button("Skip") {
                    viewModel.skipCurrentBlock()
                }
                .buttonStyle(RiseRitualSecondaryButton())

                Button("Done") {
                    viewModel.completeCurrentBlock()
                }
                .buttonStyle(RiseRitualPrimaryButton())
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(.ultraThinMaterial.opacity(0.4))
        }
    }

    private var stepText: String {
        let total = viewModel.currentRitual?.blocks.count ?? 0
        return "\(min(viewModel.currentCardIndex + 1, max(total, 1))) of \(max(total, 1))"
    }
}
