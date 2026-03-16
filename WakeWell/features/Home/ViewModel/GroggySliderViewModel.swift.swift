import Foundation

struct GroggySliderViewModel {

    let title: String
    let leftLabel: String
    let rightLabel: String
    let value: Float

    init() {
        title = "How groggy do you feel?"
        leftLabel = "Fresh"
        rightLabel = "Very Groggy"
        value = 5
    }
}
