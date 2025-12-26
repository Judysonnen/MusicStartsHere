//
//  Types.swift
//  MusicStartsHere
//
//  Created by Di on 12/15/25.
//

import Foundation

enum ClefType: String, Codable {
    case treble
    case bass
}

struct NoteData: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let solfege: String
    let step: Int
    let frequency: Double
    let clef: ClefType
    let description: String
}

struct UserNoteProgress: Codable {
    var correctCount: Int = 0
    var consecutiveCorrect: Int = 0
    var lastPracticed: TimeInterval = 0
    var masteryLevel: Int = 0
}

typealias UserProgress = [String: UserNoteProgress]

struct QuizQuestion {
    let notes: [NoteData]
    let correctAnswer: String
    let options: [String]
}
