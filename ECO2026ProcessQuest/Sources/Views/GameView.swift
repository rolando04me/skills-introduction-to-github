import SwiftUI

/// Pantalla principal de juego: header, matriz interactiva, avatar que
/// entrega stickies y zona POV para arrastrarlos a la celda correcta.
struct GameView: View {
    @Environment(GameEngine.self) private var engine
    @Namespace private var stickyNS

    // Estado local del drag (la validación vive en el engine).
    @State private var cellFrames: [CellKey: CGRect] = [:]
    @State private var hoveredCell: CellKey?
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var confettiTrigger = 0
    @State private var confettiCenter: CGPoint = .zero

    static let spaceName = "gameSpace"

    var body: some View {
        @Bindable var engine = engine

        GeometryReader { geo in
            ZStack {
                VStack(spacing: 10) {
                    header
                    controlsRow(engine: $engine)
                    progressBar

                    ProcessMatrixView(
                        hoveredCell: hoveredCell,
                        coordinateSpaceName: Self.spaceName,
                        onCellTap: { key in place(in: key) }
                    )
                    .frame(maxHeight: .infinity)

                    feedbackBanner
                    bottomZone
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 6)
                .animation(.easeInOut(duration: 0.25), value: engine.feedback)

                // Confetti púrpura sobre la celda acertada (omitido en modo ADHD).
                ConfettiView(trigger: confettiTrigger)
                    .position(confettiCenter == .zero
                              ? CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                              : confettiCenter)

                if engine.phase == .levelUp { levelUpBanner }

                if let medal = engine.newMedal {
                    VStack {
                        MedalToast(medal: medal)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        Spacer()
                    }
                    .padding(.top, 14)
                }
            }
            .coordinateSpace(name: Self.spaceName)
        }
        .onPreferenceChange(CellFramePreferenceKey.self) { cellFrames = $0 }
        .animation(.easeInOut(duration: 0.25), value: engine.newMedal)
    }

    // MARK: - Header compacto

    private var header: some View {
        HStack(spacing: 10) {
            Button {
                engine.backToOnboarding()
            } label: {
                Image(systemName: "xmark")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(Theme.deepPurple.opacity(0.6))
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(.white.opacity(0.8)))
            }
            .accessibilityLabel("Salir al inicio")

            chip(icon: "star.circle.fill",
                 text: engine.practiceMode ? "Práctica" : "Nivel \(engine.level)")
            chip(icon: "sum", text: "\(engine.score) pts")
            chip(icon: "flame.fill", text: "x\(engine.streak)",
                 tint: engine.streak > 0 ? Theme.brightPurple : Theme.deepPurple.opacity(0.4))

            Spacer()

            // Sonido de concentración opcional (ambient suave).
            Button {
                engine.focusSoundOn.toggle()
            } label: {
                Image(systemName: engine.focusSoundOn ? "headphones.circle.fill" : "headphones.circle")
                    .font(.title3)
                    .foregroundStyle(engine.focusSoundOn ? Theme.purple : Theme.deepPurple.opacity(0.45))
            }
            .accessibilityLabel("Sonido de concentración")
            .accessibilityValue(engine.focusSoundOn ? "activado" : "desactivado")

            Button {
                engine.soundOn.toggle()
            } label: {
                Image(systemName: engine.soundOn ? "speaker.wave.2.circle.fill" : "speaker.slash.circle")
                    .font(.title3)
                    .foregroundStyle(engine.soundOn ? Theme.purple : Theme.deepPurple.opacity(0.45))
            }
            .accessibilityLabel("Sonido")
            .accessibilityValue(engine.soundOn ? "activado" : "silenciado")
        }
    }

    private func chip(icon: String, text: String, tint: Color = Theme.deepPurple) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption.weight(.bold).monospacedDigit())
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Capsule().fill(.white.opacity(0.85)))
    }

    // MARK: - Selector de modo + ADHD

    private func controlsRow(engine: Bindable<GameEngine>) -> some View {
        HStack {
            ModeToggleView(mode: engine.mode, compact: true)
            Spacer()
            ADHDModeToggle(isOn: engine.adhdMode, compact: true)
        }
    }

    // MARK: - Barra de progreso de la ronda

    private var progressBar: some View {
        VStack(spacing: 3) {
            if engine.adhdMode {
                // Instrucción corta y clara en modo enfoque.
                Text("Arrastra el sticky a su celda.")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(Theme.deepPurple)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.lavender.opacity(0.35))
                    Capsule()
                        .fill(LinearGradient(colors: [Theme.brightPurple, engine.mode.accent],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(8, geo.size.width * engine.progress))
                        .animation(.spring(response: 0.5, dampingFraction: 0.9), value: engine.progress)
                }
            }
            .frame(height: engine.adhdMode ? 12 : 7)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progreso de la ronda: \(engine.roundPlaced) de \(engine.roundTotal)")
    }

    // MARK: - Feedback educativo

    @ViewBuilder
    private var feedbackBanner: some View {
        if let feedback = engine.feedback {
            HStack(spacing: 8) {
                Image(systemName: feedback.isSuccess ? "checkmark.circle.fill" : "lightbulb.fill")
                    .foregroundStyle(feedback.isSuccess ? Theme.brightPurple : Theme.softCoral)
                Text(feedback.text)
                    .font(engine.adhdMode ? .callout.weight(.semibold) : .footnote)
                    .foregroundStyle(Theme.deepPurple)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(feedback.isSuccess ? Theme.brightPurple.opacity(0.5)
                                                             : Theme.softCoral.opacity(0.6),
                                          lineWidth: 1.5)
                    )
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Zona inferior: avatar + sticky POV + pista

    private var bottomZone: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top) {
                AvatarGuideView(mode: engine.mode,
                                phrase: engine.phase == .delivering ? engine.deliveryPhrase : "",
                                isDelivering: engine.phase == .delivering,
                                adhd: engine.adhdMode)

                // Sticky pequeño en manos del avatar durante la entrega.
                if engine.phase == .delivering, let term = engine.currentTerm {
                    StickyNoteView(term: term,
                                   colorIndex: engine.stickyColorIndex,
                                   adhd: engine.adhdMode,
                                   size: 86)
                        .matchedGeometryEffect(id: "activeSticky", in: stickyNS)
                }

                Spacer()

                Button {
                    engine.requestHint()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "lightbulb")
                        Text("Pista")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.purple)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(Capsule().strokeBorder(Theme.purple, lineWidth: 1.5))
                }
                .disabled(engine.phase != .holding || engine.hintLevel >= 3)
                .opacity(engine.phase == .holding && engine.hintLevel < 3 ? 1 : 0.35)
                .accessibilityLabel("Pedir una pista")
                .accessibilityHint("Revela primero el dominio, luego el focus area y luego la explicación.")
            }

            // POV: manos del usuario sosteniendo el sticky, listo para arrastrar.
            ZStack {
                if engine.phase == .holding, let term = engine.currentTerm {
                    ZStack(alignment: .bottom) {
                        HandsPOVView()
                            .offset(y: 26)
                        StickyNoteView(term: term,
                                       colorIndex: engine.stickyColorIndex,
                                       adhd: engine.adhdMode,
                                       size: engine.adhdMode ? 170 : 150)
                            .matchedGeometryEffect(id: "activeSticky", in: stickyNS)
                    }
                    .scaleEffect(isDragging ? 1.06 : 1)
                    .offset(dragOffset)
                    .gesture(stickyDragGesture)
                    .zIndex(10)
                } else if engine.phase == .celebrating {
                    // Espacio reservado mientras se lee el feedback.
                    Color.clear
                }
            }
            .frame(height: engine.adhdMode ? 150 : 132)
        }
    }

    // MARK: - Drag & drop

    private var stickyDragGesture: some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .named(Self.spaceName))
            .onChanged { value in
                guard engine.phase == .holding else { return }
                isDragging = true
                dragOffset = value.translation
                hoveredCell = cellKey(at: value.location)
            }
            .onEnded { value in
                guard engine.phase == .holding else { return }
                isDragging = false
                hoveredCell = nil
                if let target = cellKey(at: value.location) {
                    place(in: target)
                } else {
                    // Soltado fuera de la tabla: el sticky regresa a las manos.
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                        dragOffset = .zero
                    }
                }
            }
    }

    /// Valida la colocación (por drag o por toque de celda) y anima el resultado.
    private func place(in key: CellKey) {
        guard engine.phase == .holding else { return }
        let correct = engine.attemptPlacement(in: key)
        if correct {
            if let frame = cellFrames[key] {
                confettiCenter = CGPoint(x: frame.midX, y: frame.midY)
            }
            if !engine.adhdMode { confettiTrigger += 1 }
            dragOffset = .zero
        } else {
            // Rebote suave hacia las manos + pista corta (la pone el engine).
            withAnimation(.spring(response: 0.45, dampingFraction: 0.5)) {
                dragOffset = .zero
            }
        }
    }

    private func cellKey(at point: CGPoint) -> CellKey? {
        cellFrames.first(where: { $0.value.contains(point) })?.key
    }

    // MARK: - Banner de nivel

    private var levelUpBanner: some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Theme.brightPurple)
            Text("¡Nivel \(engine.level) superado!")
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.deepPurple)
            Text("Preparando nivel \(engine.level + 1)…")
                .font(.subheadline)
                .foregroundStyle(Theme.deepPurple.opacity(0.6))
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white)
                .shadow(color: Theme.brightPurple.opacity(0.3), radius: 18, y: 8)
        )
        .transition(.scale.combined(with: .opacity))
        .accessibilityLabel("Nivel \(engine.level) superado. Preparando nivel \(engine.level + 1).")
    }
}
