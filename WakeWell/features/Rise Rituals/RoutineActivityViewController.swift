//
//  RoutineActivityViewController.swift
//  WakeWell
//

import UIKit

class RoutineActivityViewController: UIViewController {

    var routineQueue: [Activity] = []
    var currentIndex: Int = 0
    var activity: Activity?

    func navigateToNextActivity() {
        if currentIndex < routineQueue.count - 1 {
            let nextActivity = routineQueue[currentIndex + 1]
            let nextViewController = ActivityRunnerFactory.makeViewController(
                for: nextActivity,
                routineQueue: routineQueue,
                currentIndex: currentIndex + 1
            )
            navigationController?.pushViewController(nextViewController, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
}
