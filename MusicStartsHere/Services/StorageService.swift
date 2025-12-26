//
//  StorageService.swift
//  MusicStartsHere
//
//  Created by Di on 12/15/25.
//

import Foundation

class StorageService {
    private static let progressKey = "notebear_user_progress"
    
    static func getProgress() -> UserProgress {
        guard let data = UserDefaults.standard.data(forKey: progressKey),
              let progress = try? JSONDecoder().decode(UserProgress.self, from: data) else {
            return [:]
        }
        return progress
    }
    
    static func saveProgress(_ progress: UserProgress) {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: progressKey)
        }
    }
    
    static func updateNoteProgress(_ progress: UserProgress, noteId: String, isCorrect: Bool) -> UserProgress {
        var newProgress = progress
        var noteProgress = newProgress[noteId] ?? UserNoteProgress()
        
        noteProgress.lastPracticed = Date().timeIntervalSince1970
        
        if isCorrect {
            noteProgress.correctCount += 1
            noteProgress.consecutiveCorrect += 1
        } else {
            // Reset consecutive on mistake to reinforce learning
            noteProgress.consecutiveCorrect = 0
        }
        
        // Calculate Mastery
        if noteProgress.consecutiveCorrect >= 6 {
            noteProgress.masteryLevel = 3
        } else if noteProgress.consecutiveCorrect >= 3 {
            noteProgress.masteryLevel = 2
        } else if noteProgress.consecutiveCorrect >= 1 {
            noteProgress.masteryLevel = 1
        } else {
            noteProgress.masteryLevel = 0
        }
        
        newProgress[noteId] = noteProgress
        return newProgress
    }
}
