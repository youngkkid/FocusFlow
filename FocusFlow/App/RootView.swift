import SwiftUI

struct RootView: View {
    @StateObject private var appModel = AppModel()
    @State private var didFinishSplash = false
    @AppStorage("FocusFlow.hasSeenOnboarding.v1") private var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            if didFinishSplash {
                if hasSeenOnboarding {
                    MainTabView()
                        .environmentObject(appModel)
                        .transition(.opacity)
                } else {
                    OnboardingView {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            hasSeenOnboarding = true
                        }
                    }
                    .transition(.opacity)
                }
            } else {
                SplashView()
                    .transition(.opacity)
                    .onAppear {
                        Task { @MainActor in
                            // Keep short: should feel instant but intentional.
                            try? await Task.sleep(nanoseconds: 1_100_000_000)
                            withAnimation(.easeInOut(duration: 0.35)) {
                                didFinishSplash = true
                            }
                        }
                    }
            }
        }
        .preferredColorScheme(appModel.settings.preferredColorScheme)
    }
}

#Preview {
    RootView()
}

