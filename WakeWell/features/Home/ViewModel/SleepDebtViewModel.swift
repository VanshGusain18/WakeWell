//
//  SleepDebtViewModel.swift
//  WakeWell
//
import Foundation

class SleepDebtViewModel {

    private let model: SleepDebtModel

    init(model: SleepDebtModel) {
        self.model = model
    }

    // MARK: - Sleep Debt Calculation

    func calculateSleepDebt(requiredSleep: Double = 8.0) -> Double {

        var debt: Double = 0

        for item in model.sleepHistory {

            if item.sleepDuration < requiredSleep {
                debt += (requiredSleep - item.sleepDuration)
            }

        }

        return debt
    }

    // MARK: - Message

    func debtMessage() -> String {

        let debt = calculateSleepDebt()
        if debt == 0 {
            return "Good job you have no sleep debt."
        }

        let formatted = String(format: "%.1f", debt)

        return "You have a sleep debt of \(formatted) hrs"
    }

    // MARK: - Visibility

    func shouldShowCard() -> Bool {
        return calculateSleepDebt() > 0
    }
}
