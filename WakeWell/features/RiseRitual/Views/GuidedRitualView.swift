import SwiftUI

struct GuidedRitualView: View {
    @ObservedObject var viewModel: RiseRitualFeatureViewModel
    @State private var tapCount = 0
    @State private var completedPrompts: Set<String> = []

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

                ScrollView(showsIndicators: false) {
                    if let block = viewModel.currentBlock {
                        VStack(spacing: 22) {
                            Image(systemName: block.sfSymbol)
                                .font(.system(size: 68, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 132, height: 132)
                                .background(
                                    LinearGradient(colors: RiseRitualStyle.gradient(for: viewModel.currentCardIndex), startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 38, style: .continuous))
                                .shadow(color: RiseRitualStyle.shadow.opacity(0.14), radius: 16, x: 0, y: 10)

                            VStack(spacing: 10) {
                                Text(block.title)
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundStyle(RiseRitualStyle.text)
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.75)

                                Text(block.subtitle)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundStyle(RiseRitualStyle.secondaryText)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(3)
                            }
                            .padding(.horizontal, 24)

                            InteractionPanel(
                                block: block,
                                tapCount: $tapCount,
                                completedPrompts: $completedPrompts
                            )

                            InstructionSteps(steps: block.detailedInstructions)

                            Text(viewModel.timerText)
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(RiseRitualStyle.purple)
                        }
                        .padding(.top, 24)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 110)
                    }
                }
            }
        }
        .onChange(of: viewModel.currentBlock?.id) { _ in
            resetInteraction()
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button("Skip") {
                    resetInteraction()
                    viewModel.skipCurrentBlock()
                }
                .buttonStyle(RiseRitualSecondaryButton())

                Button("Done") {
                    resetInteraction()
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

    private func resetInteraction() {
        tapCount = 0
        completedPrompts.removeAll()
    }
}

private struct InteractionPanel: View {
    let block: RitualBlock
    @Binding var tapCount: Int
    @Binding var completedPrompts: Set<String>

    var body: some View {
        VStack(spacing: 14) {
            switch block.interactionType {
            case .instruction:
                PassivePanel(text: "Use the timer as a gentle container.")
            case .tapCounter:
                TapCounterPanel(target: max(block.interactionTarget, 12), tapCount: $tapCount)
            case .breathingPacer:
                BreathingPacerPanel()
            case .focusPrompt:
                PromptChecklistPanel(prompts: prompts, completedPrompts: $completedPrompts)
            case .mentalActivation:
                MentalActivationPanel(prompt: prompts.first ?? "Count backward from 20 by 2s.")
            case .bodyActivation:
                BodyActivationPanel(target: max(block.interactionTarget, 8), title: block.title)
            case .grounding:
                PromptChecklistPanel(prompts: prompts, completedPrompts: $completedPrompts)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(RiseRitualStyle.card.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(RiseRitualStyle.border, lineWidth: 1)
        )
    }

    private var prompts: [String] {
        block.interactionPrompts.isEmpty ? ["Notice one thing", "Take one breath", "Choose the next step"] : block.interactionPrompts
    }
}

private struct TapCounterPanel: View {
    let target: Int
    @Binding var tapCount: Int

    var body: some View {
        Button {
            tapCount = min(tapCount + 1, target)
        } label: {
            VStack(spacing: 10) {
                Text("\(tapCount)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                Text("Tap to \(target)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.82))
            }
            .foregroundStyle(.white)
            .frame(width: 138, height: 138)
            .background(
                Circle()
                    .fill(RiseRitualStyle.purple)
                    .overlay(Circle().stroke(.white.opacity(0.22), lineWidth: 1))
            )
            .scaleEffect(tapCount >= target ? 1.04 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.72), value: tapCount)
        }
        .buttonStyle(.plain)

        ProgressView(value: Double(tapCount), total: Double(max(target, 1)))
            .tint(RiseRitualStyle.gold)
    }
}

private struct BreathingPacerPanel: View {
    @State private var expanded = false

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(RiseRitualStyle.purple.opacity(0.12))
                    .frame(width: 142, height: 142)
                    .scaleEffect(expanded ? 1.18 : 0.78)
                Circle()
                    .stroke(RiseRitualStyle.gold.opacity(0.8), lineWidth: 3)
                    .frame(width: 108, height: 108)
                    .scaleEffect(expanded ? 1.16 : 0.82)
                Text(expanded ? "Inhale" : "Exhale")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(RiseRitualStyle.purple)
            }
            .animation(.easeInOut(duration: 3.4).repeatForever(autoreverses: true), value: expanded)

            Text("Follow the pulse. Let the exhale feel unhurried.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(RiseRitualStyle.secondaryText)
                .multilineTextAlignment(.center)
        }
        .onAppear { expanded = true }
    }
}

private struct PromptChecklistPanel: View {
    let prompts: [String]
    @Binding var completedPrompts: Set<String>

    var body: some View {
        VStack(spacing: 10) {
            ForEach(prompts, id: \.self) { prompt in
                Button {
                    if completedPrompts.contains(prompt) {
                        completedPrompts.remove(prompt)
                    } else {
                        completedPrompts.insert(prompt)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: completedPrompts.contains(prompt) ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(completedPrompts.contains(prompt) ? RiseRitualStyle.gold : RiseRitualStyle.secondaryText)
                        Text(prompt)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(RiseRitualStyle.text)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(12)
                    .background(RiseRitualStyle.card.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct MentalActivationPanel: View {
    let prompt: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(RiseRitualStyle.gold)
            Text(prompt)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(RiseRitualStyle.text)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            Text("Do it quietly. You only need enough effort to wake the mind.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(RiseRitualStyle.secondaryText)
                .multilineTextAlignment(.center)
        }
    }
}

private struct BodyActivationPanel: View {
    let target: Int
    let title: String

    var body: some View {
        VStack(spacing: 10) {
            Text("\(target)")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(RiseRitualStyle.purple)
            Text("clean reps")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(RiseRitualStyle.secondaryText)
            Text("Do the movement, then press Done. Keep it light enough to feel good.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(RiseRitualStyle.secondaryText)
                .multilineTextAlignment(.center)
        }
        .accessibilityLabel("\(title), \(target) clean reps")
    }
}

private struct PassivePanel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(RiseRitualStyle.secondaryText)
            .multilineTextAlignment(.center)
            .padding(.vertical, 8)
    }
}

private struct InstructionSteps: View {
    let steps: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(RiseRitualStyle.purple)
                        .clipShape(Circle())

                    Text(step)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(RiseRitualStyle.text)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RiseRitualStyle.card.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(RiseRitualStyle.border, lineWidth: 1)
        )
    }
}
