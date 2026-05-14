import SwiftUI

struct TaperedGlassShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let widthTop = rect.width
        let widthBottom = rect.width * 0.82
        let offsetX = (widthTop - widthBottom) / 2
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: widthTop, y: 0))
        path.addLine(to: CGPoint(x: widthTop - offsetX, y: rect.height))
        path.addLine(to: CGPoint(x: offsetX, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct WaterGlassView: View {
    var progress: Double
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Glass Body
            TaperedGlassShape()
                .fill(.ultraThinMaterial)
                .frame(width: 150, height: 250)
                .overlay(
                    TaperedGlassShape()
                        .stroke(LinearGradient(colors: [.white.opacity(0.6), .clear, .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 5, y: 5)
            
            // Water
            TaperedGlassShape()
                .fill(LinearGradient(colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                .frame(width: 140, height: 240 * min(progress, 1.0))
                .padding(.bottom, 6)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            
            // Highlight
            Capsule()
                .fill(.white.opacity(0.15))
                .frame(width: 6, height: 160)
                .offset(x: -55, y: -45)
                .blur(radius: 1)

            // Base
            RoundedRectangle(cornerRadius: 4)
                .fill(.white.opacity(0.4))
                .frame(width: 120, height: 12)
                .offset(y: 10)
        }
    }
}
