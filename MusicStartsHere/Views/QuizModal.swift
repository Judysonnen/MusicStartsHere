//
//  QuizModal.swift
//  MusicStartsHere
//
//  Created by Di on 12/15/25.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum QuestionResult {
    case unanswered
    case correct
    case incorrect
}

// Explicit finite state machine for quiz interaction
enum QuizState {
    case idle           // State 1: Question displayed, can select, button shows "检查答案"
    case checked        // State 2: Feedback shown, options locked, button shows "继续"
}

struct QuizModal: View {
    let notesPool: [NoteData]
    let clef: ClefType
    let progress: UserProgress
    let onCompleteQuestion: ([String], Bool) -> Void
    init(notesPool: [NoteData], clef: ClefType, progress: UserProgress, onCompleteQuestion: @escaping ([String], Bool) -> Void) {
        self.notesPool = notesPool
        self.clef = clef
        self.progress = progress
        self.onCompleteQuestion = onCompleteQuestion
        // Pre-generate questions synchronously to avoid any loading state
        let generatedQuestions = Self.makeQuizQuestions(notesPool: notesPool, progress: progress)
        self._questions = State(initialValue: generatedQuestions)
        // Initialize results array with same count
        self._questionResults = State(initialValue: Array(repeating: .unanswered, count: generatedQuestions.count))
    }
    @Environment(\.dismiss) var dismiss

    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: String?
    @State private var quizState: QuizState = .idle  // Explicit state machine
    @State private var isFinished = false
    @State private var questionResults: [QuestionResult] = []  // Track each question's result

    #if canImport(UIKit)
    private func hapticSuccess() {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
    }
    private func hapticError() {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.error)
    }
    private func hapticNext() {
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.impactOccurred()
    }
    #endif

    var body: some View {
        ZStack {
            if !questions.isEmpty {
                QuizQuestionView(
                    question: questions[currentIndex],
                    clef: clef,
                    currentIndex: currentIndex,
                    totalQuestions: questions.count,
                    questionResults: questionResults,
                    selectedAnswer: $selectedAnswer,
                    quizState: $quizState,
                    onCheckAnswer: checkAnswer,
                    onContinue: continueToNext,
                    onClose: { dismiss() }
                )
                .id(currentIndex)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("正在准备测试…")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .onAppear {
                    // Fallback: ensure questions are generated when the view is presented
                    if questions.isEmpty && !notesPool.isEmpty {
                        print("QuizModal onAppear: questions empty, generating now…")
                        generateQuiz()
                    } else {
                        print("QuizModal onAppear: questions.count=\(questions.count), notesPool.isEmpty=\(notesPool.isEmpty)")
                    }
                }
            }
            
            // Results popup overlay
            if isFinished {
                ResultsPopup(score: score, total: questions.count, clef: clef, onClose: { dismiss() })
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1000)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            print("QuizModal appeared")
        }
    }

    private static func selectNoteByProgressStatic(from notes: [NoteData], progress: UserProgress) -> NoteData {
        let weights = notes.map { note -> Double in
            let correctCount = progress[note.id]?.correctCount ?? 0
            return pow(0.5, Double(correctCount))
        }
        let totalWeight = weights.reduce(0, +)
        var randomValue = Double.random(in: 0..<totalWeight)
        for (index, weight) in weights.enumerated() {
            randomValue -= weight
            if randomValue <= 0 { return notes[index] }
        }
        return notes.last!
    }

    private static func makeQuizQuestions(notesPool: [NoteData], progress: UserProgress) -> [QuizQuestion] {
        guard !notesPool.isEmpty else { return [] }
        var newQuestions: [QuizQuestion] = []
        for _ in 0..<10 {
            let rawCount = [1, 2, 3].randomElement() ?? 2
            let noteCount = min(rawCount, max(1, notesPool.count))
            var currentNotes: [NoteData] = []
            var availableNotes = notesPool
            for _ in 0..<noteCount {
                guard !availableNotes.isEmpty else { break }
                let selectedNote = selectNoteByProgressStatic(from: availableNotes, progress: progress)
                currentNotes.append(selectedNote)
                availableNotes.removeAll { $0.id == selectedNote.id }
            }
            let correctAnswer = currentNotes.map { $0.solfege }.joined(separator: " ")
            var options = Set<String>()
            options.insert(correctAnswer)
            if currentNotes.count > 1 {
                let shuffled = currentNotes.shuffled().map { $0.solfege }.joined(separator: " ")
                if shuffled != correctAnswer { options.insert(shuffled) }
            }
            if let idx = currentNotes.indices.randomElement(), let alt = notesPool.randomElement() {
                var altNotes = currentNotes
                altNotes[idx] = alt
                let s = altNotes.map { $0.solfege }.joined(separator: " ")
                if s != correctAnswer { options.insert(s) }
            }
            if currentNotes.count >= 2 {
                var altNotes = currentNotes
                for _ in 0..<2 {
                    if let idx = altNotes.indices.randomElement(), let alt = notesPool.randomElement() {
                        altNotes[idx] = alt
                    }
                }
                let s = altNotes.map { $0.solfege }.joined(separator: " ")
                if s != correctAnswer { options.insert(s) }
            }
            for _ in 0..<6 {
                var randomNotes: [NoteData] = []
                for _ in 0..<noteCount {
                    if let n = notesPool.randomElement() { randomNotes.append(n) }
                }
                let s = randomNotes.map { $0.solfege }.joined(separator: " ")
                if s != correctAnswer { options.insert(s) }
                if options.count >= 6 { break }
            }
            var choicesArray = Array(options)
            choicesArray.shuffle()
            choicesArray = Array(choicesArray.prefix(6))
            while choicesArray.count < 6 {
                let filler = (0..<noteCount).compactMap { _ in notesPool.randomElement() }.map { $0.solfege }.joined(separator: " ")
                if !choicesArray.contains(filler) && filler != correctAnswer {
                    choicesArray.append(filler)
                }
            }
            if choicesArray.isEmpty {
                let filler = currentNotes.isEmpty ? "" : currentNotes.map { $0.solfege }.joined(separator: " ")
                if !filler.isEmpty { choicesArray.append(filler) }
            }
            while choicesArray.count < 4 {
                let filler = (0..<noteCount).compactMap { _ in notesPool.randomElement() }.map { $0.solfege }.joined(separator: " ")
                if !choicesArray.contains(filler) { choicesArray.append(filler) }
            }
            newQuestions.append(QuizQuestion(notes: currentNotes, correctAnswer: correctAnswer, options: choicesArray))
        }
        return newQuestions
    }

    private func generateQuiz() {
        guard !notesPool.isEmpty else {
            questions = []
            currentIndex = 0
            score = 0
            isFinished = false
            selectedAnswer = nil
            quizState = .idle
            questionResults = []
            return
        }
        questions = Self.makeQuizQuestions(notesPool: notesPool, progress: progress)
        questionResults = Array(repeating: .unanswered, count: questions.count)
        currentIndex = 0
        score = 0
        isFinished = false
        selectedAnswer = nil
        quizState = .idle  // Reset to idle state
    }

    // State 1 → State 2: Check the selected answer
    private func checkAnswer() {
        // Guard: Only allow checking in idle state with a selected answer
        guard quizState == .idle, let answer = selectedAnswer else { return }
        
        let currentQ = questions[currentIndex]
        let isCorrect = answer == currentQ.correctAnswer
        
        // Record the result
        questionResults[currentIndex] = isCorrect ? .correct : .incorrect
        
        if isCorrect {
            score += 1
            AudioService.playTone(frequency: currentQ.notes[0].frequency)
        }

        #if canImport(UIKit)
        if isCorrect { hapticSuccess() } else { hapticError() }
        #endif
        
        // Transition to checked state - STAY ON CURRENT QUESTION
        quizState = .checked
    }

    // State 2 → State 1: Advance to next question or finish
    private func continueToNext() {
        // Guard: Only allow continuing in checked state
        guard quizState == .checked else { return }
        
        // Call the progress callback when moving to next question
        let currentQ = questions[currentIndex]
        let isCorrect = selectedAnswer == currentQ.correctAnswer
        onCompleteQuestion(currentQ.notes.map { $0.id }, isCorrect)

        #if canImport(UIKit)
        hapticNext()
        #endif

        // Advance to next question or finish
        if currentIndex < questions.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                currentIndex += 1
            }
            selectedAnswer = nil
            quizState = .idle  // Reset to idle state for new question
        } else {
            isFinished = true
        }
    }
}

struct QuizQuestionView: View {
    let question: QuizQuestion
    let clef: ClefType
    let currentIndex: Int
    let totalQuestions: Int
    let questionResults: [QuestionResult]
    @Binding var selectedAnswer: String?
    @Binding var quizState: QuizState
    let onCheckAnswer: () -> Void
    let onContinue: () -> Void
    let onClose: () -> Void
    
    @State private var isButtonPressed = false

    var themeColor: Color {
        clef == .treble ? Constants.TREBLE_THEME_COLOR : Constants.BASS_THEME_COLOR
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            GeometryReader { proxy in
                let totalH = proxy.size.height
                let scaleFactor: CGFloat = min(1.2, max(0.85, totalH / 844.0)) // 844 ~ iPhone Pro baseline
                let topReserved: CGFloat = 64
                let bottomButtonH: CGFloat = 45 * scaleFactor
                let verticalSpacing: CGFloat = 12 * scaleFactor
                let optionsRows: CGFloat = 3
                let optionH: CGFloat = 115 * scaleFactor
                let optionsSpacing: CGFloat = 10 * scaleFactor
                let optionsPaddingV: CGFloat = 16 * scaleFactor
                let estimatedOptionsH = optionsRows * optionH + 2 * optionsSpacing + 2 * optionsPaddingV
                let staffTarget = totalH * (0.29 + 0.03 * min(1, scaleFactor))  // Increased height
                let availableForStaff = max(130 * scaleFactor, min(staffTarget, totalH - topReserved - bottomButtonH - estimatedOptionsH - 2 * verticalSpacing))

                    VStack(spacing: 0) {
                        // Header - matching GridView style
                        GeometryReader { geo in
                            let _ = geo.safeAreaInsets.top
                            
                            ZStack(alignment: .bottom) {
                                Color(hex: 0x191919)
                                    .ignoresSafeArea(edges: .top)
                                
                                HStack(spacing: 12) {
                                    Button(action: onClose) {
                                        Image(systemName: "chevron.left")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    GeometryReader { progressGeo in
                                        HStack(spacing: 2) {
                                            ForEach(0..<totalQuestions, id: \.self) { index in
                                                let result = questionResults[index]
                                                let fillColor: Color = {
                                                    switch result {
                                                    case .correct:
                                                        return .green
                                                    case .incorrect:
                                                        return .red
                                                    case .unanswered:
                                                        return index == currentIndex ? themeColor.opacity(0.3) : Color.clear
                                                    }
                                                }()
                                                
                                                ZStack {
                                                    Capsule()
                                                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                                                    Capsule()
                                                        .fill(fillColor)
                                                        .padding(1.5)
                                                }
                                                .frame(width: {
                                                    // Safely compute per-segment width; avoid division by zero or negative/NaN values
                                                    let segments = max(1, totalQuestions)
                                                    let spacing: CGFloat = 2
                                                    let available = max(0, progressGeo.size.width.isFinite ? progressGeo.size.width : 100)
                                                    let totalSpacing = CGFloat(segments - 1) * spacing
                                                    let raw = (available - totalSpacing) / CGFloat(segments)
                                                    // Ensure minimum width of 1pt and check for finite value
                                                    let width = max(1, raw)
                                                    return width.isFinite ? width : 1
                                                }())
                                                .frame(height: 6)
                                                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: result)
                                                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentIndex)
                                            }
                                        }
                                    }
                                    .frame(height: 6)
                                }
                                .padding(.horizontal, 12)
                                .padding(.bottom, 12)
                            }
                        }
                        .frame(height: 40 + (UIApplication.shared.connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .first?.windows
                            .first?.safeAreaInsets.top ?? 0))
                        
                        Spacer()
                            .frame(height: verticalSpacing)

                    // Staff area - with card background matching options width
                    HStack(spacing: 0) {
                        Spacer(minLength: 0)
                        let scale: CGFloat = 0.8
                        StaffNoteView(
                            notes: question.notes,
                            clef: clef,
                            scale: scale,
                            staffWidthRatio: 1.2
                        )
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: availableForStaff)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)

                    Spacer()
                        .frame(height: verticalSpacing * 1.5)

                    // Options grid
                    let columns = [
                        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 12),
                        GridItem(.flexible(minimum: 0, maximum: .infinity), spacing: 12)
                    ]
                    LazyVGrid(columns: columns, spacing: optionsSpacing) {
                        ForEach(question.options, id: \.self) { option in
                            AnswerButton(
                                option: option,
                                isSelected: selectedAnswer == option,
                                isCorrect: option == question.correctAnswer,
                                quizState: quizState,
                                themeColor: themeColor,
                                action: {
                                    // Only allow selection in idle state
                                    if quizState == .idle {
                                        selectedAnswer = option
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)

                    Spacer()
                        .frame(height: verticalSpacing * 1.5)

                    // Bottom primary button - full width matching staff and options
                    Button(action: {
                        switch quizState {
                        case .idle:
                            // State 1: Check answer (only if something selected)
                            if selectedAnswer != nil {
                                onCheckAnswer()
                            }
                        case .checked:
                            // State 2: Continue to next
                            onContinue()
                        }
                    }) {
                        Text(quizState == .checked ? "继续" : "检查答案")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)  // Full width
                            .frame(height: bottomButtonH)
                            .background(themeColor)
                            .cornerRadius(12)
                    }
                    .disabled(quizState == .idle && selectedAnswer == nil)
                    .opacity(quizState == .idle && selectedAnswer == nil ? 0.5 : 1)
                    .scaleEffect(isButtonPressed ? 0.96 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isButtonPressed)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isButtonPressed {
                                    isButtonPressed = true
                                }
                            }
                            .onEnded { _ in
                                isButtonPressed = false
                            }
                    )
                    .padding(.horizontal, 16)  // Match staff and options padding
                    .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }

            // Removed .safeAreaInset(edge: .top) block completely as per instructions
        }
    }
}

struct AnswerButton: View {
    let option: String
    let isSelected: Bool
    let isCorrect: Bool
    let quizState: QuizState
    let themeColor: Color
    let action: () -> Void

    var textColor: Color {
        switch quizState {
        case .idle:
            // State 1: Normal colors, yellow highlight for selected
            return .black
        case .checked:
            // State 2: Show feedback colors - brighter white for better visibility
            if isCorrect {
                return .white
            }
            if isSelected && !isCorrect {
                return .white
            }
            return .primary
        }
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                let baseShape = RoundedRectangle(cornerRadius: 12)
                switch quizState {
                case .idle:
                    // State 1: Yellow for selected, white for unselected
                    if isSelected {
                        baseShape.fill(Color.yellow)
                    } else {
                        baseShape.fill(Color.white)
                    }
                case .checked:
                    // State 2: Show feedback colors - custom brand colors
                    if isCorrect {
                        // Green: #0C7C59 - custom green
                        baseShape.fill(Color(.sRGB, red: 12/255, green: 124/255, blue: 89/255, opacity: 1.0))
                    } else if isSelected {
                        // Red: #C32F27 - custom red
                        baseShape.fill(Color(.sRGB, red: 195/255, green: 47/255, blue: 39/255, opacity: 1.0))
                    } else {
                        // Keep other options bright white
                        baseShape.fill(Color.white)
                    }
                }
                
                VStack(spacing: 4) {
                    Text(option)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(textColor)
                        .shadow(color: quizState == .checked && (isCorrect || isSelected) ? .black.opacity(0.3) : .clear, radius: 2, x: 0, y: 1)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .frame(height: 115)
            }
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black, lineWidth: 1.5))
            .scaleEffect(isSelected && quizState == .idle ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: isSelected)
            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: quizState)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(quizState == .idle)  // Only allow interaction in idle state, no gray overlay
    }
}

struct ResultsPopup: View {
    let score: Int
    let total: Int
    let clef: ClefType
    let onClose: () -> Void

    var isPerfect: Bool {
        score == total
    }
    
    var themeColor: Color {
        clef == .treble ? Constants.TREBLE_THEME_COLOR : Constants.BASS_THEME_COLOR
    }

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            // Popup card
            VStack(spacing: 20) {
                // Clef symbol
                Text(clef == .treble ? "𝄞" : "𝄢")
                    .font(.system(size: 80))
                    .foregroundColor(themeColor)
                
                // Congratulations message
                Text(isPerfect ? "完美！" : "真棒！")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                // Score
                Text("答对了 \(score)/\(total) 题")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)
                
                // Return button
                Button(action: onClose) {
                    Text("返回")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(themeColor)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
        }
    }
}
