import SwiftUI

struct RiseRitualRootView: View {
    @StateObject private var viewModel = RiseRitualFeatureViewModel()

    var body: some View {
        ZStack {
            switch viewModel.screen {
            case .mood:
                MoodSelectionView(viewModel: viewModel)
                    .transition(.opacity)
            case .carousel:
                RitualCarouselView(viewModel: viewModel)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .guided:
                GuidedRitualView(viewModel: viewModel)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .completion:
                RitualCompletionView(viewModel: viewModel)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: String(describing: viewModel.screen))
    }
}
