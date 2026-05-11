import SwiftUI

struct RiseRitualRootView: View {
    @StateObject private var viewModel = RiseRitualFeatureViewModel()
    @State private var route: RiseRitualRoute?

    var body: some View {
        NavigationStack {
            MoodSelectionView(viewModel: viewModel) { mood in
                route = .loading
                viewModel.beginGeneration(for: mood) {
                    route = .preview
                }
            }
            .navigationDestination(item: $route) { destination in
                switch destination {
                case .loading:
                    RitualLoadingView()

                case .preview:
                    RitualPreviewView(viewModel: viewModel) {
                        route = .guided
                    }

                case .guided:
                    GuidedRitualView(viewModel: viewModel) {
                        viewModel.resetCompletionInput()
                        route = .completion
                    }

                case .completion:
                    RitualCompletionView(viewModel: viewModel) {
                        route = nil
                    }
                }
            }
        }
    }
}

private enum RiseRitualRoute: Hashable, Identifiable {
    case loading
    case preview
    case guided
    case completion

    var id: String {
        switch self {
        case .loading: return "loading"
        case .preview: return "preview"
        case .guided: return "guided"
        case .completion: return "completion"
        }
    }
}
