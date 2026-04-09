import SwiftUI

struct SplashView: View {
    @State private var spin = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            FFColor.background.ignoresSafeArea()

            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(FFColor.gradient)
                        .frame(width: 92, height: 92)
                        .shadow(color: FFColor.brand.opacity(0.25), radius: 18, x: 0, y: 10)
                        .scaleEffect(pulse ? 1.04 : 0.96)
                        .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)

                    Circle()
                        .trim(from: 0.12, to: 0.88)
                        .stroke(.white.opacity(0.95), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 62, height: 62)
                        .rotationEffect(.degrees(spin ? 360 : 0))
                        .animation(.linear(duration: 1.1).repeatForever(autoreverses: false), value: spin)

                    Image(systemName: "timer")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.95))
                }

                VStack(spacing: 6) {
                    Text("FocusFlow")
                        .font(.system(.title2, design: .rounded).weight(.semibold))
                        .foregroundStyle(FFColor.primaryText)

                    Text("Make time visible.")
                        .font(.subheadline)
                        .foregroundStyle(FFColor.secondaryText)
                }
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            spin = true
            pulse = true
        }
    }
}

#Preview {
    SplashView()
}

