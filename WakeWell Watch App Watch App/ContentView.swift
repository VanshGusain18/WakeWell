//
//  ContentView.swift
//  WakeWell Watch App Watch App
//
//  Created by geu on 29/04/26.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @StateObject private var connectivity = WatchConnectivityManager.shared

    var body: some View {
        let isReachable = WCSession.default.isReachable

        VStack(alignment: .leading, spacing: 8) {
            Text("LIVE HEALTH DATA MODE")
                .font(.caption.bold())
                .foregroundStyle(connectivity.hasHealthDataAccess ? .green : .red)

            Text(connectivity.hasHealthDataAccess ? statusText(isReachable: isReachable) : "No Health Data Access")
                .font(.headline)
                .foregroundStyle(connectivity.hasHealthDataAccess ? statusColor(isReachable: isReachable) : .red)

            VStack(alignment: .leading, spacing: 2) {
                Text("HR")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(String(format: "%.0f", connectivity.lastHeartRate)) BPM")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
            }

            Text("Motion: \(String(format: "%.3f", connectivity.lastMotion))")
                .font(.caption)

            Text("HRV: \(String(format: "%.1f", connectivity.lastHRV)) ms")
                .font(.caption)

            Text("Resp: \(String(format: "%.1f", connectivity.lastRespiratoryRate)) /min")
                .font(.caption)

            Text("HRV updated: \(hrvUpdateText)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private func statusText(isReachable: Bool) -> String {
        if !isReachable {
            return "❌ iPhone not reachable"
        }

        if !connectivity.hasSentPayload {
            return "🟡 Connecting..."
        }

        return "🟢 Sending Live Vitals"
    }

    private func statusColor(isReachable: Bool) -> Color {
        if !isReachable {
            return .red
        }

        return connectivity.hasSentPayload ? .green : .yellow
    }

    private var hrvUpdateText: String {
        guard let date = connectivity.lastHRVUpdatedAt else {
            return "--"
        }

        return Self.timeFormatter.string(from: date)
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter
    }()
}

#Preview {
    ContentView()
}
