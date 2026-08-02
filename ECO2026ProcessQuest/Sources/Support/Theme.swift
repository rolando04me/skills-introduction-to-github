import SwiftUI

/// Paleta ECO 2026: fondo claro lavanda, acentos púrpura, azul suave y aqua.
enum Theme {
    // MARK: Fondos claros (nunca oscuros)
    static let paleLavender = Color(red: 0.958, green: 0.945, blue: 0.988)
    static let warmWhite    = Color(red: 0.992, green: 0.988, blue: 1.0)
    static let softBlueTint = Color(red: 0.913, green: 0.937, blue: 0.988)

    // MARK: Púrpuras de marca
    static let purple       = Color(red: 0.478, green: 0.325, blue: 0.788)   // principal
    static let brightPurple = Color(red: 0.545, green: 0.361, blue: 0.965)   // acierto / brillo
    static let deepPurple   = Color(red: 0.302, green: 0.204, blue: 0.541)   // texto sobre claro
    static let lavender     = Color(red: 0.804, green: 0.749, blue: 0.929)

    // MARK: Secundarios por modo
    static let softAqua = Color(red: 0.490, green: 0.827, blue: 0.784)       // Agile
    static let softBlue = Color(red: 0.576, green: 0.722, blue: 0.910)       // Predictive

    // MARK: Feedback
    static let softCoral = Color(red: 0.941, green: 0.565, blue: 0.553)      // error suave
    static let mint      = Color(red: 0.812, green: 0.961, blue: 0.906)

    // MARK: Sticky notes
    static let stickyYellow   = Color(red: 1.0, green: 0.953, blue: 0.690)
    static let stickyLavender = Color(red: 0.902, green: 0.863, blue: 0.980)
    static let stickyMint     = Color(red: 0.812, green: 0.961, blue: 0.906)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [warmWhite, paleLavender, softBlueTint],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Color de sticky según índice; en modo ADHD se usa siempre alto contraste.
    static func stickyColor(index: Int, adhd: Bool) -> Color {
        if adhd { return stickyYellow }   // un solo color, máximo contraste con la tabla
        let palette = [stickyYellow, stickyLavender, stickyMint]
        return palette[index % palette.count]
    }
}

extension GameMode {
    /// Acento secundario por modo (violeta + aqua para Agile, violeta + azul para Predictive).
    var accent: Color {
        switch self {
        case .agile: Theme.softAqua
        case .predictive: Theme.softBlue
        }
    }
}
