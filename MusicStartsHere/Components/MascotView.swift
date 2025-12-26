//
//  MascotView.swift
//  MusicStartsHere
//
//  Created by Di on 12/15/25.
//

import SwiftUI

struct MascotView: View {
    let type: String // "violin" or "piano"
    var animate: Bool = true
    
    var body: some View {
        ZStack {
            // Simple bear with instrument using SF Symbols
            VStack(spacing: -20) {
                // Bear face
                ZStack {
                    Circle()
                        .fill(Color.brown.opacity(0.7))
                        .frame(width: 100, height: 100)
                    
                    HStack(spacing: 30) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 12, height: 12)
                        Circle()
                            .fill(Color.black)
                            .frame(width: 12, height: 12)
                    }
                    .offset(y: -10)
                    
                    // Nose
                    Circle()
                        .fill(Color.black)
                        .frame(width: 8, height: 8)
                        .offset(y: 10)
                    
                    // Ears
                    HStack(spacing: 80) {
                        Circle()
                            .fill(Color.brown.opacity(0.7))
                            .frame(width: 30, height: 30)
                        Circle()
                            .fill(Color.brown.opacity(0.7))
                            .frame(width: 30, height: 30)
                    }
                    .offset(y: -50)
                }
                
                // Body with instrument
                ZStack {
                    Capsule()
                        .fill(Color.brown.opacity(0.6))
                        .frame(width: 80, height: 120)
                    
                    Image(systemName: type == "violin" ? "music.note" : "pianokeys")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
            
            // Floating music notes
            if animate {
                FloatingNotesView()
            }
        }
        .scaleEffect(animate ? 1.0 : 0.9)
        .animation(animate ? .easeInOut(duration: 2).repeatForever(autoreverses: true) : .default, value: animate)
    }
}

struct FloatingNotesView: View {
    @State private var offset1: CGFloat = 0
    @State private var offset2: CGFloat = 0
    @State private var offset3: CGFloat = 0
    
    var body: some View {
        ZStack {
            Text("♪")
                .font(.system(size: 30))
                .foregroundColor(.red.opacity(0.6))
                .offset(x: 60, y: offset1)
                .onAppear {
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                        offset1 = -100
                    }
                }
            
            Text("♫")
                .font(.system(size: 25))
                .foregroundColor(.blue.opacity(0.6))
                .offset(x: -50, y: offset2)
                .onAppear {
                    withAnimation(.linear(duration: 4).delay(1).repeatForever(autoreverses: false)) {
                        offset2 = -100
                    }
                }
            
            Text("♩")
                .font(.system(size: 20))
                .foregroundColor(.brown.opacity(0.6))
                .offset(x: 40, y: offset3)
                .onAppear {
                    withAnimation(.linear(duration: 3.5).delay(2).repeatForever(autoreverses: false)) {
                        offset3 = -100
                    }
                }
        }
    }
}
