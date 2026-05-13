import Foundation

struct MorningNotesViewModel {

    let title: String
    let placeholderText: String
    let text: String
    let isLocked: Bool

    init(model: MorningNoteModel) {
        title = "Morning Notes"
        placeholderText = "Write how you feel today..."
        text = model.text
        isLocked = model.isLocked
    }
}
