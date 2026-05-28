import SwiftUI

struct RitualCarouselView: View {
    @ObservedObject var viewModel: RiseRitualFeatureViewModel

    var body: some View {
        ZStack {
            RiseRitualStyle.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                RiseRitualTopBar(
                    title: viewModel.currentRitual?.title ?? "Rise Ritual",
                    subtitle: viewModel.currentRitual.map { "\($0.totalDuration) min ritual" },
                    leadingSystemImage: "chevron.left",
                    onLeadingTap: viewModel.backToMoodSelection
                )

                Spacer(minLength: 12)

                TabView(selection: $viewModel.currentCardIndex) {
                    ForEach(Array((viewModel.currentRitual?.blocks ?? []).enumerated()), id: \.element.id) { index, block in
                        ActivityCard(block: block, index: index)
                            .padding(.horizontal, 28)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: 430)

                PageDots(
                    count: viewModel.currentRitual?.blocks.count ?? 0,
                    current: viewModel.currentCardIndex
                )
                .padding(.top, 12)

                Spacer(minLength: 12)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                Button("Start Ritual") {
                    viewModel.startRitualFlow()
                }
                .buttonStyle(RiseRitualPrimaryButton())

                HStack(spacing: 10) {
                    Button("Shuffle") {
                        viewModel.shuffleCurrentCard()
                    }
                    .buttonStyle(RiseRitualSecondaryButton())

                    Button("Shuffle All") {
                        viewModel.shuffleAllCards()
                    }
                    .buttonStyle(RiseRitualSecondaryButton())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 12)
            .background(.ultraThinMaterial.opacity(0.4))
        }
    }
}

private struct ActivityCard: View {
    let block: RitualBlock
    let index: Int

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: block.sfSymbol)
                .font(RiseRitualStyle.bodyFont(size: 76, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 146, height: 146)
                .background(
                    LinearGradient(colors: RiseRitualStyle.gradient(for: index), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 42, style: .continuous))
                .shadow(color: RiseRitualStyle.shadow.opacity(0.16), radius: 18, x: 0, y: 12)

            VStack(spacing: 10) {
                Text(block.title)
                    .font(RiseRitualStyle.titleFont(size: 34))
                    .foregroundStyle(RiseRitualStyle.text)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
                Text(block.subtitle)
                    .font(RiseRitualStyle.bodyFont(size: 18))
                    .foregroundStyle(RiseRitualStyle.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            Text("\(block.duration) min")
                .font(RiseRitualStyle.bodyFont(size: 15, weight: .bold))
                .foregroundStyle(RiseRitualStyle.gold)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(RiseRitualStyle.gold.opacity(0.12))
                .clipShape(Capsule())

            Spacer()
        }
        .padding(26)
        .frame(maxWidth: .infinity, minHeight: 390)
        .background(RiseRitualStyle.card)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(RiseRitualStyle.border, lineWidth: 1)
        )
        .shadow(color: RiseRitualStyle.shadow.opacity(0.1), radius: 22, x: 0, y: 14)
    }
}

private struct PageDots: View {
    let count: Int
    let current: Int

    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<max(count, 0), id: \.self) { index in
                Capsule()
                    .fill(index == current ? RiseRitualStyle.purple : RiseRitualStyle.border)
                    .frame(width: index == current ? 20 : 7, height: 7)
                    .animation(.easeInOut(duration: 0.18), value: current)
            }
        }
    }
}
