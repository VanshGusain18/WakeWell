import SwiftUI
import HealthKit

struct ContentView: View {
    var body: some View {
        VStack {
            Text("WakeWell Watch")
            Button("Start Workout") {
                startWorkout()
            }
        }
    }

    func startWorkout() {
        print("⌚️ Workout started (required for live HR)")
    }
}
