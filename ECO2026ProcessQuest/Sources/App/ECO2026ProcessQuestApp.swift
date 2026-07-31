import SwiftUI

@main
struct ECO2026ProcessQuestApp: App {
    // El engine es la única fuente de verdad del juego y se inyecta por environment.
    @State private var engine = GameEngine()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(engine)
        }
    }
}

/// Enruta entre las tres pantallas principales según el estado del engine.
struct RootView: View {
    @Environment(GameEngine.self) private var engine

    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()

            switch engine.screen {
            case .onboarding:
                OnboardingView()
                    .transition(.opacity)
            case .game:
                GameView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .results:
                ResultsView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(engine.adhdMode ? .easeInOut(duration: 0.2) : .easeInOut(duration: 0.4),
                   value: engine.screen)
    }
}
