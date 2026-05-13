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
                insightText: "Track sleep regularly to unlock trend insights.",
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
                    ? "You reached your ideal sleep target tonight."
                    : "Track sleep regularly to unlock trend insights.",
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
                    ? "You reached your ideal sleep target tonight."
                    : "Track sleep regularly to unlock trend insights.",
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
            "You reached your ideal sleep target tonight.",
            "No sleep debt detected.",
            "Your recovery sleep was excellent."
        ]
        return pick(options, seed: Double(seed))
    }

    private func positiveInsight(seed: Double) -> String {
        let options = [
            "You slept closer to your ideal range.",
            "Your sleep debt decreased from yesterday.",
            "You recovered more sleep tonight.",
            "Your sleep duration improved overnight.",
            "You are moving toward healthier sleep duration."
        ]
        return pick(options, seed: seed)
    }

    private func negativeInsight(seed: Int) -> String {
        let options = [
            "Your sleep debt increased tonight.",
            "You slept below your ideal range.",
            "You may need more recovery sleep.",
            "Your sleep duration dropped compared to yesterday."
        ]
        return pick(options, seed: Double(seed))
    }

    private func neutralInsight(seed: Int) -> String {
        let options = [
            "Your sleep debt stayed similar to yesterday.",
            "Your sleep duration remained stable.",
            "No major change from your previous night."
        ]
        return pick(options, seed: Double(seed))
    }

    private func pick(_ options: [String], seed: Double) -> String {
        guard !options.isEmpty else { return "" }
        let index = abs(Int(seed.rounded())) % options.count
        return options[index]
    }
}
