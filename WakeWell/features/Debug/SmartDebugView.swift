import SwiftUI

struct SmartDebugView: View {

    @StateObject private var viewModel: SmartDebugViewModel

    init(viewModel: SmartDebugViewModel = SmartDebugViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        let snapshot = viewModel.snapshot

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header(snapshot: snapshot)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    metricCard(title: "Current HR", value: formatted(snapshot.currentHR))
                    metricCard(title: "Current HRV", value: formatted(snapshot.currentHRV))
                    metricCard(title: "Current Motion", value: formatted(snapshot.currentMotion))
                    metricCard(title: "Avg HR", value: formatted(snapshot.avgHR))
                    metricCard(title: "Avg Motion", value: formatted(snapshot.avgMotion))
                    metricCard(title: "Confidence", value: formatted(snapshot.confidence))
                    metricCard(title: "Score", value: formatted(snapshot.score))
                    metricCard(title: "Threshold", value: formatted(snapshot.threshold))
                    metricCard(title: "Motion Count", value: "\(snapshot.motionIncreasingCount)")
                    metricCard(title: "Phase", value: snapshot.currentPhase)
                }

                statusCard(snapshot: snapshot)

                Button(action: viewModel.clear) {
                    Text("Clear DB + Reset Engine")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .padding(20)
        }
        .navigationTitle("Smart Debug")
        .background(Color(.systemGroupedBackground))
    }

    private func header(snapshot: SmartAlarmDebugSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WakeWell Demo Dashboard")
                .font(.title2.bold())
            Text("State: \(snapshot.alarmState.rawValue.capitalized)")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Decision: \(snapshot.decisionReason)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statusCard(snapshot: SmartAlarmDebugSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Live Status")
                .font(.headline)
            statusRow(label: "Avg HRV", value: formatted(snapshot.avgHRV))
            statusRow(label: "Alarm State", value: snapshot.alarmState.rawValue.capitalized)
            statusRow(label: "Current Phase", value: snapshot.currentPhase)
            statusRow(label: "Reason", value: snapshot.decisionReason)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func metricCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func statusRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }

    private func formatted(_ value: Double) -> String {
        String(format: "%.3f", value)
    }
}
