import SwiftUI

// MARK: - Sticky note

struct StickyNoteView: View {
    let term: ProcessTerm
    var colorIndex: Int
    var adhd: Bool
    var size: CGFloat = 150

    var body: some View {
        ZStack {
            // Papel del sticky con una leve sombra y esquina "doblada".
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Theme.stickyColor(index: colorIndex, adhd: adhd))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(adhd ? Theme.deepPurple.opacity(0.8) : Color.black.opacity(0.06),
                                      lineWidth: adhd ? 3 : 1)
                )
                .shadow(color: Theme.deepPurple.opacity(0.18), radius: 8, y: 5)

            VStack(spacing: 6) {
                // "Cinta" superior del sticky.
                Capsule()
                    .fill(Color.white.opacity(0.65))
                    .frame(width: size * 0.35, height: 8)

                Text(term.title)
                    .font(adhd ? .headline : .subheadline.weight(.semibold))
                    .foregroundStyle(Theme.deepPurple)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 10)
            }
            .padding(.vertical, 10)
        }
        .frame(width: size, height: size * 0.78)
        .rotationEffect(.degrees(adhd ? 0 : -2))
        .accessibilityLabel("Sticky note: \(term.title). Arrástralo a la celda correcta de la matriz.")
    }
}

// MARK: - Manos en primera persona (POV)

/// Silueta minimalista de manos sosteniendo el sticky, para la sensación POV.
struct HandsPOVView: View {
    var body: some View {
        HStack(spacing: 90) {
            handShape(mirrored: false)
            handShape(mirrored: true)
        }
        .accessibilityHidden(true)
    }

    private func handShape(mirrored: Bool) -> some View {
        ZStack {
            // Palma
            Ellipse()
                .fill(Theme.lavender.opacity(0.85))
                .frame(width: 54, height: 70)
            // Pulgar
            Capsule()
                .fill(Theme.lavender.opacity(0.85))
                .frame(width: 20, height: 44)
                .rotationEffect(.degrees(mirrored ? -35 : 35))
                .offset(x: mirrored ? 22 : -22, y: -14)
        }
        .rotationEffect(.degrees(mirrored ? 12 : -12))
        .shadow(color: Theme.deepPurple.opacity(0.12), radius: 4, y: 2)
    }
}

// MARK: - Avatar guía

struct AvatarGuideView: View {
    let mode: GameMode
    let phrase: String
    let isDelivering: Bool
    var adhd: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(mode.accent.opacity(0.35))
                        .frame(width: 58, height: 58)
                    Image(systemName: mode.avatarSymbol)
                        .font(.system(size: 30))
                        .foregroundStyle(Theme.purple)
                        .symbolRenderingMode(.hierarchical)
                }
                .scaleEffect(isDelivering && !adhd ? 1.08 : 1.0)

                Text(mode.avatarName)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.deepPurple)
            }

            if !phrase.isEmpty {
                // Burbuja de diálogo con el lenguaje del modo activo.
                Text(phrase)
                    .font(adhd ? .callout.weight(.semibold) : .footnote)
                    .foregroundStyle(Theme.deepPurple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: Theme.deepPurple.opacity(0.10), radius: 5, y: 3)
                    )
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(mode.avatarName) dice: \(phrase)")
    }
}

// MARK: - Selector de modo Agile / Predictive

struct ModeToggleView: View {
    @Binding var mode: GameMode
    var compact = false

    var body: some View {
        HStack(spacing: 6) {
            ForEach(GameMode.allCases) { candidate in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        mode = candidate
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: candidate.icon)
                        if !compact {
                            Text(candidate.title)
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                    .padding(.horizontal, compact ? 10 : 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule().fill(mode == candidate
                                       ? candidate.accent.opacity(0.55)
                                       : Color.white.opacity(0.7))
                    )
                    .overlay(
                        Capsule().strokeBorder(mode == candidate ? Theme.purple : Color.clear,
                                               lineWidth: 2)
                    )
                    .foregroundStyle(Theme.deepPurple)
                }
                .accessibilityLabel("Modo \(candidate.title)")
                .accessibilityAddTraits(mode == candidate ? .isSelected : [])
            }
        }
    }
}

// MARK: - Toggle ADHD Friendly

struct ADHDModeToggle: View {
    @Binding var isOn: Bool
    var compact = false

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) { isOn.toggle() }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "target")   // icono de enfoque
                if !compact {
                    Text("ADHD Friendly")
                        .font(.subheadline.weight(.semibold))
                }
            }
            .padding(.horizontal, compact ? 10 : 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(isOn ? Theme.purple : Color.white.opacity(0.7)))
            .foregroundStyle(isOn ? .white : Theme.deepPurple)
        }
        .accessibilityLabel("Modo ADHD Friendly")
        .accessibilityValue(isOn ? "activado" : "desactivado")
        .accessibilityHint("Simplifica la pantalla y reduce las animaciones.")
    }
}

// MARK: - Confetti púrpura

/// Explosión breve de partículas púrpura/lavanda al acertar.
struct ConfettiView: View {
    let trigger: Int

    private struct Particle: Identifiable {
        let id = UUID()
        let angle: Double
        let distance: CGFloat
        let size: CGFloat
        let color: Color
        let spin: Double
    }

    @State private var particles: [Particle] = []
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                RoundedRectangle(cornerRadius: 2)
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size * 1.6)
                    .rotationEffect(.degrees(animate ? particle.spin : 0))
                    .offset(
                        x: animate ? cos(particle.angle) * particle.distance : 0,
                        y: animate ? sin(particle.angle) * particle.distance : 0
                    )
                    .opacity(animate ? 0 : 1)
            }
        }
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, _ in burst() }
    }

    private func burst() {
        let colors = [Theme.brightPurple, Theme.lavender, Theme.softAqua, Theme.purple, .white]
        particles = (0..<26).map { index in
            Particle(
                angle: Double(index) / 26.0 * 2 * .pi + .random(in: -0.2...0.2),
                distance: .random(in: 70...150),
                size: .random(in: 6...11),
                color: colors.randomElement() ?? Theme.purple,
                spin: .random(in: -260...260)
            )
        }
        animate = false
        withAnimation(.easeOut(duration: 0.8)) { animate = true }
        Task {
            try? await Task.sleep(for: .seconds(0.9))
            particles = []
            animate = false
        }
    }
}

// MARK: - Toast de medalla

struct MedalToast: View {
    let medal: Medal

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: medal.icon)
                .font(.title3)
                .foregroundStyle(Theme.brightPurple)
            VStack(alignment: .leading, spacing: 2) {
                Text("¡Medalla: \(medal.rawValue)!")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.deepPurple)
                Text(medal.spanishDescription)
                    .font(.caption)
                    .foregroundStyle(Theme.deepPurple.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule().fill(.white)
                .shadow(color: Theme.brightPurple.opacity(0.3), radius: 10, y: 4)
        )
        .accessibilityLabel("Nueva medalla: \(medal.rawValue). \(medal.spanishDescription)")
    }
}
