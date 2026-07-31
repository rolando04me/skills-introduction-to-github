import Foundation
import SwiftUI

// MARK: - Performance Domains (filas de la matriz)

enum PerformanceDomain: String, CaseIterable, Codable, Identifiable, Hashable {
    case governance   = "Governance"
    case scope        = "Scope"
    case schedule     = "Schedule"
    case finance      = "Finance"
    case stakeholders = "Stakeholders"
    case resources    = "Resources"
    case risk         = "Risk"

    var id: String { rawValue }

    /// Nombre en español para feedback y pistas.
    var spanishName: String {
        switch self {
        case .governance:   return "Gobernanza"
        case .scope:        return "Alcance"
        case .schedule:     return "Cronograma"
        case .finance:      return "Finanzas"
        case .stakeholders: return "Interesados"
        case .resources:    return "Recursos"
        case .risk:         return "Riesgo"
        }
    }

    var icon: String {
        switch self {
        case .governance:   return "building.columns"
        case .scope:        return "scope"
        case .schedule:     return "calendar"
        case .finance:      return "dollarsign.circle"
        case .stakeholders: return "person.3"
        case .resources:    return "wrench.and.screwdriver"
        case .risk:         return "exclamationmark.triangle"
        }
    }
}

// MARK: - Focus Areas (columnas de la matriz)

enum FocusArea: String, CaseIterable, Codable, Identifiable, Hashable {
    case initiating             = "Initiating"
    case planning               = "Planning"
    case executing              = "Executing"
    case monitoringControlling  = "Monitoring & Controlling"
    case closing                = "Closing"

    var id: String { rawValue }

    /// Encabezado corto para columnas estrechas.
    var shortName: String {
        switch self {
        case .initiating:            return "Initiating"
        case .planning:              return "Planning"
        case .executing:             return "Executing"
        case .monitoringControlling: return "Monit. & Ctrl."
        case .closing:               return "Closing"
        }
    }

    /// Frase en español usada en pistas.
    var spanishPhase: String {
        switch self {
        case .initiating:            return "al inicio del proyecto"
        case .planning:              return "durante la planificación"
        case .executing:             return "durante la ejecución"
        case .monitoringControlling: return "mientras monitoreas y controlas"
        case .closing:               return "al cerrar el proyecto o fase"
        }
    }

    var icon: String {
        switch self {
        case .initiating:            return "flag"
        case .planning:              return "map"
        case .executing:             return "hammer"
        case .monitoringControlling: return "gauge.with.needle"
        case .closing:               return "checkmark.seal"
        }
    }
}

// MARK: - Modos de juego

enum GameMode: String, CaseIterable, Identifiable {
    case agile
    case predictive

    var id: String { rawValue }

    var title: String {
        switch self {
        case .agile:      return "Agile"
        case .predictive: return "Predictive"
        }
    }

    /// Icono sugerido: kanban para Agile, gantt/checklist para Predictive.
    var icon: String {
        switch self {
        case .agile:      return "square.grid.3x1.below.line.grid.1x2"
        case .predictive: return "chart.bar.doc.horizontal"
        }
    }

    var avatarName: String {
        switch self {
        case .agile:      return "Project Owner"
        case .predictive: return "Functional Manager"
        }
    }

    var avatarSymbol: String {
        switch self {
        case .agile:      return "person.crop.circle.badge.checkmark"
        case .predictive: return "person.crop.circle.badge.clock"
        }
    }

    /// Frases de entrega del sticky, con el lenguaje propio de cada modo.
    var deliveryPhrases: [String] {
        switch self {
        case .agile:
            return [
                "Prioriza este proceso y entrega valor.",
                "Colabora con la matriz: ¿dónde va?",
                "Itera: coloca este proceso en su celda.",
                "Nuevo ítem del backlog. ¡Entrega valor!"
            ]
        case .predictive:
            return [
                "Planifica: ubica este proceso en la matriz.",
                "Controla el plan: ¿a qué celda pertenece?",
                "Valida su ubicación en la matriz.",
                "Sigue el plan y clasifica este proceso."
            ]
        }
    }

    var successPhrases: [String] {
        switch self {
        case .agile:
            return ["¡Valor entregado!", "¡Gran iteración!", "¡Colaboración perfecta!"]
        case .predictive:
            return ["¡Según el plan!", "¡Validado!", "¡Control total!"]
        }
    }
}

// MARK: - Relevancia y dificultad

enum ModeRelevance: String, Codable {
    case agile, predictive, both
}

enum Difficulty: Int, Codable, Comparable {
    case easy = 1, medium = 2, hard = 3
    static func < (lhs: Difficulty, rhs: Difficulty) -> Bool { lhs.rawValue < rhs.rawValue }
}

// MARK: - Modelo de término/proceso

struct ProcessTerm: Identifiable, Hashable {
    let id: UUID
    let title: String
    let performanceDomain: PerformanceDomain
    let focusArea: FocusArea
    let explanation: String          // en español, enseña el "por qué"
    let modeRelevance: ModeRelevance
    let difficulty: Difficulty

    init(title: String,
         performanceDomain: PerformanceDomain,
         focusArea: FocusArea,
         explanation: String,
         modeRelevance: ModeRelevance = .both,
         difficulty: Difficulty = .medium) {
        self.id = UUID()
        self.title = title
        self.performanceDomain = performanceDomain
        self.focusArea = focusArea
        self.explanation = explanation
        self.modeRelevance = modeRelevance
        self.difficulty = difficulty
    }

    var correctCell: CellKey { CellKey(domain: performanceDomain, area: focusArea) }
}

// MARK: - Celdas de la matriz

/// Identifica una celda por dominio + focus area.
struct CellKey: Hashable {
    let domain: PerformanceDomain
    let area: FocusArea
}

struct MatrixCell: Identifiable {
    let performanceDomain: PerformanceDomain
    let focusArea: FocusArea
    let acceptedTerms: [String]      // títulos de procesos que pertenecen aquí
    var placedTerms: [ProcessTerm] = []

    var id: String { "\(performanceDomain.rawValue)-\(focusArea.rawValue)" }
    var key: CellKey { CellKey(domain: performanceDomain, area: focusArea) }
    var isPlayable: Bool { !acceptedTerms.isEmpty }
}

// MARK: - Medallas

enum Medal: String, CaseIterable, Identifiable {
    case planner    = "Planner"
    case closer     = "Closer"
    case riskMaster = "Risk Master"
    case focusMode  = "Focus Mode"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .planner:    return "map.fill"
        case .closer:     return "checkmark.seal.fill"
        case .riskMaster: return "shield.checkered"
        case .focusMode:  return "scope"
        }
    }

    var spanishDescription: String {
        switch self {
        case .planner:    return "5 aciertos en Planning"
        case .closer:     return "3 aciertos en Closing"
        case .riskMaster: return "Riesgo dominado sin fallos"
        case .focusMode:  return "Ronda completa en modo enfoque"
        }
    }
}

// MARK: - Fases y pantallas

enum Screen: Equatable {
    case onboarding, game, results
}

/// Fases dentro de una ronda de juego.
enum GamePhase: Equatable {
    case delivering        // el avatar entrega el sticky (animación de traspaso)
    case holding           // POV: el usuario sostiene el sticky y puede arrastrarlo
    case celebrating       // acierto: confetti + mensaje educativo
    case levelUp           // banner de nuevo nivel
}

struct FeedbackMessage: Equatable {
    let text: String
    let isSuccess: Bool
}
