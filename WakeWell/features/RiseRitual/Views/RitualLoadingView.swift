import SwiftUI

struct RitualLoadingView: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            RiseRitualBackground()

            VStack(spacing: 22) {
                Image(systemName: "sparkles")
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(Color(riseHex: "#FFD36A"))
                    .scaleEffect(pulse ? 1.12 : 0.92)
                    .opacity(pulse ? 1 : 0.72)
                    .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)

                Text("Building your rise ritual...")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { pulse = true }
    }
}
