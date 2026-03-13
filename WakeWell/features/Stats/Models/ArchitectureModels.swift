//
//  ArchitectureModels.swift
//  WakeWell
//
//  Created by geu on 12/03/26.
//

import Foundation

struct SleepArchitecture {

    let deepSleep: Double
    let remSleep: Double
    let lightSleep: Double

    static func sampleData() -> SleepArchitecture {

        return SleepArchitecture(
            deepSleep: 22,
            remSleep: 18,
            lightSleep: 60
        )
    }
}
