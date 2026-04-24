//
//  ActivityRunnerFactory.swift
//  WakeWell
//

import UIKit

enum ActivityRunnerFactory {

    static func makeViewController(
        for activity: Activity,
        routineQueue: [Activity],
        currentIndex: Int
    ) -> UIViewController {
        let viewController: RoutineActivityViewController

        switch activity.id {
        case "ritual_5":
            viewController = BoxBreathingViewController()
        case "ritual_9":
            viewController = ShortWalkActivityViewController()
        case "ritual_12":
            viewController = ReactionTapViewController()
        default:
            if activity.activityType == .timerBased {
                let storyboard = UIStoryboard(name: "Rise", bundle: nil)
                viewController = storyboard.instantiateViewController(
                    withIdentifier: "ActivityDetailViewController"
                ) as! ActivityDetailViewController
            } else {
                viewController = ActivityInstructionViewController()
            }
        }

        viewController.activity = activity
        viewController.routineQueue = routineQueue
        viewController.currentIndex = currentIndex
        return viewController
    }
}
