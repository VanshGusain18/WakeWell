//
//  Activity.swift
//  WakeWell
//
//  Created by geu on 18/03/26.
//

struct Activity {
    let id: String
    let title: String
    let description: String
    let duration: Int?
    let category: String
    let imageName: String
    let activityType: ActivityType
    let steps: [String]
}
enum ActivityType {
    case timerBased
    case stepBased
    case informational
}

let activities: [Activity] = [
    
    Activity(id: "ritual_1", title: "Sunlight Exposure",
             description: "Get 10-15 minutes of direct sunlight to refresh your senses and boost your energy.",
             duration: 900,
             category: "(Calm your mind)",
             imageName: "ritual_1",
             activityType: .timerBased,
             steps: [
                "Step outside or sit near a window",
                "Expose your eyes to natural light",
                "Relax and breathe normally"
             ]),
    
    Activity(id: "ritual_2", title: "Screen Light Ramp",
             description: "Gradually increase screen brightness or use warmer light settings.",
             duration: nil,
             category: "mindfulness",
             imageName: "ritual_2",
             activityType: .informational,
             steps: [
                "Start with low brightness",
                "Gradually increase over time",
                "Enable night shift or warm tones"
             ]),
    
    Activity(id: "ritual_3", title: "Warm Sunlight",
             description: "Feel the warmth of the sun on your skin.",
             duration: 300,
             category: "mindfulness",
             imageName: "ritual_3",
             activityType: .timerBased,
             steps: [
                "Step into sunlight",
                "Close your eyes briefly",
                "Focus on warmth on skin"
             ]),
    
    Activity(id: "ritual_4", title: "Calm Sigh",
             description: "Deep inhale, short inhale, long exhale.",
             duration: 60,
             category: "mindfulness",
             imageName: "ritual_4",
             activityType: .stepBased,
             steps: [
                "Take a deep inhale",
                "Take a second short inhale",
                "Slowly exhale through mouth"
             ]),
    
    Activity(id: "ritual_5", title: "Box Breathing",
             description: "Inhale, hold, exhale, hold.",
             duration: 120,
             category: "mindfulness",
             imageName: "ritual_2",
             activityType: .timerBased,
             steps: [
                "Inhale for 4 seconds",
                "Hold for 4 seconds",
                "Exhale and hold for 4 seconds"
             ]),
    
    Activity(id: "ritual_6", title: "Extended Exhale",
             description: "Exhale twice as long as inhale.",
             duration: 120,
             category: "mindfulness",
             imageName: "ritual_6",
             activityType: .timerBased,
             steps: [
                "Inhale slowly",
                "Exhale for double duration",
                "Repeat rhythm calmly"
             ]),
    
    Activity(id: "ritual_7", title: "Stability Pause",
             description: "Stand still and balance.",
             duration: 60,
             category: "mindfulness",
             imageName: "ritual_7",
             activityType: .timerBased,
             steps: [
                "Stand upright",
                "Focus on balance",
                "Stay still without movement"
             ]),
    
    Activity(id: "ritual_8", title: "Stand Posture",
             description: "Align your spine.",
             duration: nil,
             category: "physical",
             imageName: "ritual_8",
             activityType: .informational,
             steps: [
                "Stand straight",
                "Pull shoulders back",
                "Align neck with spine"
             ]),
    
    Activity(id: "ritual_9", title: "Short Walk",
             description: "Take a walk.",
             duration: 600,
             category: "physical",
             imageName: "ritual_9",
             activityType: .timerBased,
             steps: [
                "Start walking slowly",
                "Maintain steady pace",
                "Observe surroundings"
             ]),
    
    Activity(id: "ritual_10", title: "Neck Mobility",
             description: "Gentle neck stretches.",
             duration: 60,
             category: "physical",
             imageName: "ritual_10",
             activityType: .stepBased,
             steps: [
                "Tilt head side to side",
                "Rotate neck slowly",
                "Stretch gently"
             ]),
    
    Activity(id: "ritual_11", title: "Balance Hold",
             description: "Stand on one leg.",
             duration: 60,
             category: "physical",
             imageName: "ritual_11",
             activityType: .timerBased,
             steps: [
                "Lift one leg",
                "Maintain balance",
                "Switch sides"
             ]),
    
    Activity(id: "ritual_12", title: "Reaction Tap",
             description: "Tap rapidly.",
             duration: 30,
             category: "productivity",
             imageName: "ritual_12",
             activityType: .timerBased,
             steps: [
                "Start tapping quickly",
                "Maintain speed",
                "Track consistency"
             ]),
    
    Activity(id: "ritual_13", title: "Pattern Recognition",
             description: "Find patterns.",
             duration: nil,
             category: "productivity",
             imageName: "ritual_13",
             activityType: .informational,
             steps: [
                "Observe surroundings",
                "Identify repeating elements",
                "Focus on patterns"
             ]),
    
    Activity(id: "ritual_14", title: "Working Memory",
             description: "Recall items.",
             duration: nil,
             category: "productivity",
             imageName: "ritual_14",
             activityType: .stepBased,
             steps: [
                "Think of yesterday",
                "Recall 5 items",
                "Repeat mentally"
             ]),
    
    Activity(id: "ritual_15", title: "Focus Calibration",
             description: "Stare at a point.",
             duration: 60,
             category: "productivity",
             imageName: "ritual_15",
             activityType: .timerBased,
             steps: [
                "Pick a point",
                "Focus your eyes",
                "Avoid distractions"
             ]),
    
    Activity(id: "ritual_16", title: "One Line Intention",
             description: "Write a goal.",
             duration: nil,
             category: "productivity",
             imageName: "ritual_16",
             activityType: .stepBased,
             steps: [
                "Think of your goal",
                "Write one sentence",
                "Keep it simple"
             ]),
    
    Activity(id: "ritual_17", title: "Top Priority",
             description: "Find main task.",
             duration: nil,
             category: "productivity",
             imageName: "ritual_17",
             activityType: .stepBased,
             steps: [
                "List tasks",
                "Pick most important",
                "Commit to it"
             ]),
    
    Activity(id: "ritual_18", title: "First Task",
             description: "Start your task.",
             duration: nil,
             category: "productivity",
             imageName: "ritual_18",
             activityType: .stepBased,
             steps: [
                "Pick your task",
                "Start immediately",
                "Avoid distractions"
             ]),
    
    Activity(id: "ritual_19", title: "Gratitude",
             description: "Be grateful.",
             duration: nil,
             category: "productivity",
             imageName: "ritual_19",
             activityType: .stepBased,
             steps: [
                "Think of one thing",
                "Feel gratitude",
                "Write it down"
             ]),
    
    Activity(id: "ritual_20", title: "Hydration",
             description: "Drink water.",
             duration: nil,
             category: "nutrition",
             imageName: "ritual_20",
             activityType: .stepBased,
             steps: [
                "Fill a glass",
                "Drink slowly",
                "Notice temperature"
             ]),
    
    Activity(id: "ritual_21", title: "Stillness Check",
             description: "Eat quietly.",
             duration: nil,
             category: "nutrition",
             imageName: "ritual_21",
             activityType: .informational,
             steps: [
                "Sit calmly",
                "Eat without distractions",
                "Focus on food"
             ]),
    
    Activity(id: "ritual_22", title: "Temperature Awareness",
             description: "Notice food temperature.",
             duration: nil,
             category: "nutrition",
             imageName: "ritual_22",
             activityType: .informational,
             steps: [
                "Take a bite",
                "Notice warmth/cold",
                "Observe sensations"
             ])
]

var shuffledActivities = activities.shuffled()
