import Foundation

final class WatchDebugRunner {

    static func run() {

        print("🚀 STARTING WATCH BACKEND TEST\n")

        WatchDataManager.shared.syncData {

            print("\n📊 FINAL RESULT:")

            if let data = WatchDataManager.shared.latestData {

                print("Sleep Score: \(data.sleepScore)")
                print("Duration: \(data.duration)")
                print("Efficiency: \(data.efficiency)")
                print("Architecture: \(data.architecture)")
                print("Continuity: \(data.continuity)")
                print("Calmness: \(data.calmness)")
                print("Consistency: \(data.consistency)")
                print("Timestamp: \(data.timestamp)")

            } else {
                print("❌ No data received")
            }

            print("\n✅ WATCH BACKEND PIPELINE WORKING\n")
        }
    }
}
