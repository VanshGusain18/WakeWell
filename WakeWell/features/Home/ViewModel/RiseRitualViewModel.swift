import Foundation

struct RiseRitualViewModel {

    let title: String
    let category: String
    let description: String
    let startButtonTitle: String
    let viewTabTitle: String

    init(model: RiseRitualModel) {
        self.title = model.title
        self.category = model.category
        self.description = model.description
        self.startButtonTitle = "Start Ritual"
        self.viewTabTitle = "VIEW RISE TAB ›"
    }
}
