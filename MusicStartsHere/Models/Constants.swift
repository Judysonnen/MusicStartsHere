import Foundation
import SwiftUI

struct Constants {
    
    // Theme Colors
    static let TREBLE_THEME_COLOR = Color(hex: 0xFF8811)  // Orange for treble clef
    static let BASS_THEME_COLOR = Color(hex: 0x9DD9D2)    // Teal for bass clef

    // StaffNoteView assumption:
    // step = 0 is the middle line of the staff.
    // Treble middle line: B4
    // Range: D3 to G6
    static let TREBLE_NOTES: [NoteData] = [
        NoteData(id: "treble-D3", name: "D", solfege: "re", step: -12, frequency: 146.83, clef: .treble, description: "D3"),
        NoteData(id: "treble-E3", name: "E", solfege: "mi", step: -11, frequency: 164.81, clef: .treble, description: "E3"),
        NoteData(id: "treble-F3", name: "F", solfege: "fa", step: -10, frequency: 174.61, clef: .treble, description: "F3"),
        NoteData(id: "treble-G3", name: "G", solfege: "sol", step: -9, frequency: 196.00, clef: .treble, description: "G3"),
        NoteData(id: "treble-A3", name: "A", solfege: "la", step: -8, frequency: 220.00, clef: .treble, description: "A3"),
        NoteData(id: "treble-B3", name: "B", solfege: "si", step: -7, frequency: 246.94, clef: .treble, description: "B3"),
        NoteData(id: "treble-C4", name: "C", solfege: "do", step: -6, frequency: 261.63, clef: .treble, description: "C4 (Middle C)"),
        NoteData(id: "treble-D4", name: "D", solfege: "re", step: -5, frequency: 293.66, clef: .treble, description: "D4"),
        NoteData(id: "treble-E4", name: "E", solfege: "mi", step: -4, frequency: 329.63, clef: .treble, description: "E4"),
        NoteData(id: "treble-F4", name: "F", solfege: "fa", step: -3, frequency: 349.23, clef: .treble, description: "F4"),
        NoteData(id: "treble-G4", name: "G", solfege: "sol", step: -2, frequency: 392.00, clef: .treble, description: "G4"),
        NoteData(id: "treble-A4", name: "A", solfege: "la", step: -1, frequency: 440.00, clef: .treble, description: "A4 (440Hz)"),
        NoteData(id: "treble-B4", name: "B", solfege: "si", step: 0, frequency: 493.88, clef: .treble, description: "B4"),
        NoteData(id: "treble-C5", name: "C", solfege: "do", step: 1, frequency: 523.25, clef: .treble, description: "C5"),
        NoteData(id: "treble-D5", name: "D", solfege: "re", step: 2, frequency: 587.33, clef: .treble, description: "D5"),
        NoteData(id: "treble-E5", name: "E", solfege: "mi", step: 3, frequency: 659.25, clef: .treble, description: "E5"),
        NoteData(id: "treble-F5", name: "F", solfege: "fa", step: 4, frequency: 698.46, clef: .treble, description: "F5"),
        NoteData(id: "treble-G5", name: "G", solfege: "sol", step: 5, frequency: 783.99, clef: .treble, description: "G5"),
        NoteData(id: "treble-A5", name: "A", solfege: "la", step: 6, frequency: 880.00, clef: .treble, description: "A5"),
        NoteData(id: "treble-B5", name: "B", solfege: "si", step: 7, frequency: 987.77, clef: .treble, description: "B5"),
        NoteData(id: "treble-C6", name: "C", solfege: "do", step: 8, frequency: 1046.50, clef: .treble, description: "C6"),
        NoteData(id: "treble-D6", name: "D", solfege: "re", step: 9, frequency: 1174.66, clef: .treble, description: "D6"),
        NoteData(id: "treble-E6", name: "E", solfege: "mi", step: 10, frequency: 1318.51, clef: .treble, description: "E6"),
        NoteData(id: "treble-F6", name: "F", solfege: "fa", step: 11, frequency: 1396.91, clef: .treble, description: "F6"),
        NoteData(id: "treble-G6", name: "G", solfege: "sol", step: 12, frequency: 1567.98, clef: .treble, description: "G6"),
    ]

    // Bass middle line: D3 (step 0)
    // Range: D1 to G4
    // 使用移动唱名法：D=fa, E=sol, F=la, G=si, A=do, B=re, C=mi
    static let BASS_NOTES: [NoteData] = [
        NoteData(id: "bass-D1", name: "D", solfege: "fa", step: -14, frequency: 36.71, clef: .bass, description: "D1"),
        NoteData(id: "bass-E1", name: "E", solfege: "sol", step: -13, frequency: 41.20, clef: .bass, description: "E1"),
        NoteData(id: "bass-F1", name: "F", solfege: "la", step: -12, frequency: 43.65, clef: .bass, description: "F1"),
        NoteData(id: "bass-G1", name: "G", solfege: "si", step: -11, frequency: 49.00, clef: .bass, description: "G1"),
        NoteData(id: "bass-A1", name: "A", solfege: "do", step: -10, frequency: 55.00, clef: .bass, description: "A1"),
        NoteData(id: "bass-B1", name: "B", solfege: "re", step: -9, frequency: 61.74, clef: .bass, description: "B1"),
        NoteData(id: "bass-C2", name: "C", solfege: "mi", step: -8, frequency: 65.41, clef: .bass, description: "C2"),
        NoteData(id: "bass-D2", name: "D", solfege: "fa", step: -7, frequency: 73.42, clef: .bass, description: "D2"),
        NoteData(id: "bass-E2", name: "E", solfege: "sol", step: -6, frequency: 82.41, clef: .bass, description: "E2"),
        NoteData(id: "bass-F2", name: "F", solfege: "la", step: -5, frequency: 87.31, clef: .bass, description: "F2"),
        NoteData(id: "bass-G2", name: "G", solfege: "si", step: -4, frequency: 98.00, clef: .bass, description: "G2"),
        NoteData(id: "bass-A2", name: "A", solfege: "do", step: -3, frequency: 110.00, clef: .bass, description: "A2"),
        NoteData(id: "bass-B2", name: "B", solfege: "re", step: -2, frequency: 123.47, clef: .bass, description: "B2"),
        NoteData(id: "bass-C3", name: "C", solfege: "mi", step: -1, frequency: 130.81, clef: .bass, description: "C3"),
        NoteData(id: "bass-D3", name: "D", solfege: "fa", step: 0, frequency: 146.83, clef: .bass, description: "D3"),
        NoteData(id: "bass-E3", name: "E", solfege: "sol", step: 1, frequency: 164.81, clef: .bass, description: "E3"),
        NoteData(id: "bass-F3", name: "F", solfege: "la", step: 2, frequency: 174.61, clef: .bass, description: "F3"),
        NoteData(id: "bass-G3", name: "G", solfege: "si", step: 3, frequency: 196.00, clef: .bass, description: "G3"),
        NoteData(id: "bass-A3", name: "A", solfege: "do", step: 4, frequency: 220.00, clef: .bass, description: "A3"),
        NoteData(id: "bass-B3", name: "B", solfege: "re", step: 5, frequency: 246.94, clef: .bass, description: "B3"),
        NoteData(id: "bass-C4", name: "C", solfege: "mi", step: 6, frequency: 261.63, clef: .bass, description: "C4 (Middle C)"),
        NoteData(id: "bass-D4", name: "D", solfege: "fa", step: 7, frequency: 293.66, clef: .bass, description: "D4"),
        NoteData(id: "bass-E4", name: "E", solfege: "sol", step: 8, frequency: 329.63, clef: .bass, description: "E4"),
        NoteData(id: "bass-F4", name: "F", solfege: "la", step: 9, frequency: 349.23, clef: .bass, description: "F4"),
        NoteData(id: "bass-G4", name: "G", solfege: "si", step: 10, frequency: 392.00, clef: .bass, description: "G4"),
    ]
}

// MARK: - Color Extension

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
