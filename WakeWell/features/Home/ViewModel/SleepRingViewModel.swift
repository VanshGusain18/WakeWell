import Foundation
import UIKit

struct SleepRingViewModel {

    let scoreText: String
    let subtitleText: String
    let progress: CGFloat

    init(model: SleepRingModel) {
        self.scoreText = "\(model.score)"
        self.subtitleText = model.subtitle
        self.progress = CGFloat(model.score) / 100
    }
}
