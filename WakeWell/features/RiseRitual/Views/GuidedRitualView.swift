import SwiftUI

struct GuidedRitualView: View {
    @ObservedObject var viewModel: RiseRitualFeatureViewModel
    @State private var tapCount = 0
    @State private var completedPrompts: Set<String> = []
    @State private var promptResponses: [String: String] = [:]

    var body: some View {
        ZStack {
            RiseRitualStyle.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                RiseRitualTopBar(
                    title: "Guided Ritual",
                    subtitle: "Stay with the ritual",
                    leadingSystemImage: "xmark",
                    trailingText: stepText,
                    onLeadingTap: viewModel.backToCarousel
                )

                GuidedTimerHeader(timerText: viewModel.timerText, progress: viewModel.progress)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    if let block = viewModel.currentBlock {
                        VStack(spacing: 22) {
                            Image(systemName: block.sfSymbol)
                                .font(RiseRitualStyle.bodyFont(size: 68, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 132, height: 132)
                                .background(
                                    LinearGradient(colors: RiseRitualStyle.gradient(for: viewModel.currentCardIndex), startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 38, style: .continuous))
                                .shadow(color: RiseRitualStyle.shadow.opacity(0.14), radius: 16, x: 0, y: 10)

                            VStack(spacing: 10) {
                                Text(block.title)
                                    .font(RiseRitualStyle.titleFont(size: 34))
                                    .foregroundStyle(RiseRitualStyle.text)
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.75)

                                Text(block.subtitle)
                                    .font(RiseRitualStyle.bodyFont(size: 17))
                                    .foregroundStyle(RiseRitualStyle.secondaryText)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(3)
                            }
                            .padding(.horizontal, 24)

                            InteractionPanel(
                                block: block,
                                tapCount: $tapCount,
                                completedPrompts: $completedPrompts,
                                promptResponses: $promptResponses
                            )

                            InstructionSteps(steps: block.detailedInstructions)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 110)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .onChange(of: viewModel.currentBlock?.id) { _, _ in
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
        promptResponses.removeAll()
    }
}

private struct GuidedTimerHeader: View {
    let timerText: String
    let progress: Double

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Time remaining")
                        .font(RiseRitualStyle.bodyFont(size: 12, weight: .semibold))
                        .foregroundStyle(RiseRitualStyle.secondaryText)
                    Text(timerText)
                        .font(RiseRitualStyle.titleFont(size: 30))
                        .foregroundStyle(RiseRitualStyle.purple)
                }

                Spacer()

                Image(systemName: "timer")
                    .font(RiseRitualStyle.headlineFont(size: 24))
                    .foregroundStyle(RiseRitualStyle.gold)
                    .frame(width: 46, height: 46)
                    .background(RiseRitualStyle.gold.opacity(0.12))
                    .clipShape(Circle())
            }

            ProgressView(value: progress)
                .tint(RiseRitualStyle.gold)
        }
        .padding(16)
        .background(.ultraThinMaterial.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(RiseRitualStyle.border, lineWidth: 1)
        )
    }
}

private struct InteractionPanel: View {
    let block: RitualBlock
    @Binding var tapCount: Int
    @Binding var completedPrompts: Set<String>
    @Binding var promptResponses: [String: String]

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
                PromptEntryPanel(prompts: prompts, responses: $promptResponses)
            case .mentalActivation:
                MentalActivationPanel(prompt: prompts.first ?? "Count backward from 20 by 2s.", responses: $promptResponses)
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
                    .font(RiseRitualStyle.titleFont(size: 44))
                Text("Tap to \(target)")
                    .font(RiseRitualStyle.bodyFont(size: 14, weight: .semibold))
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
                    .font(RiseRitualStyle.headlineFont(size: 18))
                    .foregroundStyle(RiseRitualStyle.purple)
            }
            .animation(.easeInOut(duration: 3.4).repeatForever(autoreverses: true), value: expanded)

            Text("Follow the pulse. Let the exhale feel unhurried.")
                .font(RiseRitualStyle.bodyFont(size: 14))
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
                            .font(RiseRitualStyle.bodyFont(size: 22, weight: .semibold))
                            .foregroundStyle(completedPrompts.contains(prompt) ? RiseRitualStyle.gold : RiseRitualStyle.secondaryText)
                        Text(prompt)
                            .font(RiseRitualStyle.bodyFont(size: 15, weight: .semibold))
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

private struct PromptEntryPanel: View {
    let prompts: [String]
    @Binding var responses: [String: String]
    @FocusState private var focusedPrompt: String?

    var body: some View {
        VStack(spacing: 12) {
            ForEach(prompts, id: \.self) { prompt in
                VStack(alignment: .leading, spacing: 8) {
                    Text(prompt)
                        .font(RiseRitualStyle.bodyFont(size: 14, weight: .semibold))
                        .foregroundStyle(RiseRitualStyle.secondaryText)

                    TextField("Type a short response", text: binding(for: prompt), axis: .vertical)
                        .font(RiseRitualStyle.bodyFont(size: 16))
                        .foregroundStyle(RiseRitualStyle.text)
                        .lineLimit(1...3)
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(.next)
                        .focused($focusedPrompt, equals: prompt)
                        .padding(12)
                        .background(RiseRitualStyle.elevated)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(focusedPrompt == prompt ? RiseRitualStyle.purple.opacity(0.65) : RiseRitualStyle.border, lineWidth: 1)
                        )
                }
            }
        }
    }

    private func binding(for prompt: String) -> Binding<String> {
        Binding(
            get: { responses[prompt, default: ""] },
            set: { responses[prompt] = $0 }
        )
    }
}

private struct MentalActivationPanel: View {
    let prompt: String
    @Binding var responses: [String: String]
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(RiseRitualStyle.bodyFont(size: 32, weight: .semibold))
                .foregroundStyle(RiseRitualStyle.gold)
            Text(prompt)
                .font(RiseRitualStyle.headlineFont(size: 18))
                .foregroundStyle(RiseRitualStyle.text)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            TextField("Your answer", text: Binding(
                get: { responses[prompt, default: ""] },
                set: { responses[prompt] = $0 }
            ), axis: .vertical)
            .font(RiseRitualStyle.bodyFont(size: 16))
            .foregroundStyle(RiseRitualStyle.text)
            .lineLimit(1...3)
            .focused($focused)
            .padding(12)
            .background(RiseRitualStyle.elevated)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            Text("Do it quietly. You only need enough effort to wake the mind.")
                .font(RiseRitualStyle.bodyFont(size: 14))
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
                .font(RiseRitualStyle.titleFont(size: 42))
                .foregroundStyle(RiseRitualStyle.purple)
            Text("clean reps")
                .font(RiseRitualStyle.bodyFont(size: 15, weight: .bold))
                .foregroundStyle(RiseRitualStyle.secondaryText)
            Text("Do the movement, then press Done. Keep it light enough to feel good.")
                .font(RiseRitualStyle.bodyFont(size: 14))
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
            .font(RiseRitualStyle.bodyFont(size: 15, weight: .semibold))
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
                        .font(RiseRitualStyle.bodyFont(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(RiseRitualStyle.purple)
                        .clipShape(Circle())

                    Text(step)
                        .font(RiseRitualStyle.bodyFont(size: 15))
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
