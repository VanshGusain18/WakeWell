import SwiftUI

struct RitualPreviewView: View {
    @ObservedObject var viewModel: RiseRitualFeatureViewModel
    let onStart: () -> Void

    var body: some View {
        ZStack {
            RiseRitualBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.currentRitual?.title ?? "Rise Ritual")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        if let ritual = viewModel.currentRitual {
                            Text("\(ritual.totalDuration) min • \(ritual.blocks.count) steps")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color(riseHex: "#FFD36A"))
                        }
                    }

                    VStack(spacing: 12) {
                        ForEach(viewModel.currentRitual?.blocks ?? []) { block in
                            RitualBlockCard(block: block)
                        }
                    }

                    VStack(spacing: 10) {
                        Button("Start Ritual") {
                            onStart()
                        }
                        .buttonStyle(RisePrimaryButtonStyle())

                        HStack(spacing: 10) {
                            Button {
                                viewModel.shuffleOneBlock()
                            } label: {
                                Label("Shuffle Block", systemImage: "shuffle")
                            }
                            .buttonStyle(RiseSecondaryButtonStyle())

                            Button {
                                viewModel.shuffleAll()
                            } label: {
                                Label("Shuffle All", systemImage: "arrow.triangle.2.circlepath")
                            }
                            .buttonStyle(RiseSecondaryButtonStyle())
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 34)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
