//
//  SleepRingViewModel.swift
//  WakeWell
//
//  Created by geu on 13/02/26.
//

import Foundation

struct SleepRingViewModel {

    private let model: SleepRingModel

    init(model: SleepRingModel) {
        self.model = model
    }

    var scoreText: String {
        return "\(model.score)"
    }

    var subtitleText: String {
        return model.subtitle
    }

    var progress: CGFloat {
        return CGFloat(model.score) / 100
    }
}
