// Activity.swift — SetSail
// Model is kept identical to the original so HomeDataProvider, Stats, and
// other features that reference `activities` / `Activity` are unaffected.

import Foundation

struct Activity: Codable {
    let id:           String
    let title:        String
    let description:  String
    let duration:     Int?
    let category:     String
    let imageName:    String
    let activityType: ActivityType
    let steps:        [String]
}

enum ActivityType: String, Codable {
    case timerBased
    case stepBased
    case informational
}

// MARK: - Built-in activity library (science-backed, grogginess-busting)

var activities: [Activity] = [

    Activity(id: "ritual_1",  title: "Sunlight Exposure",
             description: "Step outside for 10–15 minutes of natural light. Sunlight suppresses melatonin and resets your circadian clock.",
             duration: 900, category: "Energy", imageName: "ritual_1",
             activityType: .timerBased,
             steps: ["Step outside or sit near a window",
                     "Let natural light reach your eyes — no sunglasses",
                     "Breathe slowly and let your body wake up"]),

    Activity(id: "ritual_2",  title: "Cold Splash",
             description: "Splash cold water on your face to trigger the dive reflex, reducing sleepiness fast.",
             duration: nil, category: "Alertness", imageName: "ritual_2",
             activityType: .stepBased,
             steps: ["Run cold water from the tap",
                     "Splash your face 5–10 times",
                     "Pat dry and notice how awake you feel"]),

    Activity(id: "ritual_3",  title: "Box Breathing",
             description: "4-4-4-4 breathing activates the parasympathetic nervous system, clearing brain fog.",
             duration: 168, category: "Calm", imageName: "ritual_5",
             activityType: .timerBased,
             steps: ["Inhale for 4 counts",
                     "Hold for 4 counts",
                     "Exhale for 4 counts",
                     "Hold for 4 counts — repeat 6 times"]),

    Activity(id: "ritual_4",  title: "Physiological Sigh",
             description: "Double inhale through the nose then a long exhale instantly lowers stress.",
             duration: 60, category: "Calm", imageName: "ritual_4",
             activityType: .timerBased,
             steps: ["Inhale fully through your nose",
                     "Take a second short inhale on top",
                     "Exhale slowly through your mouth — longer than the inhale"]),

    Activity(id: "ritual_5",  title: "Hydration",
             description: "Drinking 1–2 glasses of water after waking replenishes overnight fluid loss and boosts alertness.",
             duration: nil, category: "Energy", imageName: "ritual_20",
             activityType: .stepBased,
             steps: ["Pour a full glass of water",
                     "Drink it slowly — no rush",
                     "Notice how your body responds"]),

    Activity(id: "ritual_6",  title: "Body Scan Stretch",
             description: "A 2-minute head-to-toe stretch reduces cortisol and wakes up your muscles.",
             duration: 120, category: "Physical", imageName: "ritual_10",
             activityType: .timerBased,
             steps: ["Roll your neck gently left and right",
                     "Shrug shoulders up to ears — release",
                     "Reach arms above your head and stretch",
                     "Slowly bend forward and hang"]),

    Activity(id: "ritual_7",  title: "Gratitude Note",
             description: "Writing one sentence of gratitude shifts your brain from threat-detection to positive focus.",
             duration: nil, category: "Mindset", imageName: "ritual_19",
             activityType: .stepBased,
             steps: ["Pick up a pen or open notes",
                     "Write one thing you are grateful for today",
                     "Read it back and let it land"]),

    Activity(id: "ritual_8",  title: "Top Priority",
             description: "Identifying your single most important task reduces decision fatigue and primes focus.",
             duration: nil, category: "Mindset", imageName: "ritual_17",
             activityType: .stepBased,
             steps: ["Think about everything on your plate today",
                     "Pick ONE task that matters most",
                     "Write it down or say it aloud"]),

    Activity(id: "ritual_9",  title: "Short Walk",
             description: "Even 5 minutes of walking increases dopamine, serotonin, and norepinephrine — all anti-grogginess.",
             duration: 300, category: "Physical", imageName: "ritual_9",
             activityType: .timerBased,
             steps: ["Head outside or walk around your home",
                     "Keep a steady comfortable pace",
                     "No phone — just movement and observation"]),

    Activity(id: "ritual_10", title: "Balance Hold",
             description: "Single-leg balance activates the cerebellum and rapidly sharpens full-brain focus.",
             duration: 60, category: "Physical", imageName: "ritual_11",
             activityType: .timerBased,
             steps: ["Stand near a wall for safety",
                     "Lift one foot off the ground",
                     "Hold for 30 seconds each side"]),

    Activity(id: "ritual_11", title: "Reaction Taps",
             description: "Visual reaction training fires fast-twitch neural circuits and eliminates mental sluggishness.",
             duration: 300, category: "Alertness", imageName: "ritual_12",
             activityType: .timerBased,
             steps: ["Tap the dot the instant it appears",
                     "Missed dots score zero — stay sharp",
                     "Speed increases as your reaction improves"]),

    Activity(id: "ritual_12", title: "Focus Calibration",
             description: "Holding visual focus on a single point for 60 seconds trains attentional control.",
             duration: 60, category: "Alertness", imageName: "ritual_15",
             activityType: .timerBased,
             steps: ["Pick a fixed point across the room",
                     "Lock your gaze on it — don't let it wander",
                     "If your mind drifts, bring it back"]),
]

var shuffledActivities: [Activity] = activities.shuffled()

// MARK: - Persistence helpers

func loadActivities() {
    guard let data = UserDefaults.standard.data(forKey: "activities"),
          let saved = try? JSONDecoder().decode([Activity].self, from: data)
    else { return }
    activities = saved
}

func saveActivities() {
    guard let data = try? JSONEncoder().encode(activities) else { return }
    UserDefaults.standard.set(data, forKey: "activities")
}
