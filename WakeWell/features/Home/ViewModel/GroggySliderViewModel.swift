import Foundation

struct GroggySliderViewModel {

    let title: String
    let leftLabel: String
    let rightLabel: String
    let value: Float
    let isLocked: Bool
    let hasEntry: Bool

    init(model: GroggyModel) {
        title = "How groggy do you feel?"
        leftLabel = "Fresh"
        rightLabel = "Very Groggy"
        value = model.value
        isLocked = model.isLocked
        hasEntry = model.hasEntry
    }
}
