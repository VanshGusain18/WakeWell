//
//  ContentView.swift
//  WakeWell Watch App Watch App
//
//  Created by geu on 29/04/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var connectivity = WatchConnectivityManager.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("WakeWell")
                                .font(.system(.title3, design: .rounded).weight(.bold))
                                .foregroundStyle(WatchTheme.primaryText)
                            Text("Watch")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(WatchTheme.gold)
                        }

                        Spacer()

                        Image(systemName: "moon.zzz.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(WatchTheme.gold)
                            .frame(width: 34, height: 34)
                            .background(WatchTheme.card)
                            .clipShape(Circle())
                    }

                    RiseRitualStartCard()

                    LiveVitalsWatchView(connectivity: connectivity)
                }
                .padding(.horizontal, 6)
                .padding(.bottom, 10)
            }
            .background(WatchTheme.background)
            .containerBackground(WatchTheme.background.gradient, for: .navigation)
            .navigationDestination(isPresented: $connectivity.shouldOpenRiseRitual) {
                RiseRitualWatchView(autoStart: connectivity.shouldAutoStartRiseRitual)
            }
        }
    }
}

private struct RiseRitualStartCard: View {
    var body: some View {
        NavigationLink {
            RiseRitualWatchView()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(WatchTheme.gold.opacity(0.18))
                        Image(systemName: "sunrise.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(WatchTheme.gold)
                    }
                    .frame(width: 42, height: 42)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Rise Ritual")
                            .font(.system(.headline, design: .rounded).weight(.bold))
                            .foregroundStyle(WatchTheme.primaryText)
                        Text("Start your morning reset")
                            .font(.caption2)
                            .foregroundStyle(WatchTheme.secondaryText)
                            .lineLimit(2)
                    }
                }

                HStack(spacing: 6) {
                    Text("Start")
                        .font(.caption.weight(.bold))
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                }
                .foregroundStyle(WatchTheme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(WatchTheme.gold)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding(12)
            .background(
                LinearGradient(
                    colors: [WatchTheme.card, WatchTheme.purple.opacity(0.38)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(WatchTheme.gold.opacity(0.22), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct LiveVitalsWatchView: View {
    @ObservedObject var connectivity: WatchConnectivityManager

    var body: some View {
        let isReachable = connectivity.isReachable

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Live Vitals")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(WatchTheme.primaryText)
                Spacer()
                Circle()
                    .fill(connectivity.hasHealthDataAccess ? statusColor(isReachable: isReachable) : .red)
                    .frame(width: 8, height: 8)
            }

            Text(connectivity.hasHealthDataAccess ? statusText(isReachable: isReachable) : "No Health Data Access")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(connectivity.hasHealthDataAccess ? WatchTheme.secondaryText : .red)

            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(connectivity.hasReceivedHeartRate ? "\(String(format: "%.0f", connectivity.lastHeartRate))" : "--")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(WatchTheme.gold)
                Text("BPM")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(WatchTheme.secondaryText)
            }

            VStack(alignment: .leading, spacing: 4) {
                metricRow(
                    title: "Motion",
                    value: connectivity.hasReceivedMotion ? String(format: "%.3f", connectivity.lastMotion) : "--"
                )
                metricRow(
                    title: "HRV",
                    value: connectivity.hasReceivedHRV ? "\(String(format: "%.1f", connectivity.lastHRV)) ms" : "--"
                )
                metricRow(
                    title: "Resp",
                    value: connectivity.hasReceivedRespiratoryRate ? "\(String(format: "%.1f", connectivity.lastRespiratoryRate)) /min" : "--"
                )
                metricRow(title: "HRV updated", value: hrvUpdateText)
            }
        }
        .padding(12)
        .background(WatchTheme.card.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func metricRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(WatchTheme.secondaryText)
            Spacer()
            Text(value)
                .foregroundStyle(WatchTheme.primaryText)
        }
        .font(.caption2)
    }

    private func statusText(isReachable: Bool) -> String {
        if connectivity.hasSentPayload {
            return isReachable ? "Sending Live Vitals" : "Syncing in background"
        }

        if isReachable {
            return "Connecting"
        }

        return "Waiting for iPhone"
    }

    private func statusColor(isReachable: Bool) -> Color {
        connectivity.hasSentPayload ? .green : .yellow
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
