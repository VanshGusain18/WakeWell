import Foundation

final class MetricDataProvider {

    static func weeklyData(for metric: SleepMetricType) -> [MetricData] {

        switch metric {

        case .duration:
            return [
                MetricData(day: "Mon", value: MetricValue(raw: 6.5)),
                MetricData(day: "Tue", value: MetricValue(raw: 7.2)),
                MetricData(day: "Wed", value: MetricValue(raw: 5.8)),
                MetricData(day: "Thu", value: MetricValue(raw: 8.0)),
                MetricData(day: "Fri", value: MetricValue(raw: 6.9)),
                MetricData(day: "Sat", value: MetricValue(raw: 7.5)),
                MetricData(day: "Sun", value: MetricValue(raw: 8.3))
            ]

        case .efficiency:
            return [
                MetricData(day: "Mon", value: MetricValue(raw: 85)),
                MetricData(day: "Tue", value: MetricValue(raw: 88)),
                MetricData(day: "Wed", value: MetricValue(raw: 82)),
                MetricData(day: "Thu", value: MetricValue(raw: 90)),
                MetricData(day: "Fri", value: MetricValue(raw: 87)),
                MetricData(day: "Sat", value: MetricValue(raw: 92)),
                MetricData(day: "Sun", value: MetricValue(raw: 94))
            ]

        case .architecture:
            return [
                MetricData(day: "Mon", value: MetricValue(raw: 65)),
                MetricData(day: "Tue", value: MetricValue(raw: 70)),
                MetricData(day: "Wed", value: MetricValue(raw: 68)),
                MetricData(day: "Thu", value: MetricValue(raw: 75)),
                MetricData(day: "Fri", value: MetricValue(raw: 72)),
                MetricData(day: "Sat", value: MetricValue(raw: 78)),
                MetricData(day: "Sun", value: MetricValue(raw: 80))
            ]

        case .continuity:
            return [
                MetricData(day: "Mon", value: MetricValue(raw: 80)),
                MetricData(day: "Tue", value: MetricValue(raw: 82)),
                MetricData(day: "Wed", value: MetricValue(raw: 78)),
                MetricData(day: "Thu", value: MetricValue(raw: 85)),
                MetricData(day: "Fri", value: MetricValue(raw: 83)),
                MetricData(day: "Sat", value: MetricValue(raw: 88)),
                MetricData(day: "Sun", value: MetricValue(raw: 90))
            ]

        case .calmness:
            return [
                MetricData(day: "Mon", value: MetricValue(raw: 72)),
                MetricData(day: "Tue", value: MetricValue(raw: 68)),
                MetricData(day: "Wed", value: MetricValue(raw: 70)),
                MetricData(day: "Thu", value: MetricValue(raw: 78)),
                MetricData(day: "Fri", value: MetricValue(raw: 74)),
                MetricData(day: "Sat", value: MetricValue(raw: 80)),
                MetricData(day: "Sun", value: MetricValue(raw: 82))
            ]

        case .consistency:
            return [
                MetricData(day: "Mon", value: MetricValue(raw: 60)),
                MetricData(day: "Tue", value: MetricValue(raw: 65)),
                MetricData(day: "Wed", value: MetricValue(raw: 62)),
                MetricData(day: "Thu", value: MetricValue(raw: 68)),
                MetricData(day: "Fri", value: MetricValue(raw: 70)),
                MetricData(day: "Sat", value: MetricValue(raw: 75)),
                MetricData(day: "Sun", value: MetricValue(raw: 78))
            ]
        }
    }
}
