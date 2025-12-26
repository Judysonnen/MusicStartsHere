//
//  ContentView.swift
//  MusicStartsHere
//
//  Created by Di on 12/15/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedClef: ClefType?
    @State private var progress: UserProgress = [:]
    
    var body: some View {
        ZStack {
            if let clef = selectedClef {
                GridView(
                    clef: clef,
                    progress: $progress,
                    selectedClef: $selectedClef
                )
                .transition(.opacity.combined(with: .move(edge: .trailing)))
                .zIndex(1)
            } else {
                HomeView(selectedClef: $selectedClef)
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                    .zIndex(0)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0), value: selectedClef)
        .onAppear {
            progress = StorageService.getProgress()
        }
    }
}

#Preview {
    ContentView()
}
