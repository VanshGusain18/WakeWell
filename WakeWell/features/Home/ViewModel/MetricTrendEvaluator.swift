import Foundation

enum TrendDirection {
    case improving
    case declining
    case neutral
}

enum MetricTrendPreference {
    case higherIsBetter
    case lowerIsBetter
}

struct MetricTrendResult {
    let direction: TrendDirection
    let delta: Double
    let isImproving: Bool

    var arrowSymbol: String {
        switch direction {
        case .improving: return "↑"
        case .declining: return "↓"
        case .neutral: return "→"
        }
    }
}

enum MetricTrendEvaluator {
    static func evaluate(
        current: Double?,
        previous: Double?,
        preference: MetricTrendPreference,
        neutralThresholdMinutes: Double = 15
    ) -> MetricTrendResult? {
        guard let current, let previous else { return nil }

        let delta = current - previous
        let neutralThresholdHours = neutralThresholdMinutes / 60.0

        if abs(delta) < neutralThresholdHours {
            return MetricTrendResult(direction: .neutral, delta: delta, isImproving: false)
        }

        let isImproving: Bool
        switch preference {
        case .higherIsBetter:
            isImproving = current > previous
        case .lowerIsBetter:
            isImproving = current < previous
        }

        return MetricTrendResult(
            direction: isImproving ? .improving : .declining,
            delta: delta,
            isImproving: isImproving
        )
    }
}
