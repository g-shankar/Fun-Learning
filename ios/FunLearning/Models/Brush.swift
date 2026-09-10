import SwiftUI

// MARK: - Brushes kids can pick (and switch mid-trace)

enum Brush: String, CaseIterable, Identifiable {
    case coral, blue, green, purple, rainbow, glitter

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .coral: "Coral"
        case .blue: "Blue"
        case .green: "Green"
        case .purple: "Purple"
        case .rainbow: "Rainbow"
        case .glitter: "Glitter"
        }
    }

    /// Base ink color (rainbow/glitter resolve per-segment at draw time).
    var color: Color {
        switch self {
        case .coral: Color(red: 1.0, green: 0.48, blue: 0.35)
        case .blue: Color(red: 0.30, green: 0.62, blue: 1.0)
        case .green: Color(red: 0.35, green: 0.78, blue: 0.45)
        case .purple: Color(red: 0.66, green: 0.45, blue: 0.95)
        case .rainbow: Color(red: 1.0, green: 0.55, blue: 0.35)
        case .glitter: Color(red: 0.85, green: 0.45, blue: 0.95)
        }
    }

    var dark: Color {
        switch self {
        case .coral: Color(red: 0.78, green: 0.30, blue: 0.20)
        case .blue: Color(red: 0.16, green: 0.42, blue: 0.78)
        case .green: Color(red: 0.20, green: 0.58, blue: 0.30)
        case .purple: Color(red: 0.48, green: 0.28, blue: 0.75)
        case .rainbow: Color(red: 0.75, green: 0.30, blue: 0.55)
        case .glitter: Color(red: 0.62, green: 0.25, blue: 0.78)
        }
    }

    var swatch: Color { color }
    var isSpecial: Bool { self == .rainbow || self == .glitter }
}
