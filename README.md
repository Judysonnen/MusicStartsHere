# Note Bear - Music Academy

A SwiftUI app for learning and memorizing musical notes on the treble and bass clefs.

## Project Structure

```
MusicStartsHere/
├── MusicStartsHereApp.swift       # App entry point
├── ContentView.swift              # Main navigation controller
│
├── Models/
│   ├── Types.swift                # Core data types (ClefType, NoteData, etc.)
│   └── Constants.swift            # Note definitions (TREBLE_NOTES, BASS_NOTES)
│
├── Services/
│   ├── StorageService.swift       # UserDefaults persistence
│   └── AudioService.swift         # Audio playback for notes
│
├── Components/
│   ├── StaffNoteView.swift        # Musical staff visualization
│   └── MascotView.swift           # Animated bear mascot
│
└── Views/
    ├── HomeView.swift             # Clef selection screen
    ├── GridView.swift             # Note grid/library view
    ├── NoteDetailModal.swift      # Individual note details
    └── QuizModal.swift            # Practice quiz interface
```

## Features

### 🎵 Core Features
- **Treble & Bass Clef Support**: Learn notes in both clefs
- **Interactive Note Cards**: Tap to hear and see note details
- **Mastery Tracking**: Progress system with 4 levels (0-3)
- **Practice Quiz**: 5-question quizzes with instant feedback
- **Audio Playback**: Hear each note when selected
- **Persistent Progress**: Your learning progress is saved

### 🎨 UI Features
- Beautiful, clean SwiftUI interface
- Smooth animations and transitions
- Responsive grid layout
- Color-coded mastery levels
- Animated bear mascot
- Musical staff notation visualization

## How to Run

1. **Open in Xcode**: Open `MusicStartsHere.xcodeproj`
2. **Select Target**: Choose a simulator or device
3. **Build & Run**: Press ⌘+R or click the Run button

### Requirements
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

## How to Use

1. **Start**: Launch the app and select either Treble or Bass clef
2. **Explore**: Browse the note grid - tap any note to see details
3. **Learn**: Study note positions and listen to their sounds
4. **Practice**: Take quizzes to test your knowledge
5. **Master**: Keep practicing until all notes are mastered (⭐)

### Mastery Levels
- **Level 0** (White): Not yet practiced
- **Level 1** (Light Orange): Beginner
- **Level 2** (Orange): Intermediate  
- **Level 3** (Red/Blue with ⭐): Mastered!

## Technical Details

### Data Model
- `NoteData`: Represents a musical note with frequency, position, and metadata
- `ClefType`: Enum for treble/bass selection
- `UserProgress`: Dictionary tracking mastery level for each note
- `QuizQuestion`: Quiz data with notes and answer options

### Services
- **StorageService**: Handles UserDefaults persistence
- **AudioService**: Generates audio tones using AVAudioEngine

### Note Representation
- 21 notes per clef (TREBLE_NOTES, BASS_NOTES)
- Each note has:
  - Name (e.g., "C", "D#")
  - Solfege (do, re, mi, etc.)
  - Frequency in Hz
  - Staff position (step number)
  - Description

## Converting from React

This SwiftUI app was converted from a React/TypeScript web app. Key translations:

| React | SwiftUI |
|-------|---------|
| `useState` | `@State` |
| `useEffect` | `.onAppear` |
| `props` | `let` properties |
| `className` | View modifiers |
| LocalStorage | UserDefaults |
| Web Audio API | AVAudioEngine |
| CSS animations | SwiftUI animations |

## Future Enhancements

Potential features to add:
- [ ] More note ranges (extended bass/treble)
- [ ] Spaced repetition algorithm
- [ ] Statistics and charts
- [ ] Multiple quiz modes
- [ ] Customizable themes
- [ ] Achievement system
- [ ] Export/import progress
- [ ] iPad optimization

## License

Educational project - feel free to use and modify.
