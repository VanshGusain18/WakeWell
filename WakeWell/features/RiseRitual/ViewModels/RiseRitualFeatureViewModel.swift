import Combine
import Foundation

final class RiseRitualFeatureViewModel: ObservableObject {
    enum Mood: String, CaseIterable, Identifiable {
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
            case .foggy: return "Clear the haze with light activation."
            case .lowEnergy: return "Build energy with movement and sunlight."
            case .distracted: return "Reset attention with a simple focus ritual."
            case .restless: return "Calm the body before starting the day."
            case .slowStart: return "Ease into the morning without force."
            }
        }

        var symbol: String {
            switch self {
            case .foggy: return "cloud.fog.fill"
            case .lowEnergy: return "bolt.heart.fill"
            case .distracted: return "brain.head.profile"
            case .restless: return "wind"
            case .slowStart: return "sunrise.fill"
            }
        }
    }

    enum Screen {
        case mood
        case carousel
        case guided
        case completion
    }

    @Published var screen: Screen = .mood
    @Published var selectedMood: Mood?
    @Published var currentRitual: RiseRitual?
    @Published var currentCardIndex = 0
    @Published var remainingSeconds = 0
    @Published var elapsedSeconds = 0
    @Published var energyLevel = 0.6
    @Published var notes = ""

    private var timer: Timer?
    private var generationSeed = 0
    private var recentReplacementTitles: [String] = []

    deinit {
        stopTimer()
    }

    var currentBlock: RitualBlock? {
        guard let currentRitual,
              currentRitual.blocks.indices.contains(currentCardIndex) else {
            return nil
        }
        return currentRitual.blocks[currentCardIndex]
    }

    var progress: Double {
        guard let currentRitual, !currentRitual.blocks.isEmpty else { return 0 }
        return Double(currentCardIndex + 1) / Double(currentRitual.blocks.count)
    }

    var timerText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func selectMood(_ mood: Mood) {
        stopTimer()
        selectedMood = mood
        currentRitual = generateRitual(for: mood)
        currentCardIndex = 0
        screen = .carousel
    }

    func shuffleCurrentCard() {
        guard let ritual = currentRitual,
              let mood = selectedMood,
              ritual.blocks.indices.contains(currentCardIndex) else {
            return
        }

        var blocks = ritual.blocks
        let current = blocks[currentCardIndex]
        let replacement = replacementBlock(for: current, mood: mood, excluding: Set(blocks.map(\.title)))
        blocks[currentCardIndex] = replacement
        rememberReplacement(replacement.title)
        currentRitual = RiseRitual(title: ritual.title, mood: ritual.mood, blocks: blocks)
    }

    func shuffleAllCards() {
        guard let selectedMood else { return }
        recentReplacementTitles.removeAll()
        currentRitual = generateRitual(for: selectedMood)
        currentCardIndex = 0
    }

    func startRitualFlow() {
        guard currentRitual != nil else { return }
        currentCardIndex = 0
        screen = .guided
        startTimerForCurrentBlock()
    }

    func completeCurrentBlock() {
        advanceGuidedFlow()
    }

    func skipCurrentBlock() {
        advanceGuidedFlow()
    }

    func backToMoodSelection() {
        stopTimer()
        selectedMood = nil
        currentRitual = nil
        currentCardIndex = 0
        screen = .mood
    }

    func backToCarousel() {
        stopTimer()
        currentCardIndex = 0
        screen = currentRitual == nil ? .mood : .carousel
    }

    func finishCompletion() {
        stopTimer()
        selectedMood = nil
        currentRitual = nil
        currentCardIndex = 0
        remainingSeconds = 0
        elapsedSeconds = 0
        energyLevel = 0.6
        notes = ""
        screen = .mood
    }

    private func generateRitual(for mood: Mood) -> RiseRitual {
        generationSeed += 1
        let plan = categoryPlan(for: mood)
        var usedCategories = Set<String>()
        var usedTitles = Set<String>()

        let blocks = plan.compactMap { category -> RitualBlock? in
            guard !usedCategories.contains(category) else { return nil }
            let block = block(for: category, mood: mood, excluding: usedTitles)
            usedCategories.insert(block.category)
            usedTitles.insert(block.title)
            return block
        }

        return RiseRitual(
            title: ritualTitle(for: mood),
            mood: mood.title,
            blocks: Array(blocks.prefix(5))
        )
    }

    private func categoryPlan(for mood: Mood) -> [String] {
        let options: [[String]]
        switch mood {
        case .foggy:
            options = [
                ["hydration", "sunlight", "breathing", "activation"],
                ["cooling", "brain", "movement", "sunlight"],
                ["hydration", "mobility", "focus", "circulation"],
                ["sensory", "posture", "breathing", "sunlight"]
            ]
        case .lowEnergy:
            options = [
                ["movement", "activation", "posture", "circulation"],
                ["breathing", "movement", "activation", "hydration"],
                ["posture", "circulation", "movement", "activation"],
                ["cooling", "movement", "breathing", "posture"]
            ]
        case .distracted:
            options = [
                ["focus", "breathing", "intention", "planning"],
                ["mind", "breathing", "focus", "declutter"],
                ["hydration", "focus", "planning", "intention"],
                ["brain", "breathing", "declutter", "focus"]
            ]
        case .restless:
            options = [
                ["breathing", "grounding", "mobility", "mindfulness"],
                ["calming", "stretch", "grounding", "breathing"],
                ["mindfulness", "breathing", "walking", "release"],
                ["hydration", "calming", "mobility", "grounding"]
            ]
        case .slowStart:
            options = [
                ["hydration", "sunlight", "breathing", "gentle"],
                ["movement", "hydration", "posture", "focus"],
                ["sunlight", "stretch", "breathing", "activation"],
                ["gentle", "mobility", "hydration", "sunlight"]
            ]
        }
        return options[abs(generationSeed % options.count)]
    }

    private func ritualTitle(for mood: Mood) -> String {
        let titles: [String]
        switch mood {
        case .foggy: titles = ["Clear Morning", "Haze Breaker", "Bright Start"]
        case .lowEnergy: titles = ["Wake Pulse", "Morning Charge", "Energy Lift"]
        case .distracted: titles = ["Focused Reset", "Attention Anchor", "Clear Direction"]
        case .restless: titles = ["Calm Start", "Steady Morning", "Grounded Wake"]
        case .slowStart: titles = ["Soft Launch", "Easy Rise", "Gentle Start"]
        }
        return titles[abs(generationSeed % titles.count)]
    }

    private func block(for category: String, mood: Mood, excluding usedTitles: Set<String>) -> RitualBlock {
        let moodBlocks = moodLibrary(for: mood)
        let categoryOptions = moodBlocks.filter { $0.category == category && !usedTitles.contains($0.title) }
        let broadCategoryOptions = Self.allBlocks.filter { $0.category == category && !usedTitles.contains($0.title) }
        let fallbackMoodOptions = moodBlocks.filter { !usedTitles.contains($0.title) }
        let options = !categoryOptions.isEmpty
            ? categoryOptions
            : (!broadCategoryOptions.isEmpty ? broadCategoryOptions : fallbackMoodOptions)

        guard !options.isEmpty else { return Self.fallbackBlock }
        return pick(from: options, salt: category.count + usedTitles.count) ?? Self.fallbackBlock
    }

    private func replacementBlock(
        for currentBlock: RitualBlock,
        mood: Mood,
        excluding usedTitles: Set<String>
    ) -> RitualBlock {

        let existingTitles = usedTitles.subtracting([currentBlock.title])

        let currentRitualCategories = Set(currentRitual?.blocks.map(\.category) ?? [])
            .subtracting([currentBlock.category])

        let pool = moodLibrary(for: mood).filter {
            !existingTitles.contains($0.title) &&
            $0.title != currentBlock.title &&
            !recentReplacementTitles.contains($0.title) &&
            !isTooSimilar($0, to: currentBlock)
        }

        generationSeed += 1

        let preferred = pool.filter {
            !currentRitualCategories.contains($0.category) &&
            $0.category != currentBlock.category
        }

        let balanced = preferred.isEmpty
            ? pool.filter { !currentRitualCategories.contains($0.category) }
            : preferred

        let varied = balanced.isEmpty
            ? pool.filter { $0.category != currentBlock.category }
            : balanced

        let options = varied.isEmpty ? pool : varied

        guard !options.isEmpty else {

            let fallbackPool = moodLibrary(for: mood).filter {
                !existingTitles.contains($0.title) &&
                $0.title != currentBlock.title &&
                !isTooSimilar($0, to: currentBlock)
            }

            return pick(from: fallbackPool, salt: currentBlock.title.count)
                ?? block(
                    for: currentBlock.category,
                    mood: mood,
                    excluding: existingTitles
                )
        }

        return pick(
            from: options,
            salt: currentBlock.title.count + currentBlock.subtitle.count
        ) ?? options[abs(generationSeed % options.count)]
    }

    private func moodLibrary(for mood: Mood) -> [RitualBlock] {
        Self.allBlocks.filter { $0.moodTags.contains(mood.rawValue) }
    }

    private func pick(from options: [RitualBlock], salt: Int) -> RitualBlock? {
        guard !options.isEmpty else { return nil }
        let index = abs((generationSeed * 31 + salt * 17 + options.count) % options.count)
        return options[index]
    }

    private func rememberReplacement(_ title: String) {
        recentReplacementTitles.append(title)
        if recentReplacementTitles.count > 12 {
            recentReplacementTitles.removeFirst(recentReplacementTitles.count - 12)
        }
    }

    private func isTooSimilar(_ lhs: RitualBlock, to rhs: RitualBlock) -> Bool {
        let leftWords = Self.meaningfulTokens(in: lhs.title + " " + lhs.subtitle)
        let rightWords = Self.meaningfulTokens(in: rhs.title + " " + rhs.subtitle)
        let overlap = leftWords.intersection(rightWords)
        return lhs.category == rhs.category && overlap.count >= 1 || overlap.count >= 2
    }

    private func startTimerForCurrentBlock() {
        stopTimer()
        remainingSeconds = max((currentBlock?.duration ?? 1) * 60, 1)
        elapsedSeconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard screen == .guided else {
            stopTimer()
            return
        }
        elapsedSeconds += 1
        remainingSeconds = max(remainingSeconds - 1, 0)
        if remainingSeconds == 0 {
            advanceGuidedFlow()
        }
    }

    private func advanceGuidedFlow() {
        guard let ritual = currentRitual else { return }
        if currentCardIndex < ritual.blocks.count - 1 {
            currentCardIndex += 1
            startTimerForCurrentBlock()
        } else {
            stopTimer()
            screen = .completion
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

private extension RiseRitualFeatureViewModel {
    static let fillerWords: Set<String> = [
        "with", "your", "from", "into", "that", "this", "then", "before",
        "after", "soft", "simple", "quick", "morning", "reset", "wake"
    ]

    static let fallbackBlock = RitualBlock(
        title: "Breathe",
        subtitle: "A simple reset.",
        duration: 1,
        sfSymbol: "wind",
        category: "breathing",
        moodTags: Mood.allCases.map(\.rawValue)
    )

    static func meaningfulTokens(in text: String) -> Set<String> {
        Set(
            text.lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { $0.count > 3 && !fillerWords.contains($0) }
        )
    }

    static func b(
        _ title: String,
        _ subtitle: String,
        _ duration: Int,
        _ sfSymbol: String,
        _ category: String,
        _ moods: Mood...
    ) -> RitualBlock {
        RitualBlock(
            title: title,
            subtitle: subtitle,
            duration: duration,
            sfSymbol: sfSymbol,
            category: category,
            moodTags: moods.map(\.rawValue)
        )
    }

    static let allBlocks: [RitualBlock] = [
        b("Mineral Sip", "Add a pinch of minerals or lemon.", 1, "waterbottle.fill", "hydration", .foggy, .slowStart),
        b("Cool Water Primer", "Drink half a glass before moving.", 1, "drop.fill", "hydration", .foggy, .distracted),
        b("Calm Hydration", "Sip slowly while relaxing your jaw.", 1, "drop.circle.fill", "hydration", .restless, .slowStart),
        b("Steady Glass", "Finish a glass at an easy pace.", 1, "waterbottle", "hydration", .slowStart, .distracted),
        b("Electrolyte Start", "Hydrate before your energy push.", 1, "drop.triangle.fill", "hydration", .lowEnergy, .foggy),
        b("Table Water Reset", "Stand up, drink, and look away from screens.", 1, "cup.and.saucer.fill", "hydration", .distracted),
        b("Warm Sip", "Use warm water for a low-pressure start.", 1, "mug.fill", "hydration", .slowStart, .restless),
        b("Clear Sip", "One clean glass to signal the day.", 1, "drop.degreesign.fill", "hydration", .foggy),

        b("Morning Sunlight", "Face outdoor light for a short cue.", 1, "sun.max.fill", "sunlight", .foggy, .lowEnergy),
        b("Open the Curtains", "Let bright light reach the room.", 1, "curtains.open", "sunlight", .foggy, .slowStart),
        b("Fresh Air Window", "Open a window and take five breaths.", 1, "wind", "sunlight", .foggy, .slowStart),
        b("Balcony Brightness", "Step into daylight without checking your phone.", 2, "cloud.sun.fill", "sunlight", .lowEnergy, .foggy),
        b("Sunlight Pause", "Let light land while your shoulders drop.", 1, "sunrise.fill", "sunlight", .restless, .slowStart),
        b("Sky Focus", "Look toward the sky and blink slowly.", 1, "eye.fill", "sunlight", .foggy, .distracted),
        b("Doorway Light", "Stand at the door and breathe in fresh air.", 1, "door.left.hand.open", "sunlight", .slowStart),
        b("Outdoor Cue", "Take twenty steps near natural light.", 2, "figure.walk", "sunlight", .lowEnergy, .slowStart),

        b("Fast Nose Breathing", "Ten quick nasal breaths, controlled.", 1, "lungs.fill", "breathing", .foggy, .lowEnergy),
        b("Power Breath", "Sharp inhale, long exhale, repeat.", 1, "lungs", "breathing", .lowEnergy),
        b("Box Breathing", "Four counts in, hold, out, hold.", 2, "square.dashed", "breathing", .restless, .distracted),
        b("Long Exhale Breathing", "Inhale four, exhale six.", 2, "wind", "breathing", .restless),
        b("Deep Focus Breath", "One minute of slow belly breathing.", 1, "lungs.fill", "breathing", .distracted, .slowStart),
        b("Warm Morning Breath", "Easy breaths through the nose.", 1, "wind.circle.fill", "breathing", .slowStart),
        b("Single Task Breathing", "Breathe while naming one priority.", 1, "target", "breathing", .distracted),
        b("Calm Count Breath", "Count each exhale down from ten.", 1, "number.circle.fill", "breathing", .restless),
        b("Breathing Reset", "Three slow rounds to steady the body.", 1, "lungs.fill", "breathing", .slowStart, .restless),

        b("Cold Water Splash", "Cool your face to sharpen alertness.", 1, "drop.degreesign.fill", "cooling", .foggy, .lowEnergy),
        b("Face Cooling", "Hold a cool towel to cheeks and eyes.", 1, "face.smiling.fill", "cooling", .foggy),
        b("Wrist Cooldown", "Run cool water over both wrists.", 1, "hand.raised.fill", "cooling", .lowEnergy, .foggy),
        b("Cool Air Reset", "Stand near fresh air for ten breaths.", 1, "snowflake", "cooling", .foggy),

        b("Jumping Jacks", "Twenty light reps to raise energy.", 1, "figure.jumprope", "movement", .lowEnergy),
        b("Mini Squats", "Wake your legs with controlled reps.", 1, "figure.cross.training", "movement", .lowEnergy),
        b("High Knees", "Lift knees briskly for circulation.", 1, "figure.run", "movement", .lowEnergy),
        b("Light Marching", "March in place with tall posture.", 1, "figure.walk.motion", "movement", .foggy, .slowStart),
        b("Energy Reset Walk", "Walk around the room with purpose.", 2, "figure.walk", "movement", .lowEnergy),
        b("Quick Stretch Flow", "Reach, fold, and rise gently.", 2, "figure.flexibility", "movement", .lowEnergy, .slowStart),
        b("Movement Burst", "Move fast for twenty clean seconds.", 1, "bolt.fill", "movement", .lowEnergy),
        b("Relaxed Walking", "Slow steps while lengthening exhales.", 2, "figure.walk", "movement", .restless),
        b("Gradual Activation", "Start slow, then add a little pace.", 2, "figure.walk.arrival", "movement", .slowStart),

        b("Fast Activation", "Twenty seconds of full-body motion.", 1, "bolt.fill", "activation", .foggy, .lowEnergy),
        b("Fast Shakeout", "Shake arms and legs loose.", 1, "figure.mind.and.body", "activation", .lowEnergy),
        b("Heart Pump Reset", "Step quickly and swing your arms.", 1, "heart.fill", "activation", .lowEnergy),
        b("Hand Warm Activation", "Rub palms until warm, then open them.", 1, "hands.sparkles.fill", "activation", .foggy),
        b("Eye Focus Reset", "Focus near, then far, five times.", 1, "eye.circle.fill", "activation", .foggy),
        b("Easy Energy Flow", "Gentle reach, step, and breathe.", 2, "sparkles", "activation", .slowStart),
        b("Calm Activation", "Stand tall and move without rushing.", 1, "figure.stand", "activation", .slowStart),

        b("Power Posture", "Stand tall with open chest.", 1, "figure.stand", "posture", .foggy, .lowEnergy),
        b("Posture Reset", "Stack head, ribs, and hips.", 1, "figure.stand.line.dotted.figure.stand", "posture", .lowEnergy, .slowStart),
        b("Shoulder Wake-Up", "Roll shoulders back and open the chest.", 1, "figure.arms.open", "posture", .foggy),
        b("Dynamic Reach", "Reach overhead, side, and forward.", 1, "figure.flexibility", "posture", .lowEnergy),
        b("Easy Posture Reset", "Lift the crown and soften the jaw.", 1, "person.fill.checkmark", "posture", .slowStart),
        b("Power Stance", "Feet grounded, eyes forward, breathe.", 1, "figure.strengthtraining.traditional", "posture", .lowEnergy),

        b("Arm Swings", "Swing arms across the chest rhythmically.", 1, "figure.arms.open", "circulation", .lowEnergy, .foggy),
        b("Calf Raises", "Rise onto toes for twenty reps.", 1, "figure.stairs", "circulation", .lowEnergy),
        b("Core Wake-Up", "Brace gently and stand tall.", 1, "figure.core.training", "circulation", .lowEnergy),
        b("Shoulder Pumps", "Pump elbows back to wake the upper body.", 1, "figure.strengthtraining.functional", "circulation", .lowEnergy),
        b("Finger Pulse", "Open and close fists quickly.", 1, "hand.tap.fill", "circulation", .foggy),
        b("Circulation Walk", "Walk with long arms and steady breath.", 2, "figure.walk", "circulation", .lowEnergy),

        b("Neck Roll Reset", "Slow half-circles to release stiffness.", 1, "figure.cooldown", "mobility", .foggy, .slowStart),
        b("Calm Neck Stretch", "Lengthen each side without force.", 1, "figure.cooldown", "mobility", .restless),
        b("Shoulder Mobility", "Circle shoulders slowly and evenly.", 1, "figure.arms.open", "mobility", .restless, .slowStart),
        b("Wrist Release", "Circle wrists and unclench fingers.", 1, "hand.raised.fill", "mobility", .restless),
        b("Soft Mobility", "Move joints gently from head to toe.", 2, "figure.mind.and.body", "mobility", .restless, .slowStart),
        b("Gentle Reach", "Reach overhead and breathe into the ribs.", 1, "figure.flexibility", "mobility", .slowStart),
        b("Jaw Release", "Relax the jaw and smooth the forehead.", 1, "face.smiling", "mobility", .foggy, .restless),
        b("Light Stretch", "One easy stretch that feels kind.", 1, "figure.cooldown", "mobility", .slowStart),

        b("Grounding Reset", "Feel both feet and name the room.", 1, "leaf.fill", "grounding", .restless),
        b("Five Senses", "Name one thing you see, hear, and feel.", 2, "eye.fill", "grounding", .restless, .distracted),
        b("Quiet Standing", "Stand still until your breath settles.", 1, "figure.stand", "grounding", .restless),
        b("Floor Contact", "Press toes down and soften shoulders.", 1, "shoeprints.fill", "grounding", .restless),
        b("Nervous System Reset", "Long exhales with feet planted.", 2, "heart.circle.fill", "grounding", .restless),
        b("Guided Pause", "Pause before choosing the next action.", 1, "pause.circle.fill", "grounding", .restless, .distracted),

        b("Body Scan", "Find one tense spot and soften it.", 2, "person.fill.checkmark", "mindfulness", .restless),
        b("Gratitude Reset", "Name one thing already working.", 1, "heart.fill", "mindfulness", .restless, .distracted),
        b("Quiet Sitting", "Sit upright and let the room settle.", 2, "chair.fill", "mindfulness", .restless),
        b("Mindful Reset", "Notice thoughts without following them.", 2, "brain.head.profile", "mindfulness", .restless, .distracted),
        b("Slow Thinking Pause", "Give yourself ten seconds before action.", 1, "hourglass", "mindfulness", .distracted),
        b("Relaxed Start", "Begin with one calm, doable choice.", 1, "sparkles", "mindfulness", .slowStart),

        b("Focus Prompt", "Name the first useful action.", 1, "target", "focus", .distracted, .foggy),
        b("Attention Lock-In", "Pick one task and remove one distraction.", 1, "scope", "focus", .distracted),
        b("Mind Anchor", "Choose a word to return to.", 1, "anchor.fill", "focus", .distracted),
        b("Cognitive Wake-Up", "Solve one tiny practical question.", 1, "brain.head.profile", "focus", .foggy, .distracted),
        b("Soft Focus Reset", "Choose one gentle direction for the hour.", 1, "smallcircle.filled.circle.fill", "focus", .slowStart),
        b("Goal Reminder", "Say today's main goal out loud.", 1, "flag.fill", "focus", .distracted),
        b("Brain Countdown", "Count back from twenty by twos.", 1, "number", "focus", .foggy),

        b("Intention Reset", "Choose how you want to show up.", 1, "sparkles", "intention", .distracted),
        b("Top Three", "Pick three realistic priorities.", 2, "checklist", "intention", .distracted),
        b("Morning Priorities", "Write the first, next, and later tasks.", 2, "list.bullet.clipboard.fill", "planning", .distracted),
        b("One Minute Planning", "Make a tiny plan before reacting.", 1, "calendar.badge.clock", "planning", .distracted),
        b("Brain Declutter", "Write down loose thoughts, then choose one.", 2, "square.and.pencil", "declutter", .distracted),
        b("Clear Surface", "Move one distracting item away.", 1, "rectangle.and.hand.point.up.left.fill", "declutter", .distracted),
        b("Thought Reset", "Label the thought, then return to now.", 1, "bubble.left.and.bubble.right.fill", "mind", .distracted),
        b("Focus Countdown", "Count five breaths before starting.", 1, "timer", "mind", .distracted),

        b("Gentle Hydration", "Small sips while you sit upright.", 1, "mug.fill", "gentle", .slowStart),
        b("Morning Ease Flow", "Reach, breathe, and move slowly.", 2, "figure.mind.and.body", "gentle", .slowStart),
        b("Slow Body Wake-Up", "Wake each joint without pressure.", 2, "figure.cooldown", "gentle", .slowStart),
        b("Curtain Open Reset", "Open light before increasing pace.", 1, "curtains.open", "gentle", .slowStart),
        b("Calm Wake-Up", "Sit tall and breathe before standing.", 1, "sunrise.fill", "gentle", .slowStart),

        b("Slow Shoulder Roll", "Roll shoulders with long exhales.", 1, "figure.arms.open", "calming", .restless),
        b("Eye Relax Reset", "Soften your gaze and blink slowly.", 1, "eye", "calming", .restless),
        b("Soft Walk", "Walk slowly and match steps to breath.", 2, "figure.walk", "walking", .restless),
        b("Tension Release", "Tense hands, then fully release.", 1, "hand.raised.fill", "release", .restless),
        b("Gentle Stretch", "Choose one stretch and stay easy.", 2, "figure.flexibility", "stretch", .restless, .slowStart),
        b("Warm Stretch", "Lengthen slowly without chasing range.", 2, "figure.cooldown", "stretch", .slowStart, .restless),

        b("Brain Light Switch", "Stand, look up, and breathe once.", 1, "lightbulb.fill", "brain", .foggy),
        b("Name the Date", "Say the day, date, and next action.", 1, "calendar", "brain", .foggy),
        b("Mental Clarity Reset", "Ask what matters in the next hour.", 1, "questionmark.circle.fill", "brain", .distracted, .foggy),
        b("Window Air Reset", "Fresh air, open chest, clear eyes.", 1, "wind", "sensory", .foggy),
        b("Texture Wake-Up", "Touch something cool and name the texture.", 1, "hand.point.up.left.fill", "sensory", .foggy)
    ]
}
