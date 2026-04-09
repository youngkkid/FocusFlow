import SwiftUI

struct OnboardingView: View {
    struct Slide: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let systemImage: String
    }

    let onFinish: () -> Void

    @State private var index: Int = 0

    private let slides: [Slide] = [
        Slide(
            title: "Make time visible",
            subtitle: "Run a focus timer and build a simple, repeatable routine.",
            systemImage: "timer"
        ),
        Slide(
            title: "Build momentum",
            subtitle: "Track sessions and watch your week trend grow.",
            systemImage: "chart.xyaxis.line"
        ),
        Slide(
            title: "Stay intentional",
            subtitle: "Create habits to keep your focus sessions organized.",
            systemImage: "checklist"
        ),
    ]

    var body: some View {
        ZStack {
            FFColor.background.ignoresSafeArea()

            VStack(spacing: 18) {
                TabView(selection: $index) {
                    ForEach(Array(slides.enumerated()), id: \.offset) { i, slide in
                        VStack(spacing: 18) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(FFColor.gradient)
                                    .frame(width: 110, height: 110)
                                    .shadow(color: FFColor.brand.opacity(0.22), radius: 18, x: 0, y: 10)

                                Image(systemName: slide.systemImage)
                                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.96))
                            }
                            .padding(.top, 18)

                            VStack(spacing: 8) {
                                Text(slide.title)
                                    .font(.system(.title, design: .rounded).weight(.semibold))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(FFColor.primaryText)

                                Text(slide.subtitle)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(FFColor.secondaryText)
                                    .frame(maxWidth: 420)
                            }
                            .padding(.horizontal, 26)

                            Spacer(minLength: 0)
                        }
                        .tag(i)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))

                VStack(spacing: 10) {
                    Button {
                        if index < slides.count - 1 {
                            withAnimation(.easeInOut(duration: 0.25)) { index += 1 }
                        } else {
                            onFinish()
                        }
                    } label: {
                        Label(index < slides.count - 1 ? "Continue" : "Get Started", systemImage: "arrow.right")
                    }
                    .buttonStyle(FFPrimaryButtonStyle())

                    Button {
                        onFinish()
                    } label: {
                        Text("Skip")
                            .font(.subheadline)
                    }
                    .foregroundStyle(FFColor.secondaryText)
                    .padding(.bottom, 6)
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}

