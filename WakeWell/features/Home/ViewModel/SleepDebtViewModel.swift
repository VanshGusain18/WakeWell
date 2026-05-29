import Foundation

final class SleepDebtViewModel {

    enum Tone: Equatable {
        case positive
        case negative
        case neutral
        case empty
    }

    struct CardState {
        let valueText: String
        let trendText: String?
        let insightText: String
        let tone: Tone
    }

    private let model: SleepDebtModel
    private let targetSleepHours = 8.0

    init(model: SleepDebtModel) {
        self.model = model
    }

    var cardState: CardState {
        guard let todaySleep = model.todaySleepDuration else {
            return CardState(
                valueText: "No sleep data yet",
                trendText: nil,
                insightText: "Wear your Apple Watch tonight and SetSail will start building your sleep debt trend.",
                tone: .empty
            )
        }

        let todayDebt = sleepDebt(for: todaySleep)
        let todayValueText = "\(formatDuration(todayDebt)) Sleep Debt"

        guard let yesterdaySleep = model.yesterdaySleepDuration else {
            return CardState(
                valueText: todayValueText,
                trendText: nil,
                insightText: todayDebt == 0
                    ? "Your sleep duration met your target last night."
                    : "A few more tracked nights will help SetSail understand your normal rhythm.",
                tone: todayDebt == 0 ? .positive : .neutral
            )
        }

        let yesterdayDebt = sleepDebt(for: yesterdaySleep)
        guard let comparison = MetricTrendEvaluator.evaluate(
            current: todayDebt,
            previous: yesterdayDebt,
            preference: .lowerIsBetter
        ) else {
            return CardState(
                valueText: todayValueText,
                trendText: nil,
                insightText: todayDebt == 0
                    ? "Your sleep duration met your target last night."
                    : "A few more tracked nights will help SetSail understand your normal rhythm.",
                tone: todayDebt == 0 ? .positive : .neutral
            )
        }

        if todayDebt == 0 {
            return CardState(
                valueText: todayValueText,
                trendText: "\(comparison.arrowSymbol) Ideal target reached",
                insightText: positiveZeroDebtInsight(seed: model.sleepHistory.count),
                tone: .positive
            )
        }

        switch comparison.direction {
        case .improving:
            return CardState(
                valueText: todayValueText,
                trendText: "\(comparison.arrowSymbol) Better than yesterday",
                insightText: positiveInsight(seed: todayDebt),
                tone: .positive
            )
        case .declining:
            return CardState(
                valueText: todayValueText,
                trendText: "\(comparison.arrowSymbol) Higher than yesterday",
                insightText: negativeInsight(seed: model.sleepHistory.count),
                tone: .negative
            )
        case .neutral:
            return CardState(
                valueText: todayValueText,
                trendText: "\(comparison.arrowSymbol) Stable",
                insightText: neutralInsight(seed: model.sleepHistory.count),
                tone: .neutral
            )
        }
    }

    private func sleepDebt(for sleepHours: Double) -> Double {
        max(0, targetSleepHours - sleepHours)
    }

    private func formatDuration(_ hours: Double) -> String {
        let totalMinutes = max(0, Int((hours * 60).rounded()))
        let wholeHours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if wholeHours == 0 {
            return "\(minutes)m"
        }

        if minutes == 0 {
            return "\(wholeHours)h"
        }

        return "\(wholeHours)h \(minutes)m"
    }

    private func positiveZeroDebtInsight(seed: Int) -> String {
        let options = [
            "Your recent sleep met your target, which may help the morning feel steadier.",
            "No sleep debt detected from your latest tracked night.",
            "Your sleep duration supported recovery last night."
        ]
        return pick(options, seed: Double(seed))
    }

    private func positiveInsight(seed: Double) -> String {
        let options = [
            "You slept closer to your ideal range.",
            "Your recent sleep debt eased compared with yesterday.",
            "You recovered more sleep overnight.",
            "Your sleep duration improved gently.",
            "Your rhythm is moving in a better direction."
        ]
        return pick(options, seed: seed)
    }

    private func negativeInsight(seed: Int) -> String {
        let options = [
            "You may feel more drained today because sleep was shorter than usual.",
            "Last night landed below your ideal range.",
            "A calmer wind-down tonight may help you recover.",
            "Your sleep duration dipped compared with yesterday."
        ]
        return pick(options, seed: Double(seed))
    }

    private func neutralInsight(seed: Int) -> String {
        let options = [
            "Your sleep rhythm stayed close to yesterday.",
            "Your sleep duration remained steady.",
            "No major shift from your previous tracked night."
        ]
        return pick(options, seed: Double(seed))
    }

    private func pick(_ options: [String], seed: Double) -> String {
        guard !options.isEmpty else { return "" }
        let index = abs(Int(seed.rounded())) % options.count
        return options[index]
    }
}
