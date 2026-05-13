import Foundation
import UIKit

struct SleepRingViewModel {

    let scoreText: String
    let subtitleText: String
    let progress: CGFloat
    let hasData: Bool

    init(model: SleepRingModel) {
        self.hasData = model.score != nil
        self.scoreText = model.score.map(String.init) ?? "—"
        self.subtitleText = model.subtitle
        self.progress = CGFloat(model.score ?? 0) / 100
    }
}
