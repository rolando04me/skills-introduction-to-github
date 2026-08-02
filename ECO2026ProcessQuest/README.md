# ECO 2026 Process Quest 🎮

Juego educativo nativo para iPhone (SwiftUI) para estudiar los procesos del
**ECO 2026** y su relación con **PMBOK 8**, colocando sticky notes en la celda
correcta de la matriz *Performance Domains × Focus Areas*.

> Juego educativo independiente ("ECO 2026 Practice Game"). Sin afiliación con
> PMI y sin uso de logos oficiales.

## Características

- **Matriz interactiva 7×5**: filas = Performance Domains (Governance, Scope,
  Schedule, Finance, Stakeholders, Resources, Risk); columnas = Focus Areas
  (Initiating, Planning, Executing, Monitoring & Controlling, Closing).
  Scrollable en ambas direcciones, cada celda acepta drops y las vacías siguen
  visibles.
- **Drag & drop real** con `DragGesture` + hit-testing por `PreferenceKey`,
  más colocación por toque como alternativa accesible (VoiceOver).
- **Primera persona (POV)**: el avatar entrega el sticky con
  `matchedGeometryEffect` y unas manos minimalistas lo sostienen antes de
  arrastrarlo.
- **Modos Agile / Predictive**: cambian avatar (Project Owner / Functional
  Manager), lenguaje de las frases y color secundario (aqua / azul suave).
- **ADHD Friendly**: menos animaciones, texto más grande, un solo sticky,
  mayor contraste, frases cortas, barra de progreso prominente, solo los
  dominios del nivel visibles y sonido de concentración opcional.
- **Gamificación**: puntos, bonus por racha, 4 niveles progresivos, 4 medallas
  (Planner, Closer, Risk Master, Focus Mode) y progreso por dominio.
- **Pistas progresivas**: dominio → focus area → explicación educativa.
- **40 procesos con explicación en español**, mock data incluida: funciona
  100 % offline, sin backend.

## Cómo crear el proyecto en Xcode

1. Xcode → **File ▸ New ▸ Project ▸ iOS ▸ App**.
2. Product Name: `ECO2026ProcessQuest` · Interface: **SwiftUI** · Language:
   **Swift** · Minimum deployment: **iOS 17.0**.
3. Borra el `ContentView.swift` y el `App` generados.
4. Arrastra la carpeta `Sources/` de este repo al proyecto (marca
   *Copy items if needed* y el target de la app).
5. Compila y ejecuta en un iPhone o simulador en orientación vertical.

## Archivos de audio (opcionales)

La app usa AVFoundation y busca estos archivos en el bundle:

| Archivo | Uso |
| --- | --- |
| `focus_loop.mp3` | Loop ambient suave de concentración (modo ADHD) |
| `success_chime.mp3` | Celebración corta al acertar |
| `soft_error.mp3` | Feedback suave (no agresivo) al fallar |

**Para agregarlos:** arrastra los tres `.mp3` a la raíz del proyecto en Xcode,
marca *Copy items if needed* y verifica que aparezcan en
*Target ▸ Build Phases ▸ Copy Bundle Resources*.

**Si no los agregas, la app funciona igual**: `AudioManager` sintetiza tonos
suaves equivalentes con `AVAudioEngine` (campanita de dos notas, tono grave
amable y pad de concentración en loop). La categoría de audio es `.ambient`,
así que respeta el interruptor de silencio y se mezcla con otras apps.

## Estructura del código

```
Sources/
├── App/ECO2026ProcessQuestApp.swift   # Entry point + enrutado de pantallas
├── Support/Theme.swift                # Paleta ECO 2026 (fondo claro, púrpuras)
├── Models/Models.swift                # ProcessTerm, MatrixCell, enums, medallas
├── Data/ProcessData.swift             # Los 40 procesos + matriz + niveles
├── Engine/GameEngine.swift            # Estado del juego (@Observable, @MainActor)
├── Audio/AudioManager.swift           # AVFoundation + síntesis de respaldo
└── Views/
    ├── OnboardingView.swift           # Título, selector Agile/Predictive, ADHD
    ├── GameView.swift                 # Header, drag & drop, POV, confetti
    ├── ProcessMatrixView.swift        # Tabla interactiva con PreferenceKey
    ├── ResultsView.swift              # Score, %, medallas, dominados/repasar
    └── Components.swift               # Sticky, manos POV, avatar, toggles, confetti
```

## Reglas del juego

- **Niveles**: 1 = Governance/Scope/Schedule · 2 = +Finance/Stakeholders ·
  3 = +Resources/Risk · 4 = todos mezclados. 6 stickies por nivel.
- **Puntos**: 10 por acierto + bonus de racha (hasta +10) − 3 por pista usada.
- **Modo práctica**: los 40 procesos, sin presión de niveles.
