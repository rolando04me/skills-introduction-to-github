import Foundation
import Observation
import SwiftUI

/// Fuente de verdad del juego: niveles, puntaje, racha, medallas,
/// entrega de stickies y validación de colocaciones.
@Observable
@MainActor
final class GameEngine {

    // MARK: - Configuración elegida por el usuario
    var mode: GameMode = .agile
    var adhdMode = false {
        didSet { syncFocusAudio() }
    }
    var soundOn = true {
        didSet {
            AudioManager.shared.setMuted(!soundOn)
            syncFocusAudio()
        }
    }
    /// Sonido de concentración (ambient) — opcional, pensado para el modo ADHD.
    var focusSoundOn = false {
        didSet { syncFocusAudio() }
    }

    // MARK: - Estado de pantalla y fase
    var screen: Screen = .onboarding
    var phase: GamePhase = .delivering
    var practiceMode = false

    // MARK: - Progreso de la partida
    var level = 1
    var score = 0
    var streak = 0
    var bestStreak = 0
    var hintLevel = 0                       // 0 = sin pista, 1 = dominio, 2 = focus area, 3 = explicación
    var feedback: FeedbackMessage?
    var deliveryPhrase = ""

    var currentTerm: ProcessTerm?
    private var queue: [ProcessTerm] = []
    var roundTotal = 0
    var roundPlaced = 0

    /// Stickies ya pegados en la tabla, por celda.
    var placements: [CellKey: [ProcessTerm]] = [:]

    /// Última celda donde se soltó un sticky, para el borde púrpura/coral.
    var lastDropCell: CellKey?
    var lastDropCorrect = false

    // MARK: - Estadísticas de la sesión
    private var errorsPerTerm: [UUID: Int] = [:]
    private var completedTerms: [ProcessTerm] = []
    var totalAttempts = 0
    var totalCorrect = 0
    private var planningHits = 0
    private var closingHits = 0
    private var riskCorrect = 0
    private var riskErrors = 0
    private var adhdActiveWholeRound = false
    var medals: Set<Medal> = []
    var newMedal: Medal?                    // para el toast de medalla

    private let termsPerLevel = 6
    private let maxLevel = 4
    private var stickyCounter = 0           // rota el color del sticky

    var stickyColorIndex: Int { stickyCounter }

    var domainsInPlay: [PerformanceDomain] {
        practiceMode ? PerformanceDomain.allCases.map { $0 }
                     : ProcessData.domains(forLevel: level)
    }

    var progress: Double {
        roundTotal == 0 ? 0 : Double(roundPlaced) / Double(roundTotal)
    }

    var accuracy: Double {
        totalAttempts == 0 ? 0 : Double(totalCorrect) / Double(totalAttempts)
    }

    /// Procesos dominados: colocados al primer intento.
    var masteredTerms: [ProcessTerm] {
        completedTerms.filter { (errorsPerTerm[$0.id] ?? 0) == 0 }
    }

    /// Procesos a repasar: requirieron más de un intento.
    var termsToReview: [ProcessTerm] {
        completedTerms.filter { (errorsPerTerm[$0.id] ?? 0) > 0 }
    }

    // MARK: - Ciclo de juego

    func startGame(practice: Bool = false) {
        practiceMode = practice
        level = practice ? 4 : 1
        score = 0
        streak = 0
        bestStreak = 0
        totalAttempts = 0
        totalCorrect = 0
        planningHits = 0
        closingHits = 0
        riskCorrect = 0
        riskErrors = 0
        errorsPerTerm = [:]
        completedTerms = []
        placements = [:]
        medals = []
        newMedal = nil
        screen = .game
        startLevel()
    }

    func backToOnboarding() {
        screen = .onboarding
        AudioManager.shared.setFocusLoop(enabled: false)
    }

    private func startLevel() {
        adhdActiveWholeRound = adhdMode
        placements = [:]
        let pool = practiceMode ? ProcessData.allTerms : ProcessData.terms(forLevel: level)
        queue = Array(pool.shuffled().prefix(practiceMode ? pool.count : termsPerLevel))
        roundTotal = queue.count
        roundPlaced = 0
        deliverNext()
    }

    /// El avatar entrega el siguiente sticky (animación de traspaso al POV).
    private func deliverNext() {
        guard let next = queue.first else {
            finishLevel()
            return
        }
        queue.removeFirst()
        stickyCounter += 1
        currentTerm = next
        hintLevel = 0
        feedback = nil
        deliveryPhrase = mode.deliveryPhrases.randomElement() ?? ""
        phase = .delivering

        // Tras la entrega, pasa a la vista en primera persona (manos + sticky).
        Task {
            try? await Task.sleep(for: .seconds(self.adhdMode ? 0.5 : 1.0))
            guard self.phase == .delivering else { return }
            withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                self.phase = .holding
            }
        }
    }

    /// Valida el drop del sticky sobre una celda. Devuelve true si fue correcto.
    @discardableResult
    func attemptPlacement(in cell: CellKey) -> Bool {
        guard let term = currentTerm, phase == .holding else { return false }
        totalAttempts += 1
        lastDropCell = cell
        let correct = cell == term.correctCell
        lastDropCorrect = correct

        if correct {
            handleCorrect(term: term)
        } else {
            handleWrong(term: term)
        }

        // Limpia el resaltado de la celda tras un instante.
        Task {
            try? await Task.sleep(for: .seconds(0.9))
            self.lastDropCell = nil
        }
        return correct
    }

    private func handleCorrect(term: ProcessTerm) {
        totalCorrect += 1
        streak += 1
        bestStreak = max(bestStreak, streak)

        // Puntos: base + bonus por racha − costo de pistas usadas.
        let base = 10
        let streakBonus = min(streak - 1, 5) * 2
        let hintCost = hintLevel * 3
        score += max(2, base + streakBonus - hintCost)

        placements[term.correctCell, default: []].append(term)
        completedTerms.append(term)
        roundPlaced += 1

        if term.focusArea == .planning { planningHits += 1 }
        if term.focusArea == .closing { closingHits += 1 }
        if term.performanceDomain == .risk { riskCorrect += 1 }

        let cheer = mode.successPhrases.randomElement() ?? "¡Correcto!"
        feedback = FeedbackMessage(
            text: adhdMode
                ? "Correcto. \(term.performanceDomain.spanishName) + \(term.focusArea.shortName)."
                : "\(cheer) Correcto: este proceso pertenece a \(term.performanceDomain.spanishName) en \(term.focusArea.rawValue). \(term.explanation)",
            isSuccess: true
        )
        AudioManager.shared.playSuccess()
        phase = .celebrating
        checkInRoundMedals()

        // Pausa educativa: el usuario lee el porqué antes del siguiente sticky.
        Task {
            try? await Task.sleep(for: .seconds(self.adhdMode ? 1.6 : 2.4))
            guard self.phase == .celebrating else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                self.feedback = nil
                self.deliverNext()
            }
        }
    }

    private func handleWrong(term: ProcessTerm) {
        streak = 0
        errorsPerTerm[term.id, default: 0] += 1
        if term.performanceDomain == .risk { riskErrors += 1 }

        feedback = FeedbackMessage(
            text: adhdMode
                ? "Casi. Intenta otra celda."
                : "Casi. Piensa si este proceso ocurre al inicio, durante la planificación, ejecución, control o cierre. ¡Inténtalo de nuevo!",
            isSuccess: false
        )
        AudioManager.shared.playSoftError()
        // El usuario permanece en .holding y puede volver a intentar.
    }

    /// Pista progresiva: 1º dominio, 2º focus area, 3º explicación completa.
    func requestHint() {
        guard let term = currentTerm, hintLevel < 3 else { return }
        hintLevel += 1
        let text: String
        switch hintLevel {
        case 1:  text = "Pista: pertenece al dominio \(term.performanceDomain.spanishName)."
        case 2:  text = "Pista: ocurre \(term.focusArea.spanishPhase) (\(term.focusArea.rawValue))."
        default: text = "Pista: \(term.explanation)"
        }
        feedback = FeedbackMessage(text: text, isSuccess: false)
    }

    private func finishLevel() {
        if adhdActiveWholeRound && adhdMode {
            award(.focusMode)
        }
        if practiceMode || level >= maxLevel {
            finishSession()
            return
        }
        phase = .levelUp
        Task {
            try? await Task.sleep(for: .seconds(self.adhdMode ? 1.0 : 1.6))
            self.level += 1
            self.startLevel()
        }
    }

    private func finishSession() {
        // Risk Master: completó procesos de Riesgo sin ningún fallo en ese dominio.
        let riskTotal = ProcessData.allTerms.filter { $0.performanceDomain == .risk }.count
        if riskCorrect >= min(riskTotal, 3) && riskErrors == 0 {
            award(.riskMaster)
        }
        currentTerm = nil
        AudioManager.shared.setFocusLoop(enabled: false)
        screen = .results
    }

    // MARK: - Medallas

    private func checkInRoundMedals() {
        if planningHits >= 5 { award(.planner) }
        if closingHits >= 3 { award(.closer) }
    }

    private func award(_ medal: Medal) {
        guard !medals.contains(medal) else { return }
        medals.insert(medal)
        newMedal = medal
        Task {
            try? await Task.sleep(for: .seconds(2.2))
            if self.newMedal == medal { self.newMedal = nil }
        }
    }

    // MARK: - Audio helpers

    private func syncFocusAudio() {
        let shouldPlay = focusSoundOn && soundOn && screen == .game
        AudioManager.shared.setFocusLoop(enabled: shouldPlay)
    }
}
