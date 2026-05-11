import SwiftUI

enum RitualLibrary {
    static var allBlocks: [RitualBlock] {
        breathing + movement + hydration + mindfulness + sunlight + activation + focus
    }

    static func blocks(for category: RitualCategory) -> [RitualBlock] {
        switch category {
        case .breathing: return breathing
        case .movement: return movement
        case .hydration: return hydration
        case .mindfulness: return mindfulness
        case .sunlight: return sunlight
        case .activation: return activation
        case .focus: return focus
        }
    }

    static let breathing: [RitualBlock] = [
        block("Box Breathing", "Four-count calm.", 1, .breathing, "wind", "Inhale for 4, hold for 4, exhale for 4, hold for 4. Repeat three steady rounds.", ["#84FAB0", "#8FD3F4"]),
        block("Deep Breathing", "Fill the ribs slowly.", 1, .breathing, "lungs.fill", "Place one hand on your ribs. Inhale through the nose, then exhale longer than you inhaled.", ["#A1C4FD", "#C2E9FB"]),
        block("Long Exhale", "Ease your nervous system.", 1, .breathing, "wind.circle.fill", "Inhale for 3 counts and exhale for 6 counts. Let your jaw and shoulders drop.", ["#89F7FE", "#66A6FF"]),
        block("Calm Reset", "Three breaths with attention.", 1, .breathing, "sparkles", "Take three slow breaths. On each exhale, relax your face, hands, and stomach.", ["#F6D365", "#FDA085"]),
        block("Nasal Breathing", "Quiet energy.", 1, .breathing, "nose.fill", "Close your mouth softly and breathe through your nose for one minute.", ["#D4FC79", "#96E6A1"])
    ]

    static let movement: [RitualBlock] = [
        block("Neck Rolls", "Release sleep stiffness.", 1, .movement, "figure.cooldown", "Drop your chin gently. Roll side to side slowly, keeping the movement comfortable.", ["#FBC2EB", "#A6C1EE"]),
        block("Shoulder Mobility", "Open the upper body.", 1, .movement, "figure.strengthtraining.functional", "Roll shoulders back, reach overhead, then sweep your arms open across the chest.", ["#FAD961", "#F76B1C"]),
        block("Easy Walk", "Move without strain.", 2, .movement, "figure.walk", "Walk around the room or hallway. Keep your gaze up and arms loose.", ["#96FBC4", "#F9F586"]),
        block("Mini Squats", "Warm your legs.", 1, .movement, "figure.cross.training", "Do slow mini squats with a tall chest. Stop before the movement feels intense.", ["#FFECD2", "#FCB69F"]),
        block("Standing Stretch", "Lengthen gently.", 1, .movement, "figure.flexibility", "Fold forward with soft knees, pause, then slowly roll up one vertebra at a time.", ["#C2FFD8", "#465EFB"])
    ]

    static let hydration: [RitualBlock] = [
        block("Hydrate", "A full glass before momentum.", 1, .hydration, "drop.fill", "Drink a full glass of water slowly. Pause halfway and relax your shoulders.", ["#89F7FE", "#66A6FF"]),
        block("Cold Splash", "Freshen your senses.", 1, .hydration, "drop.degreesign.fill", "Splash cool water on your face or rinse your hands, then take three calm breaths.", ["#4FACFE", "#00F2FE"]),
        block("Mineral Sip", "Wake with a steady sip.", 1, .hydration, "waterbottle.fill", "Take several slow sips of water. Refill the glass before moving on.", ["#43E97B", "#38F9D7"]),
        block("Lemon Water", "Bright and simple.", 1, .hydration, "waterbottle", "Prepare water with lemon if you have it nearby. Drink without checking your phone.", ["#F6D365", "#FDEB71"])
    ]

    static let mindfulness: [RitualBlock] = [
        block("Gratitude Reset", "Start with one good thing.", 1, .mindfulness, "heart.fill", "Name one thing you appreciate and one thing you are ready to begin.", ["#FF9A9E", "#FECFEF"]),
        block("Five Senses", "Ground attention.", 1, .mindfulness, "eye.fill", "Notice one thing you see, feel, hear, smell, and taste.", ["#A18CD1", "#FBC2EB"]),
        block("Body Scan", "Arrive in your body.", 1, .mindfulness, "person.fill.checkmark", "Scan from forehead to feet. Relax one tense spot before continuing.", ["#84FAB0", "#8FD3F4"]),
        block("Still Minute", "Let the morning settle.", 1, .mindfulness, "leaf.fill", "Sit or stand still for one minute. Let thoughts pass without following them.", ["#D4FC79", "#96E6A1"])
    ]

    static let sunlight: [RitualBlock] = [
        block("Sunlight Reset", "Bright light cue.", 1, .sunlight, "sun.max.fill", "Stand by a bright window or step outside. Keep your gaze soft.", ["#FAD961", "#F76B1C"]),
        block("Window Pause", "Quiet morning light.", 1, .sunlight, "sunrise.fill", "Face a bright window for one minute and breathe naturally.", ["#FA709A", "#FEE140"]),
        block("Fresh Air", "Light and air together.", 1, .sunlight, "cloud.sun.fill", "Open a window or step outside. Notice the air temperature and light.", ["#89F7FE", "#FAD961"]),
        block("Sky Check", "Look beyond the room.", 1, .sunlight, "sun.horizon.fill", "Look at the sky or brightest available light. Avoid staring directly at the sun.", ["#F6D365", "#FDA085"])
    ]

    static let activation: [RitualBlock] = [
        block("Jumping Jacks", "Quick circulation boost.", 1, .activation, "figure.jumprope", "Do gentle jumping jacks or step jacks. Keep it light and rhythmic.", ["#F5576C", "#F093FB"]),
        block("Pushups", "A short strength signal.", 1, .activation, "figure.strengthtraining.traditional", "Do a small set of wall, knee, or floor pushups. Stop while it still feels clean.", ["#FF5858", "#F09819"]),
        block("Fast Activation", "Wake the whole body.", 1, .activation, "bolt.fill", "March in place with quick arms for 45 seconds, then slow your breathing.", ["#FAD961", "#F76B1C"]),
        block("Stair Step", "Strong but brief.", 1, .activation, "figure.stairs", "Step up and down on a safe stair or march with high knees for one minute.", ["#43E97B", "#38F9D7"]),
        block("Arm Swings", "Simple energy builder.", 1, .activation, "figure.arms.open", "Swing your arms forward and back with soft knees. Let the body wake naturally.", ["#FA709A", "#FEE140"])
    ]

    static let focus: [RitualBlock] = [
        block("Focus Intention", "Choose the first useful action.", 1, .focus, "target", "Name one small task that would make the morning feel successful.", ["#667EEA", "#764BA2"]),
        block("Phone Boundary", "Protect first focus.", 1, .focus, "iphone.slash", "Keep your phone away or open only the tool needed for your first task.", ["#A1C4FD", "#C2E9FB"]),
        block("Clear Surface", "Reduce visual noise.", 1, .focus, "rectangle.and.hand.point.up.left.fill", "Clear one small surface. Remove only what blocks your first action.", ["#FBC2EB", "#A6C1EE"]),
        block("Top Three", "Make the morning concrete.", 1, .focus, "checklist", "Write or mentally name the three most useful things to do next.", ["#84FAB0", "#8FD3F4"])
    ]

    private static func block(
        _ title: String,
        _ subtitle: String,
        _ duration: Int,
        _ category: RitualCategory,
        _ sfSymbol: String,
        _ instructions: String,
        _ hexColors: [String]
    ) -> RitualBlock {
        RitualBlock(
            title: title,
            subtitle: subtitle,
            duration: duration,
            category: category,
            sfSymbol: sfSymbol,
            instructions: instructions,
            gradientColors: hexColors.map { Color(riseHex: $0) }
        )
    }
}
