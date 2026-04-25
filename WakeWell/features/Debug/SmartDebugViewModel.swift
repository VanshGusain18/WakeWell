import Combine
import Foundation

final class SmartDebugViewModel: ObservableObject {

    @Published private(set) var snapshot: SmartAlarmDebugSnapshot

    private var cancellables = Set<AnyCancellable>()

    init() {
        snapshot = SmartAlarmEngine.shared.debugSnapshot

        NotificationCenter.default.publisher(for: .smartAlarmDebugDidUpdate)
            .compactMap { $0.object as? SmartAlarmDebugSnapshot }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.snapshot = snapshot
            }
            .store(in: &cancellables)
    }

    func clear() {
        WatchDataManager.shared.resetDemoEnvironment()
    }
}
