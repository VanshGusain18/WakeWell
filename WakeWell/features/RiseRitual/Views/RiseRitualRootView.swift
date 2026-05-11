import SwiftUI

struct RiseRitualRootView: View {
    @StateObject private var viewModel = RiseRitualFeatureViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.sessionState {
                case .idle, .selectingMood:
                    MoodSelectionView(viewModel: viewModel) { mood in
                        viewModel.beginGeneration(for: mood)
                    }
                    .transition(.opacity)

                case .generating:
                    RitualLoadingView()
                        .transition(.opacity)

                case .preview:
                    RitualPreviewView(viewModel: viewModel)
                        .transition(.move(edge: .trailing).combined(with: .opacity))

                case .inProgress:
                    GuidedRitualView(viewModel: viewModel)
                        .transition(.move(edge: .trailing).combined(with: .opacity))

                case .completed:
                    RitualCompletionView(viewModel: viewModel)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.22), value: viewModel.sessionState)
        }
    }
}
