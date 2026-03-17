import Foundation

struct MorningNotesViewModel {

    let title: String
    let placeholderText: String
    let text: String

    init(model: MorningNoteModel) {
        title = "Morning Notes"
        placeholderText = "Write how you feel today..."
        text = model.text
    }
}
