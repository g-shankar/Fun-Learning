import SwiftUI

// MARK: - Brush picker: colors, rainbow, glitter — switchable mid-trace

struct BrushPicker: View {
    @Binding var brush: Brush

    var body: some View {
        HStack(spacing: 14) {
            ForEach(Brush.allCases) { b in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        brush = b
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(b.isSpecial
                                  ? AnyShapeStyle(LinearGradient(
                                        colors: [.red, .orange, .yellow, .green, .blue, .purple],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                                  : AnyShapeStyle(b.swatch))
                            .frame(width: 44, height: 44)
                            .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
                        if b == .glitter {
                            Text("✨").font(.system(size: 20))
                        }
                        if brush == b {
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 52, height: 52)
                                .shadow(color: b.swatch.opacity(0.8), radius: 6)
                        }
                    }
                }
                .buttonStyle(.plain)
                .scaleEffect(brush == b ? 1.12 : 1.0)
                .accessibilityLabel("\(b.displayName) brush")
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}
