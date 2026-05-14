//
//  WaterGlassView.swift
//  HydroHabit
//
//  Created by Sandeep Chituprolu on 14/05/26.
//

import SwiftUI

struct WaterGlassView: View {
    var progress: Double
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. The Back of the Glass (Frosted Look)
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .frame(width: 160, height: 260)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 5, y: 5)
            
            // 2. The Water Level
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.cyan.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 154, height: 254 * min(progress, 1.0))
                .mask(RoundedRectangle(cornerRadius: 25)) // Keeps water inside glass shape
                .overlay(
                    // Subtle "Wave" highlight at the top of the water
                    VStack {
                        Rectangle()
                            .fill(.white.opacity(0.3))
                            .frame(height: 2)
                        Spacer()
                    }
                )
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progress)
            
            // 3. The Front Reflection (Makes it look like glass)
            RoundedRectangle(cornerRadius: 30)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .clear, .white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 160, height: 260)
            
            // 4. Glossy Highlight
            Capsule()
                .fill(.white.opacity(0.1))
                .frame(width: 8, height: 180)
                .offset(x: -60, y: 0)
                .blur(radius: 2)
        }
    }
}
