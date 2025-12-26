//
//  HomeView.swift
//  MusicStartsHere
//
//  Created by Di on 12/15/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedClef: ClefType?

    private let orange = Constants.TREBLE_THEME_COLOR
    private let teal = Constants.BASS_THEME_COLOR

    var body: some View {
        ZStack {
            // Pure white background to ensure true colors
            Color.white
                .ignoresSafeArea()

            GeometryReader { proxy in
                let size = proxy.size

                ZStack {
                    HomeBackgroundCard(orange: orange, teal: teal)
                        .overlay(
                            GeometryReader { geo in
                                let midY = geo.size.height * 0.5
                                let spacing = geo.size.height * 0.25  // Distance from divider
                                
                                ZStack {
                                    // Treble clef - above divider
                                    Text("𝄞")
                                        .font(.system(size: size.height * 0.18))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.15), radius: 6)
                                        .position(x: geo.size.width / 2, y: midY - spacing)
                                    
                                    // Bass clef - below divider
                                    Text("𝄢")
                                        .font(.system(size: size.height * 0.14))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.15), radius: 6)
                                        .position(x: geo.size.width / 2, y: midY + spacing)
                                }
                            }
                        )
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { value in
                                    let localY = value.location.y
                                    if localY < size.height / 2 {
                                        selectedClef = .treble
                                    } else {
                                        selectedClef = .bass
                                    }
                                }
                        )
                }
                .frame(width: size.width, height: size.height)
            }
        }
    }
}

// MARK: - Background Card

fileprivate struct HomeBackgroundCard: View {
    let orange: Color
    let teal: Color
    
    @State private var animationPhase: Double = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Bottom color (teal) - full background
                teal
                    .ignoresSafeArea()
                
                // Top color (orange) - gentle breathing divider
                orange
                    .mask(
                        DiagonalDivider(phase: animationPhase)
                            .fill(style: FillStyle(eoFill: false))
                    )
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 6)
                .repeatForever(autoreverses: true)
            ) {
                animationPhase = 1.0
            }
        }
    }
}

// MARK: - Breathing Divider Shape

fileprivate struct DiagonalDivider: Shape {
    var phase: Double
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let midY = height * 0.5
        
        // Subtle wave with multiple dynamics
        let baseAmplitude: CGFloat = 12
        
        // Dynamic 1: Amplitude breathing (subtle size change)
        let amplitudeVariation = sin(phase * .pi * 2) * 2
        let amplitude = baseAmplitude + amplitudeVariation
        
        // Dynamic 2: Vertical breathing (up/down movement)
        let breathOffset = sin(phase * .pi * 2) * 4
        
        // Dynamic 3: Horizontal flow (wave shifts horizontally)
        let flowPhase = phase * .pi * 0.5  // Slower horizontal flow
        
        let wavelength = width / 1.5
        let frequency = 2.0 * .pi / wavelength
        
        // Start from top-left corner
        path.move(to: CGPoint(x: 0, y: 0))
        
        // Top edge
        path.addLine(to: CGPoint(x: width, y: 0))
        
        // Right edge to wave start
        let startY = midY + sin(flowPhase) * amplitude + breathOffset
        path.addLine(to: CGPoint(x: width, y: startY))
        
        // Gentle flowing wave (right to left)
        let steps = 80
        for i in stride(from: steps, through: 0, by: -1) {
            let x = width * CGFloat(i) / CGFloat(steps)
            let waveY = midY + sin(x * frequency + flowPhase) * amplitude + breathOffset
            path.addLine(to: CGPoint(x: x, y: waveY))
        }
        
        // Close path back to start
        path.closeSubpath()
        
        return path
    }
}
