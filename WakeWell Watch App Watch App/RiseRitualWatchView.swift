import SwiftUI

struct RiseRitualWatchView: View {
    let autoStart: Bool
    private let rituals = WatchRiseRitualLibrary.rituals
    @State private var featuredRitualID = WatchRiseRitualLibrary.rituals.first?.id
    @State private var showSession = false

    init(autoStart: Bool = false) {
        self.autoStart = autoStart
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                header

                if let featuredRitual {
                    FeaturedRitualCard(ritual: featuredRitual)
                }

                Text("Choose Ritual")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(WatchTheme.secondaryText)

                ForEach(rituals) { ritual in
                    RitualRow(
                        ritual: ritual,
                        isSelected: ritual.id == featuredRitualID
                    ) {
                        featuredRitualID = ritual.id
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 10)
        }
        .navigationTitle("Rise")
        .background(WatchTheme.background)
        .containerBackground(WatchTheme.background.gradient, for: .navigation)
        .navigationDestination(isPresented: $showSession) {
            RiseRitualSessionView(ritual: featuredRitual ?? rituals[0], initialRunning: true)
        }
        .onAppear {
            guard autoStart else { return }
            featuredRitualID = rituals.first?.id
            showSession = true
        }
    }

    private var featuredRitual: WatchRiseRitual? {
        rituals.first { $0.id == featuredRitualID } ?? rituals.first
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Image(systemName: "sunrise.fill")
                    .foregroundStyle(WatchTheme.gold)
                Text("Rise Ritual")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(WatchTheme.primaryText)
            }

            Text("Start your day healthily")
                .font(.caption2)
                .foregroundStyle(WatchTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct FeaturedRitualCard: View {
    let ritual: WatchRiseRitual

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(WatchTheme.gold.opacity(0.2))
                    Image(systemName: ritual.iconName)
                        .font(.system(size: 21, weight: .semibold))
                        .foregroundStyle(WatchTheme.gold)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(ritual.title)
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(WatchTheme.primaryText)

                    Text(ritual.subtitle)
                        .font(.caption2)
                        .foregroundStyle(WatchTheme.secondaryText)
                        .lineLimit(2)
                }
            }

            HStack(spacing: 6) {
                Label(ritual.durationText, systemImage: "timer")
                Label("\(ritual.steps.count) steps", systemImage: "list.bullet")
            }
            .font(.caption2.weight(.semibold))
            .foregroundStyle(WatchTheme.secondaryText)

            NavigationLink {
                RiseRitualSessionView(ritual: ritual)
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Ritual")
                        .fontWeight(.bold)
                }
                .font(.caption)
                .foregroundStyle(WatchTheme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(WatchTheme.gold)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            LinearGradient(
                colors: [WatchTheme.card, WatchTheme.purple.opacity(0.36)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(WatchTheme.gold.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct RitualRow: View {
    let ritual: WatchRiseRitual
    let isSelected: Bool
    let onSelect: () -> Void
    @State private var isExpanded = false

    var body: some View {
        Button {
            onSelect()
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ? WatchTheme.gold.opacity(0.22) : WatchTheme.purple.opacity(0.22))
                    Image(systemName: ritual.iconName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isSelected ? WatchTheme.gold : WatchTheme.secondaryText)
                }
                .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 3) {
                    Text(ritual.title)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundStyle(WatchTheme.primaryText)
                        .lineLimit(1)

                    if isExpanded {
                        Text(ritual.subtitle)
                            .font(.caption2)
                            .foregroundStyle(WatchTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isSelected ? WatchTheme.gold : WatchTheme.secondaryText)
            }
            .padding(10)
            .background(isSelected ? WatchTheme.card.opacity(1) : WatchTheme.card.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? WatchTheme.gold.opacity(0.28) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct RiseRitualSessionView: View {
    let ritual: WatchRiseRitual
    @State private var currentStep = 0
    @State private var isRunning: Bool

    init(ritual: WatchRiseRitual, initialRunning: Bool = false) {
        self.ritual = ritual
        _isRunning = State(initialValue: initialRunning)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ritual.title)
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(WatchTheme.primaryText)

                    Text(isRunning ? "In progress" : "Ready")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(isRunning ? WatchTheme.gold : WatchTheme.secondaryText)
                }

                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(value: Double(currentStep + 1), total: Double(ritual.steps.count))
                        .tint(WatchTheme.gold)

                    Text("Step \(currentStep + 1) of \(ritual.steps.count)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(WatchTheme.secondaryText)

                    Text(ritual.steps[currentStep])
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundStyle(WatchTheme.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(WatchTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                HStack(spacing: 8) {
                    Button {
                        isRunning.toggle()
                    } label: {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(WatchTheme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(WatchTheme.gold)
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        if currentStep < ritual.steps.count - 1 {
                            currentStep += 1
                            isRunning = true
                        } else {
                            isRunning = false
                            WatchConnectivityManager.shared.stopStreaming()
                        }
                    } label: {
                        Image(systemName: currentStep < ritual.steps.count - 1 ? "arrow.right" : "checkmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(WatchTheme.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(WatchTheme.purple.opacity(0.55))
                            .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }

                ForEach(Array(ritual.steps.enumerated()), id: \.offset) { index, step in
                    StepPreviewRow(index: index, step: step, isCurrent: index == currentStep, isDone: index < currentStep)
                }
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 10)
        }
        .navigationTitle("Start")
        .background(WatchTheme.background)
        .containerBackground(WatchTheme.background.gradient, for: .navigation)
    }
}

private struct StepPreviewRow: View {
    let index: Int
    let step: String
    let isCurrent: Bool
    let isDone: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: isDone ? "checkmark.circle.fill" : "\(index + 1).circle.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(isCurrent || isDone ? WatchTheme.gold : WatchTheme.secondaryText)

            Text(step)
                .font(.caption)
                .foregroundStyle(isCurrent ? WatchTheme.primaryText : WatchTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isCurrent ? WatchTheme.card : WatchTheme.card.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

enum WatchTheme {
    static let background = Color(red: 0.11, green: 0.10, blue: 0.23)
    static let card = Color(red: 0.18, green: 0.17, blue: 0.33)
    static let gold = Color(red: 0.96, green: 0.65, blue: 0.14)
    static let purple = Color(red: 0.42, green: 0.39, blue: 1.00)
    static let primaryText = Color(red: 0.94, green: 0.93, blue: 1.00)
    static let secondaryText = Color(red: 0.62, green: 0.60, blue: 0.75)
}
