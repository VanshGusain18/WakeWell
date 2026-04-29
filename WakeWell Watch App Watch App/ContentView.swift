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
        VStack {
            Text("Streaming to iPhone...")
                .font(.headline)
            Text("HR: \(String(format: "%.1f", connectivity.lastHeartRate))")
                .font(.title3.bold())
            Text(connectivity.statusText)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
