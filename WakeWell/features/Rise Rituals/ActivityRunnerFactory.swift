//  ActivityRunnerFactory.swift — SetSail
//  Instantiates the correct runner VC for each activity.
//  No storyboard references — everything is programmatic.

import UIKit

enum ActivityRunnerFactory {

    static func makeViewController(
        for activity: Activity,
        routineQueue: [Activity],
        currentIndex: Int
    ) -> UIViewController {

        let viewController: RoutineActivityViewController

        switch activity.id {
        case "ritual_3":   // Box Breathing (was ritual_5 in original)
            viewController = BoxBreathingViewController()
        case "ritual_9":   // Short Walk
            viewController = ShortWalkActivityViewController()
        case "ritual_11":  // Reaction Taps (was ritual_12 in original)
            viewController = ReactionTapViewController()
        default:
            if activity.activityType == .timerBased {
                // Instantiate directly — no storyboard needed
                viewController = ActivityDetailViewController()
            } else {
                viewController = ActivityInstructionViewController()
            }
        }

        viewController.activity     = activity
        viewController.routineQueue = routineQueue
        viewController.currentIndex = currentIndex
        return viewController
    }
}
