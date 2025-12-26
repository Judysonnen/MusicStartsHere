//
//  GridView.swift
//  MusicStartsHere
//
//  Created by Di on 12/15/25.
//

import SwiftUI

struct GridView: View {
    let clef: ClefType
    @Binding var progress: UserProgress
    @Binding var selectedClef: ClefType?
    
    @State private var showQuiz = false
    @State private var isMultiSelectMode = false
    @State private var selectedNotes: Set<String> = []
    @State private var quizNotesPool: [NoteData] = []
    @State private var showSettings = false
    @State private var showResetAlert = false
    @State private var excludedNoteIds: Set<String> = []
    @State private var appeared = false
    
    var allNotes: [NoteData] {
        clef == .treble ? Constants.TREBLE_NOTES : Constants.BASS_NOTES
    }
    
    var activeNotes: [NoteData] {
        allNotes.filter { !excludedNoteIds.contains($0.id) }
    }
    
    var themeColor: Color {
        clef == .treble ? Constants.TREBLE_THEME_COLOR : Constants.BASS_THEME_COLOR
    }
    
    var selectedNotesData: [NoteData] {
        activeNotes.filter { selectedNotes.contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { _ in
                ZStack {
                // Background
                Color(red: 0.95, green: 0.95, blue: 0.95)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header - title centered to screen
                    ZStack {
                        Color(hex: 0x191919)
                            .ignoresSafeArea(edges: .top)
                        
                        // Buttons layer
                        HStack(spacing: 12) {
                            Button(action: {
                                if isMultiSelectMode {
                                    isMultiSelectMode = false
                                    selectedNotes.removeAll()
                                } else {
                                    selectedClef = nil
                                }
                            }) {
                                Image(systemName: isMultiSelectMode ? "xmark" : "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Button(action: {
                                    showSettings = true
                                }) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Button(action: {
                                    isMultiSelectMode.toggle()
                                    if !isMultiSelectMode {
                                        selectedNotes.removeAll()
                                    }
                                }) {
                                    Image(systemName: isMultiSelectMode ? "checklist.checked" : "checklist")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(isMultiSelectMode ? themeColor : .white.opacity(0.8))
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        
                        // Title layer (absolutely centered)
                        if isMultiSelectMode {
                            Text("已选 \(selectedNotes.count) 个")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        } else {
                            HStack(spacing: 4) {
                                Text(clef == .treble ? "𝄞" : "𝄢")
                                    .font(.system(size: 16, weight: .ultraLight))
                                    .foregroundColor(themeColor.opacity(0.9))
                                
                                Text(clef == .treble ? "高音谱号" : "低音谱号")
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                    .kerning(0.5)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    .frame(height: 40)
                    
                    // Notes Grid
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 6),
                            GridItem(.flexible(), spacing: 6),
                            GridItem(.flexible(), spacing: 6)
                        ],
                        spacing: 13
                    ) {
                        ForEach(activeNotes) { note in
                            if isMultiSelectMode {
                                NoteCard(
                                    note: note,
                                    progress: progress[note.id] ?? UserNoteProgress(),
                                    themeColor: themeColor,
                                    isMultiSelectMode: isMultiSelectMode,
                                    isSelected: selectedNotes.contains(note.id),
                                    onTap: {
                                        if selectedNotes.contains(note.id) {
                                            selectedNotes.remove(note.id)
                                        } else {
                                            selectedNotes.insert(note.id)
                                        }
                                    }
                                )
                                .frame(minHeight: 131)
                            } else {
                                NavigationLink(destination: NoteDetailModal(note: note, progress: progress)) {
                                    NoteCard(
                                        note: note,
                                        progress: progress[note.id] ?? UserNoteProgress(),
                                        themeColor: themeColor,
                                        isMultiSelectMode: false,
                                        isSelected: false,
                                        onTap: {}
                                    )
                                    .frame(minHeight: 131)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 16)
                    .padding(.bottom, 160)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                // Mode Selection Buttons or Test Selected Button
                if isMultiSelectMode && !selectedNotes.isEmpty {
                    // Test selected notes button
                    VStack {
                        Spacer()
                        Button(action: {
                            quizNotesPool = selectedNotesData
                            showQuiz = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                Text("开始测试 (\(selectedNotes.count)个音符)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                clef == .treble ? Constants.TREBLE_THEME_COLOR : Constants.BASS_THEME_COLOR
                            )
                            .cornerRadius(30)
                            .shadow(color: themeColor.opacity(0.3), radius: 10, y: 5)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                } else if !isMultiSelectMode {
                    // Normal mode buttons
                    VStack {
                        Spacer()
                        VStack(spacing: 12) {
                            Button(action: {
                                quizNotesPool = activeNotes
                                showQuiz = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "list.clipboard.fill")
                                    Text("开始特训")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    clef == .treble ? Constants.TREBLE_THEME_COLOR : Constants.BASS_THEME_COLOR
                                )
                                .cornerRadius(30)
                                .shadow(color: themeColor.opacity(0.3), radius: 10, y: 5)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                    }
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(.easeOut(duration: 0.28), value: appeared)
            .onAppear {
                appeared = true
            }
        }
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showSettings) {
            SettingsView(
                clef: clef,
                themeColor: themeColor,
                allNotes: allNotes,
                excludedNoteIds: $excludedNoteIds,
                onResetProgress: {
                    showSettings = false
                    showResetAlert = true
                }
            )
        }
        .alert("重置所有进度", isPresented: $showResetAlert) {
            Button("取消", role: .cancel) { }
            Button("确认重置", role: .destructive) {
                resetAllProgress()
            }
        } message: {
            Text("确定要清空所有音符的答对次数吗？此操作不可恢复。")
        }
        .fullScreenCover(isPresented: $showQuiz) {
            QuizModal(
                notesPool: quizNotesPool.isEmpty ? activeNotes : quizNotesPool,
                clef: clef,
                progress: progress,
                onCompleteQuestion: { noteIds, isCorrect in
                    var currentProgress = progress
                    for id in noteIds {
                        currentProgress = StorageService.updateNoteProgress(
                            currentProgress,
                            noteId: id,
                            isCorrect: isCorrect
                        )
                    }
                    progress = currentProgress
                    StorageService.saveProgress(currentProgress)
                }
            )
            .onDisappear {
                // Exit multi-select mode and clear selection after quiz
                if isMultiSelectMode {
                    isMultiSelectMode = false
                    selectedNotes.removeAll()
                }
                // Clear quiz notes pool
                quizNotesPool = []
            }
        }
    }
    
    func resetAllProgress() {
        var updatedProgress = progress
        for note in allNotes {
            var noteProgress = updatedProgress[note.id] ?? UserNoteProgress()
            noteProgress.correctCount = 0
            noteProgress.consecutiveCorrect = 0
            noteProgress.masteryLevel = 0
            updatedProgress[note.id] = noteProgress
        }
        progress = updatedProgress
        StorageService.saveProgress(updatedProgress)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    let clef: ClefType
    let themeColor: Color
    let allNotes: [NoteData]
    @Binding var excludedNoteIds: Set<String>
    let onResetProgress: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // 音符选择部分
                Section {
                    ForEach(allNotes) { note in
                        Toggle(isOn: Binding(
                            get: { !excludedNoteIds.contains(note.id) },
                            set: { isIncluded in
                                if isIncluded {
                                    excludedNoteIds.remove(note.id)
                                } else {
                                    excludedNoteIds.insert(note.id)
                                }
                            }
                        )) {
                            HStack(spacing: 12) {
                                // Extract octave notation from note.id (e.g., "treble-C4" -> "C4")
                                let octaveLabel: String = {
                                    let parts = note.id.split(separator: "-")
                                    if parts.count >= 2 {
                                        return String(parts[1])
                                    } else {
                                        return note.name
                                    }
                                }()
                                
                                Text(octaveLabel)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(themeColor)
                                    .frame(width: 30)
                                
                                Text(note.solfege)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .tint(themeColor)
                    }
                } header: {
                    HStack {
                        Text("包含的音符")
                        Spacer()
                        Button(action: {
                            if excludedNoteIds.isEmpty {
                                excludedNoteIds = Set(allNotes.map { $0.id })
                            } else {
                                excludedNoteIds.removeAll()
                            }
                        }) {
                            Text(excludedNoteIds.isEmpty ? "取消全选" : "全选")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(themeColor)
                        }
                    }
                } footer: {
                    Text("已选择 \(allNotes.count - excludedNoteIds.count) 个音符")
                }
                
                // 重置进度部分
                Section {
                    Button(action: onResetProgress) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.red)
                            Text("重置所有进度")
                                .foregroundColor(.red)
                        }
                    }
                } header: {
                    Text("危险操作")
                } footer: {
                    Text("将清空所有音符的答对次数，此操作不可恢复")
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(themeColor)
                }
            }
        }
    }
}


struct NoteCard: View {
    let note: NoteData
    let progress: UserNoteProgress
    let themeColor: Color
    let isMultiSelectMode: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    var cardBackground: Color {
        if isMultiSelectMode && isSelected {
            return themeColor.opacity(0.25)
        }
        
        let correctCount = progress.correctCount
        
        // Four distinct color levels for clear differentiation
        if correctCount == 0 {
            // Level 0: Not practiced yet (0 times) - 15% opacity
            return themeColor.opacity(0.15)
        } else if correctCount <= 5 {
            // Level 1: Beginner (1-5 times) - 35% opacity
            return themeColor.opacity(0.35)
        } else if correctCount <= 9 {
            // Level 2: Intermediate (6-9 times) - 60% opacity
            return themeColor.opacity(0.60)
        } else {
            // Level 3: Advanced (10+ times) - 100% opacity
            return themeColor.opacity(1.0)
        }
    }
    
    var textColor: Color {
        .primary
    }
    
    var cardContent: some View {
        VStack(spacing: 0) {
                // 顶部：左上角显示唱名，右上角显示答对次数或选择状态
                HStack {
                    // 左上角：唱名 - 黑色
                    Text(note.solfege.lowercased())
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.black.opacity(0.85))
                    
                    Spacer()
                    
                    // 右上角：答对次数或选择状态
                    if isMultiSelectMode {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(isSelected ? themeColor : .gray.opacity(0.3))
                    } else if progress.correctCount > 0 {
                        Text("\(progress.correctCount)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.black.opacity(0.7))
                            .padding(4)
                            .background(Color.white.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal, 10)
                .frame(height: 26)
                
                // Note visualization - centered as a whole unit in remaining space
                ZStack {
                    Color.clear
                    
                    StaffNoteView(note: note, clef: note.clef, showClef: false, staffWidthRatio: 0.6)
                        .frame(height: 90)
                        .scaleEffect(1.42296)
                        .offset(y: -18) // Move up to be truly centered
                }
                .frame(maxWidth: .infinity)
                .frame(height: 105) // 131 total - 26 header = 105 for staff area
            }
            .frame(maxWidth: .infinity)
            .frame(height: 131)
            .background(
                ZStack {
                    // Base color with subtle gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            cardBackground,
                            cardBackground.opacity(0.85)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Soft highlight on top edge
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .center
                    )
                }
            )
            .cornerRadius(16)
            // Enhanced multi-layer shadow for more depth
            .shadow(
                color: themeColor.opacity(0.15),
                radius: 2,
                x: 0,
                y: 1
            )
            .shadow(
                color: Color.black.opacity(0.08),
                radius: 4,
                x: 0,
                y: 2
            )
            .shadow(
                color: Color.black.opacity(0.12),
                radius: 12,
                x: 0,
                y: 6
            )
            .overlay(
                // Enhanced border with gradient
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(progress.correctCount == 0 ? 0.3 : 0.5),
                                Color.white.opacity(progress.correctCount == 0 ? 0.1 : 0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
    }
    
    var body: some View {
        if isMultiSelectMode {
            Button(action: onTap) {
                cardContent
            }
            .buttonStyle(ScaleButtonStyle())
        } else {
            cardContent
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
