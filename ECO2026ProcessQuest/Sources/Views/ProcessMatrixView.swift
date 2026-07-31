import SwiftUI

/// Publica el frame de cada celda (en el coordinate space del juego)
/// para que GameView pueda hacer hit-testing del drag & drop.
struct CellFramePreferenceKey: PreferenceKey {
    static var defaultValue: [CellKey: CGRect] = [:]
    static func reduce(value: inout [CellKey: CGRect], nextValue: () -> [CellKey: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

/// Tabla interactiva: columnas = Focus Areas, filas = Performance Domains.
/// Cada celda acepta drops; las vacías siguen siendo visibles.
struct ProcessMatrixView: View {
    @Environment(GameEngine.self) private var engine
    let hoveredCell: CellKey?
    let coordinateSpaceName: String
    let onCellTap: (CellKey) -> Void   // alternativa accesible al drag

    private let domainColumnWidth: CGFloat = 90
    private let cellWidth: CGFloat = 116
    private let cellHeight: CGFloat = 88
    private let headerHeight: CGFloat = 44
    private let gridSpacing: CGFloat = 4

    /// En modo ADHD solo se muestran los dominios del nivel (menos estímulos).
    private var visibleDomains: [PerformanceDomain] {
        engine.adhdMode ? engine.domainsInPlay : PerformanceDomain.allCases.map { $0 }
    }

    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            VStack(spacing: gridSpacing) {
                headerRow
                ForEach(Array(visibleDomains.enumerated()), id: \.element) { index, domain in
                    domainRow(domain, rowIndex: index)
                }
            }
            .padding(10)
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.55))
        )
        .accessibilityLabel("Matriz de procesos ECO 2026")
    }

    // MARK: Encabezado (Focus Areas)

    private var headerRow: some View {
        HStack(spacing: gridSpacing) {
            Text("Dominio")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: domainColumnWidth, height: headerHeight)
                .background(RoundedRectangle(cornerRadius: 8).fill(Theme.deepPurple))

            ForEach(FocusArea.allCases) { area in
                VStack(spacing: 2) {
                    Image(systemName: area.icon)
                        .font(.caption)
                    Text(area.shortName)
                        .font(.caption2.weight(.bold))
                        .minimumScaleFactor(0.7)
                }
                .foregroundStyle(.white)
                .frame(width: cellWidth, height: headerHeight)
                .background(RoundedRectangle(cornerRadius: 8).fill(Theme.purple))
                .accessibilityLabel("Columna \(area.rawValue)")
            }
        }
    }

    // MARK: Filas por dominio

    private func domainRow(_ domain: PerformanceDomain, rowIndex: Int) -> some View {
        let inPlay = engine.domainsInPlay.contains(domain)
        return HStack(spacing: gridSpacing) {
            VStack(spacing: 3) {
                Image(systemName: domain.icon)
                    .font(.caption)
                Text(domain.rawValue)
                    .font(.caption2.weight(.semibold))
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(Theme.deepPurple)
            .frame(width: domainColumnWidth, height: cellHeight)
            .background(RoundedRectangle(cornerRadius: 8).fill(Theme.lavender.opacity(0.55)))
            .accessibilityLabel("Fila \(domain.rawValue)")

            ForEach(FocusArea.allCases) { area in
                cellView(key: CellKey(domain: domain, area: area),
                         rowIndex: rowIndex,
                         inPlay: inPlay)
            }
        }
        .opacity(inPlay ? 1 : 0.35)   // dominios de niveles futuros, atenuados
    }

    // MARK: Celda

    private func cellView(key: CellKey, rowIndex: Int, inPlay: Bool) -> some View {
        let placed = engine.placements[key] ?? []
        let isHovered = hoveredCell == key
        let isLastDrop = engine.lastDropCell == key

        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(rowIndex.isMultiple(of: 2) ? Theme.paleLavender : Color.white)

            if placed.isEmpty {
                // Las celdas vacías siguen visibles con un punto sutil.
                Circle()
                    .fill(Theme.lavender.opacity(0.35))
                    .frame(width: 6, height: 6)
            } else {
                VStack(spacing: 3) {
                    ForEach(placed.suffix(2)) { term in
                        Text(term.title)
                            .font(.system(size: 9, weight: .semibold))
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Theme.deepPurple)
                            .padding(3)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Theme.stickyYellow)
                                    .shadow(color: .black.opacity(0.08), radius: 1, y: 1)
                            )
                    }
                    if placed.count > 2 {
                        Text("+\(placed.count - 2) más")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(Theme.purple)
                    }
                }
                .padding(4)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(borderColor(isHovered: isHovered, isLastDrop: isLastDrop),
                              lineWidth: isHovered || isLastDrop ? 3 : 1)
        )
        // Brillo púrpura cuando el drop fue correcto.
        .shadow(color: isLastDrop && engine.lastDropCorrect
                    ? Theme.brightPurple.opacity(0.6) : .clear,
                radius: 8)
        .frame(width: cellWidth, height: cellHeight)
        .scaleEffect(isHovered ? 1.05 : 1)
        .animation(.easeOut(duration: 0.15), value: isHovered)
        .background(
            // Reporta el frame de la celda para el hit-testing del drag.
            GeometryReader { geo in
                Color.clear.preference(
                    key: CellFramePreferenceKey.self,
                    value: [key: geo.frame(in: .named(coordinateSpaceName))]
                )
            }
        )
        .contentShape(Rectangle())
        .onTapGesture { onCellTap(key) }   // colocar por toque (VoiceOver / motricidad)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Celda \(key.domain.rawValue), \(key.area.rawValue). \(placed.count) procesos colocados.")
        .accessibilityHint("Toca dos veces para colocar aquí el sticky actual.")
        .accessibilityAddTraits(.isButton)
    }

    private func borderColor(isHovered: Bool, isLastDrop: Bool) -> Color {
        if isLastDrop {
            return engine.lastDropCorrect ? Theme.brightPurple : Theme.softCoral
        }
        if isHovered { return Theme.purple }
        return Theme.lavender.opacity(0.4)
    }
}
