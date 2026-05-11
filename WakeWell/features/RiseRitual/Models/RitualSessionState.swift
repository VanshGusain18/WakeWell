import Foundation

enum RitualSessionState: Hashable {
    case idle
    case selectingMood
    case generating
    case preview
    case inProgress
    case completed
}
