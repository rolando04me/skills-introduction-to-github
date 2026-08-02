import Foundation

/// Datos mock completos de la matriz ECO 2026 (funciona 100% offline).
/// Los nombres oficiales de procesos se mantienen en inglés;
/// las explicaciones educativas están en español.
enum ProcessData {

    static let allTerms: [ProcessTerm] = [

        // MARK: Governance
        ProcessTerm(title: "Initiate Project or Phase",
                    performanceDomain: .governance, focusArea: .initiating,
                    explanation: "Autoriza formalmente el proyecto o fase y define su propósito desde el inicio.",
                    difficulty: .easy),
        ProcessTerm(title: "Integrate and Align Project Plans",
                    performanceDomain: .governance, focusArea: .planning,
                    explanation: "Integra todos los planes subsidiarios en un plan coherente; es trabajo de planificación."),
        ProcessTerm(title: "Plan Sourcing Strategy",
                    performanceDomain: .governance, focusArea: .planning,
                    explanation: "Define cómo se adquirirán bienes y servicios; la estrategia se decide al planificar.",
                    difficulty: .hard),
        ProcessTerm(title: "Manage Project Execution",
                    performanceDomain: .governance, focusArea: .executing,
                    explanation: "Dirige y coordina el trabajo del proyecto mientras se ejecuta.",
                    difficulty: .easy),
        ProcessTerm(title: "Manage Quality Assurance",
                    performanceDomain: .governance, focusArea: .executing,
                    explanation: "Asegura que los procesos de calidad se apliquen durante la ejecución del trabajo."),
        ProcessTerm(title: "Manage Project Knowledge",
                    performanceDomain: .governance, focusArea: .executing,
                    explanation: "Captura y comparte conocimiento mientras el equipo realiza el trabajo.",
                    difficulty: .hard),
        ProcessTerm(title: "Monitor and Control Project Performance",
                    performanceDomain: .governance, focusArea: .monitoringControlling,
                    explanation: "Compara el desempeño real contra el plan durante todo el proyecto."),
        ProcessTerm(title: "Assess and Implement Changes",
                    performanceDomain: .governance, focusArea: .monitoringControlling,
                    explanation: "Evalúa y gestiona los cambios para mantener el proyecto bajo control.",
                    difficulty: .hard),
        ProcessTerm(title: "Close Project or Phase",
                    performanceDomain: .governance, focusArea: .closing,
                    explanation: "Se ubica en Closing porque formaliza el cierre del proyecto o fase.",
                    difficulty: .easy),

        // MARK: Scope
        ProcessTerm(title: "Plan Scope Management",
                    performanceDomain: .scope, focusArea: .planning,
                    explanation: "Define cómo se gestionará el alcance; es una decisión de planificación.",
                    difficulty: .easy),
        ProcessTerm(title: "Elicit and Analyze Requirements",
                    performanceDomain: .scope, focusArea: .planning,
                    explanation: "Recoge y analiza requisitos para planificar qué se va a entregar."),
        ProcessTerm(title: "Define Scope",
                    performanceDomain: .scope, focusArea: .planning,
                    explanation: "Establece los límites de lo que incluye (y no incluye) el proyecto al planificar.",
                    difficulty: .easy),
        ProcessTerm(title: "Develop Scope Structure",
                    performanceDomain: .scope, focusArea: .planning,
                    explanation: "Descompone el alcance en componentes manejables durante la planificación."),
        ProcessTerm(title: "Monitor and Control Scope",
                    performanceDomain: .scope, focusArea: .monitoringControlling,
                    explanation: "Vigila desviaciones del alcance y previene el scope creep durante el control."),
        ProcessTerm(title: "Validate Scope",
                    performanceDomain: .scope, focusArea: .monitoringControlling,
                    explanation: "Obtiene la aceptación formal de los entregables; es una actividad de control.",
                    difficulty: .hard),

        // MARK: Schedule
        ProcessTerm(title: "Plan Schedule Management",
                    performanceDomain: .schedule, focusArea: .planning,
                    explanation: "Define las reglas para crear y gestionar el cronograma al planificar.",
                    difficulty: .easy),
        ProcessTerm(title: "Develop Schedule",
                    performanceDomain: .schedule, focusArea: .planning,
                    explanation: "Se ubica en Planning porque define la secuencia y duración del trabajo.",
                    difficulty: .easy),
        ProcessTerm(title: "Monitor and Control Schedule",
                    performanceDomain: .schedule, focusArea: .monitoringControlling,
                    explanation: "Compara avance real contra el cronograma y gestiona desviaciones."),

        // MARK: Finance
        ProcessTerm(title: "Plan Financial Management",
                    performanceDomain: .finance, focusArea: .planning,
                    explanation: "Define cómo se gestionará el dinero del proyecto; se decide al planificar.",
                    difficulty: .easy),
        ProcessTerm(title: "Estimate Costs",
                    performanceDomain: .finance, focusArea: .planning,
                    explanation: "Calcula cuánto costará el trabajo antes de ejecutarlo: planificación pura."),
        ProcessTerm(title: "Develop Budget",
                    performanceDomain: .finance, focusArea: .planning,
                    explanation: "Consolida los costos estimados en un presupuesto autorizado durante la planificación."),
        ProcessTerm(title: "Monitor and Control Finances",
                    performanceDomain: .finance, focusArea: .monitoringControlling,
                    explanation: "Vigila el gasto real contra el presupuesto durante el proyecto."),

        // MARK: Stakeholders
        ProcessTerm(title: "Identify Stakeholders",
                    performanceDomain: .stakeholders, focusArea: .initiating,
                    explanation: "Se ubica en Initiating porque primero necesitas reconocer a las personas impactadas por el proyecto.",
                    difficulty: .easy),
        ProcessTerm(title: "Plan Stakeholder Engagement",
                    performanceDomain: .stakeholders, focusArea: .planning,
                    explanation: "Diseña la estrategia para involucrar a los interesados; se define al planificar."),
        ProcessTerm(title: "Plan Communications Management",
                    performanceDomain: .stakeholders, focusArea: .planning,
                    explanation: "Decide qué, cuándo y cómo comunicar; es un plan, no una ejecución."),
        ProcessTerm(title: "Manage Stakeholder Engagement",
                    performanceDomain: .stakeholders, focusArea: .executing,
                    explanation: "Interactúa activamente con los interesados mientras el proyecto se ejecuta."),
        ProcessTerm(title: "Manage Communications",
                    performanceDomain: .stakeholders, focusArea: .executing,
                    explanation: "Distribuye la información según el plan; ocurre durante la ejecución."),
        ProcessTerm(title: "Monitor Stakeholder Engagement",
                    performanceDomain: .stakeholders, focusArea: .monitoringControlling,
                    explanation: "Revisa si la estrategia de involucramiento funciona y la ajusta.",
                    difficulty: .hard),
        ProcessTerm(title: "Monitor Communications",
                    performanceDomain: .stakeholders, focusArea: .monitoringControlling,
                    explanation: "Verifica que la información llegue a quien debe llegar, durante el control.",
                    difficulty: .hard),

        // MARK: Resources
        ProcessTerm(title: "Plan Resource Management",
                    performanceDomain: .resources, focusArea: .planning,
                    explanation: "Define cómo obtener y gestionar personas y materiales; se decide al planificar.",
                    difficulty: .easy),
        ProcessTerm(title: "Estimate Resources",
                    performanceDomain: .resources, focusArea: .planning,
                    explanation: "Calcula qué recursos necesitará el trabajo antes de ejecutarlo."),
        ProcessTerm(title: "Acquire Resources",
                    performanceDomain: .resources, focusArea: .executing,
                    explanation: "Obtiene al equipo y los materiales cuando el trabajo ya está en marcha."),
        ProcessTerm(title: "Lead the Team",
                    performanceDomain: .resources, focusArea: .executing,
                    explanation: "Lidera, motiva y desarrolla al equipo mientras ejecuta el trabajo.",
                    difficulty: .easy),
        ProcessTerm(title: "Monitor and Control Resourcing",
                    performanceDomain: .resources, focusArea: .monitoringControlling,
                    explanation: "Vigila la disponibilidad y el desempeño de los recursos durante el proyecto.",
                    difficulty: .hard),

        // MARK: Risk
        ProcessTerm(title: "Plan Risk Management",
                    performanceDomain: .risk, focusArea: .planning,
                    explanation: "Define cómo se abordará el riesgo en el proyecto; es planificación.",
                    difficulty: .easy),
        ProcessTerm(title: "Identify Risks",
                    performanceDomain: .risk, focusArea: .planning,
                    explanation: "Descubre amenazas y oportunidades como parte de la planificación."),
        ProcessTerm(title: "Perform Risk Analysis",
                    performanceDomain: .risk, focusArea: .planning,
                    explanation: "Prioriza los riesgos por probabilidad e impacto al planificar la respuesta."),
        ProcessTerm(title: "Plan Risk Responses",
                    performanceDomain: .risk, focusArea: .planning,
                    explanation: "Diseña las acciones para cada riesgo antes de que ocurran."),
        ProcessTerm(title: "Implement Risk Responses",
                    performanceDomain: .risk, focusArea: .executing,
                    explanation: "Ejecuta las respuestas planificadas cuando el trabajo está en marcha.",
                    difficulty: .hard),
        ProcessTerm(title: "Monitor Risks",
                    performanceDomain: .risk, focusArea: .monitoringControlling,
                    explanation: "Se ubica en Monitoring and Controlling porque revisa amenazas y oportunidades durante el proyecto.")
    ]

    /// Construye la matriz completa (7 dominios x 5 focus areas), incluidas celdas vacías.
    static func buildMatrix() -> [MatrixCell] {
        PerformanceDomain.allCases.flatMap { domain in
            FocusArea.allCases.map { area in
                MatrixCell(
                    performanceDomain: domain,
                    focusArea: area,
                    acceptedTerms: allTerms
                        .filter { $0.performanceDomain == domain && $0.focusArea == area }
                        .map(\.title)
                )
            }
        }
    }

    /// Dominios habilitados por nivel de juego.
    static func domains(forLevel level: Int) -> [PerformanceDomain] {
        switch level {
        case 1:  return [.governance, .scope, .schedule]
        case 2:  return [.governance, .scope, .schedule, .finance, .stakeholders]
        case 3:  return [.governance, .scope, .schedule, .finance, .stakeholders, .resources, .risk]
        default: return PerformanceDomain.allCases.map { $0 }   // Nivel 4: todo mezclado
        }
    }

    static func terms(forLevel level: Int) -> [ProcessTerm] {
        let domains = Set(domains(forLevel: level))
        return allTerms.filter { domains.contains($0.performanceDomain) }
    }
}
