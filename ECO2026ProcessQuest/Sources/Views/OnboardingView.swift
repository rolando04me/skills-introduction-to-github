import SwiftUI

/// Pantalla inicial: título, selector Agile/Predictive, toggle ADHD y "Comenzar".
/// Intencionalmente simple para no saturar la primera pantalla.
struct OnboardingView: View {
    @Environment(GameEngine.self) private var engine

    var body: some View {
        @Bindable var engine = engine

        VStack(spacing: 28) {
            Spacer()

            // Marca del juego: mini matriz con un sticky, sin logos oficiales.
            logoMark

            VStack(spacing: 10) {
                Text("ECO 2026 Process Quest")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(Theme.deepPurple)
                    .multilineTextAlignment(.center)

                Text("Aprende los procesos jugando con la matriz.")
                    .font(.title3)
                    .foregroundStyle(Theme.deepPurple.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)

            VStack(spacing: 16) {
                Text("Elige tu enfoque")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Theme.deepPurple.opacity(0.6))
                    .textCase(.uppercase)

                ModeToggleView(mode: $engine.mode)
                ADHDModeToggle(isOn: $engine.adhdMode)
            }

            Spacer()

            Button {
                engine.startGame()
            } label: {
                Text("Comenzar")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(LinearGradient(colors: [Theme.brightPurple, Theme.purple],
                                                 startPoint: .topLeading,
                                                 endPoint: .bottomTrailing))
                            .shadow(color: Theme.brightPurple.opacity(0.35), radius: 12, y: 6)
                    )
            }
            .padding(.horizontal, 32)
            .accessibilityLabel("Comenzar el juego")

            Text("ECO 2026 Practice Game · Juego educativo independiente,\nsin afiliación con PMI.")
                .font(.caption2)
                .foregroundStyle(Theme.deepPurple.opacity(0.45))
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)
        }
    }

    private var logoMark: some View {
        ZStack {
            // Mini matriz 3x3 estilizada.
            VStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 5) {
                        ForEach(0..<3, id: \.self) { col in
                            RoundedRectangle(cornerRadius: 5)
                                .fill(cellColor(row: row, col: col))
                                .frame(width: 26, height: 26)
                        }
                    }
                }
            }
            // Sticky "pegado" sobre la matriz.
            RoundedRectangle(cornerRadius: 5)
                .fill(Theme.stickyYellow)
                .frame(width: 30, height: 30)
                .rotationEffect(.degrees(-8))
                .offset(x: 26, y: -22)
                .shadow(color: Theme.deepPurple.opacity(0.25), radius: 4, y: 2)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.white)
                .shadow(color: Theme.purple.opacity(0.18), radius: 16, y: 8)
        )
        .accessibilityHidden(true)
    }

    private func cellColor(row: Int, col: Int) -> Color {
        if row == 0 { return Theme.purple.opacity(0.85) }
        if col == 0 { return Theme.lavender }
        return (row + col).isMultiple(of: 2) ? Theme.paleLavender : Theme.softBlueTint
    }
}
