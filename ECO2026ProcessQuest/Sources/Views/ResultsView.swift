import SwiftUI

/// Pantalla final: score, % de aciertos, medallas, progreso por dominio,
/// procesos dominados y procesos a repasar.
struct ResultsView: View {
    @Environment(GameEngine.self) private var engine

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(engine.practiceMode ? "Práctica completada" : "¡Quest completada!")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(Theme.deepPurple)
                    .padding(.top, 24)

                scoreCard

                if !engine.medals.isEmpty { medalsSection }

                domainProgressSection

                if !engine.masteredTerms.isEmpty {
                    termList(title: "Procesos dominados",
                             icon: "checkmark.circle.fill",
                             tint: Theme.brightPurple,
                             terms: engine.masteredTerms)
                }

                if !engine.termsToReview.isEmpty {
                    termList(title: "Procesos a repasar",
                             icon: "arrow.counterclockwise.circle.fill",
                             tint: Theme.softCoral,
                             terms: engine.termsToReview)
                }

                buttons
                    .padding(.bottom, 30)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: Score

    private var scoreCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Theme.lavender.opacity(0.4), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: engine.accuracy)
                    .stroke(
                        LinearGradient(colors: [Theme.brightPurple, engine.mode.accent],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    Text("\(engine.score)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.deepPurple)
                    Text("puntos")
                        .font(.caption)
                        .foregroundStyle(Theme.deepPurple.opacity(0.6))
                }
            }
            .frame(width: 150, height: 150)
            .accessibilityLabel("Puntaje final: \(engine.score) puntos")

            HStack(spacing: 24) {
                stat(value: "\(Int(engine.accuracy * 100))%", label: "aciertos")
                stat(value: "\(engine.bestStreak)", label: "mejor racha")
                stat(value: "\(engine.totalCorrect)", label: "colocados")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(card)
    }

    private func stat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.purple)
            Text(label)
                .font(.caption)
                .foregroundStyle(Theme.deepPurple.opacity(0.6))
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: Medallas

    private var medalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Medallas")
            HStack(spacing: 14) {
                ForEach(Medal.allCases.filter { engine.medals.contains($0) }) { medal in
                    VStack(spacing: 6) {
                        Image(systemName: medal.icon)
                            .font(.title2)
                            .foregroundStyle(Theme.brightPurple)
                            .frame(width: 54, height: 54)
                            .background(Circle().fill(Theme.paleLavender))
                        Text(medal.rawValue)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Theme.deepPurple)
                    }
                    .accessibilityLabel("Medalla \(medal.rawValue): \(medal.spanishDescription)")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(card)
    }

    // MARK: Progreso por dominio

    private var domainProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Progreso por dominio")
            ForEach(PerformanceDomain.allCases) { domain in
                let total = ProcessData.allTerms.filter { $0.performanceDomain == domain }.count
                let done = engine.masteredTerms.filter { $0.performanceDomain == domain }.count
                    + engine.termsToReview.filter { $0.performanceDomain == domain }.count
                HStack(spacing: 10) {
                    Image(systemName: domain.icon)
                        .font(.caption)
                        .foregroundStyle(Theme.purple)
                        .frame(width: 22)
                    Text(domain.rawValue)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.deepPurple)
                        .frame(width: 96, alignment: .leading)
                    ProgressView(value: Double(done), total: Double(max(total, 1)))
                        .tint(Theme.brightPurple)
                    Text("\(done)/\(total)")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(Theme.deepPurple.opacity(0.6))
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(domain.rawValue): \(done) de \(total) procesos")
            }
        }
        .padding(20)
        .background(card)
    }

    // MARK: Listas de términos

    private func termList(title: String, icon: String, tint: Color, terms: [ProcessTerm]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title)
            ForEach(terms) { term in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: icon)
                        .font(.footnote)
                        .foregroundStyle(tint)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(term.title)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Theme.deepPurple)
                        Text("\(term.performanceDomain.spanishName) · \(term.focusArea.rawValue)")
                            .font(.caption2)
                            .foregroundStyle(Theme.deepPurple.opacity(0.55))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(card)
    }

    // MARK: Botones

    private var buttons: some View {
        VStack(spacing: 12) {
            Button {
                engine.startGame()
            } label: {
                Text("Jugar de nuevo")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(LinearGradient(colors: [Theme.brightPurple, Theme.purple],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
            }
            .accessibilityLabel("Jugar de nuevo desde el nivel 1")

            Button {
                engine.startGame(practice: true)
            } label: {
                Text("Modo práctica")
                    .font(.headline)
                    .foregroundStyle(Theme.purple)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Theme.purple, lineWidth: 2)
                    )
            }
            .accessibilityLabel("Modo práctica: todos los procesos, sin niveles")

            Button("Volver al inicio") {
                engine.backToOnboarding()
            }
            .font(.subheadline)
            .foregroundStyle(Theme.deepPurple.opacity(0.6))
        }
    }

    // MARK: Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(Theme.deepPurple)
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(.white)
            .shadow(color: Theme.purple.opacity(0.10), radius: 10, y: 5)
    }
}
