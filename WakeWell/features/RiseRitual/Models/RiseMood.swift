import SwiftUI

enum RiseMood: String, CaseIterable, Identifiable {
    case foggy
    case lowEnergy
    case distracted
    case restless
    case slowStart

    var id: String { rawValue }

    var title: String {
        switch self {
        case .foggy: return "Foggy"
        case .lowEnergy: return "Low Energy"
        case .distracted: return "Distracted"
        case .restless: return "Restless"
        case .slowStart: return "Slow Start"
        }
    }

    var subtitle: String {
        switch self {
        case .foggy: return "Clear the morning haze."
        case .lowEnergy: return "Build gentle momentum."
        case .distracted: return "Find one clean focus."
        case .restless: return "Settle your system."
        case .slowStart: return "Ease into the day."
        }
    }

    var sfSymbol: String {
        switch self {
        case .foggy: return "cloud.fill"
        case .lowEnergy: return "bolt.slash.fill"
        case .distracted: return "scope"
        case .restless: return "waveform.path.ecg"
        case .slowStart: return "sunrise.fill"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .foggy: return [Color(riseHex: "#8EC5FC"), Color(riseHex: "#E0C3FC")]
        case .lowEnergy: return [Color(riseHex: "#FAD961"), Color(riseHex: "#F76B1C")]
        case .distracted: return [Color(riseHex: "#84FAB0"), Color(riseHex: "#8FD3F4")]
        case .restless: return [Color(riseHex: "#F6D365"), Color(riseHex: "#FDA085")]
        case .slowStart: return [Color(riseHex: "#FF9A9E"), Color(riseHex: "#FECFEF")]
        }
    }
}
