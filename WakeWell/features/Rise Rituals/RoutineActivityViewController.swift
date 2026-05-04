// RoutineActivityViewController.swift — SetSail
// Base class for all activity runner screens. Logic unchanged.

import UIKit

class RoutineActivityViewController: UIViewController {

    var routineQueue:  [Activity] = []
    var currentIndex:  Int        = 0
    var activity:      Activity?

    func navigateToNextActivity() {
        if currentIndex < routineQueue.count - 1 {
            let next = routineQueue[currentIndex + 1]
            let vc   = ActivityRunnerFactory.makeViewController(
                for:           next,
                routineQueue:  routineQueue,
                currentIndex:  currentIndex + 1
            )
            navigationController?.pushViewController(vc, animated: true)
        } else {
            // Routine complete — pop back to Rise tab root
            navigationController?.popToRootViewController(animated: true)
        }
    }
}
