//
//  StaffNoteView.swift
//  MusicStartsHere
//
//  Created by Di on 12/15/25.
//

import SwiftUI

struct StaffNoteView: View {
    let notes: [NoteData]
    let clef: ClefType
    var showName: Bool = false
    var showClef: Bool = true
    var compact: Bool = false
    var scale: CGFloat = 1.0
    var staffWidthRatio: CGFloat = 1.0  // 1.0 = full width, 0.7 = 70% width

    init(
        note: NoteData? = nil,
        notes: [NoteData]? = nil,
        clef: ClefType,
        showName: Bool = false,
        showClef: Bool = true,
        compact: Bool = false,
        scale: CGFloat = 1.0,
        staffWidthRatio: CGFloat = 1.0
    ) {
        if let notes = notes {
            self.notes = notes
        } else if let note = note {
            self.notes = [note]
        } else {
            self.notes = []
        }
        self.clef = clef
        self.showName = showName
        self.showClef = showClef
        self.compact = compact
        self.scale = scale
        self.staffWidthRatio = staffWidthRatio
    }

    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            let base = min(width, height)

            // Apply scale transformation around center
            if scale != 1.0 {
                let centerX = width / 2
                let centerY = height / 2
                context.translateBy(x: centerX, y: centerY)
                context.scaleBy(x: scale, y: scale)
                context.translateBy(x: -centerX, y: -centerY)
            }

            // -----------------------------
            // Staff layout - Calculate to center entire notation (staff + notes) vertically
            // -----------------------------
            let lineSpacing: CGFloat = height * 0.086  // Increased by 7.5% for better spacing
            let initialCenterY: CGFloat = height * 0.5  // Initial center position
            
            // Calculate staff width based on ratio
            let baseStaffWidth = width * 0.97  // Increased to 97% for longer staff lines
            let actualStaffWidth = baseStaffWidth * staffWidthRatio
            let staffMargin = (width - actualStaffWidth) / 2
            let staffX0: CGFloat = staffMargin
            let staffX1: CGFloat = width - staffMargin
            // Decide whether to show 3 or 5 staff lines based on note positions
            let staffLineWidth: CGFloat = 0.35  // Very thin for illustration style
            
            // Check if notes are in the "core ambiguous zone" where 5 lines are needed
            // Core zone: central working area of the staff where notes can be confused
            // Extreme zone: clearly at top or bottom, position is obvious
            let isInCoreZone = notes.contains { note in
                // Core ambiguous zone: -3 to +3 (approximately)
                // This is where adjacent notes can be confused without full staff context
                // Examples: sol/la/ti in middle register
                abs(note.step) <= 3
            }
            
            var relevantLines = Set<Int>()
            
            if isInCoreZone {
                // Show all 5 lines for notes in the core ambiguous zone
                // These notes need full staff context to avoid confusion with adjacent notes
                // User should not need to "count lines" to identify the note
                relevantLines = Set([-2, -1, 0, 1, 2])
            } else {
                // Show only 3 closest lines for notes in extreme zones
                // These notes are clearly high or low - position is obvious at a glance
                // Examples: low ti/re/fa (bottom), high mi/sol/ti/re (top)
                for note in notes {
                    // Calculate actual note Y position
                    let noteY = initialCenterY - CGFloat(note.step) * (lineSpacing / 2)
                    
                    // Find 3 closest lines to this note
                    var lineDistances: [(line: Int, distance: CGFloat)] = []
                    for i in [-2, -1, 0, 1, 2] {
                        let lineY = initialCenterY + CGFloat(i) * lineSpacing
                        let distance = abs(lineY - noteY)
                        lineDistances.append((line: i, distance: distance))
                    }
                    
                    // Sort by distance and take the 3 closest lines
                    let closestLines = lineDistances.sorted { $0.distance < $1.distance }.prefix(3).map { $0.line }
                    for line in closestLines {
                        relevantLines.insert(line)
                    }
                }
            }
            
            // Calculate bounds of entire notation (staff + clef + notes with stems) to center as a unit
            var minY: CGFloat = .infinity
            var maxY: CGFloat = -.infinity
            
            // Include staff lines in bounds
            for i in relevantLines {
                let lineY = initialCenterY + CGFloat(i) * lineSpacing
                minY = min(minY, lineY)
                maxY = max(maxY, lineY)
            }
            
            // Include clef in bounds (using initialCenterY for calculation)
            if showClef {
                let clefFontSize: CGFloat
                let clefTopY: CGFloat
                let clefBottomY: CGFloat
                
                if clef == .treble {
                    // Treble clef sizing
                    clefFontSize = lineSpacing * 6.5
                    let secondLineY = initialCenterY + lineSpacing
                    let clefY = secondLineY - lineSpacing * 1.38
                    // Treble clef extends above and below its anchor point
                    clefTopY = clefY - clefFontSize * 0.45  // Approximate top extent
                    clefBottomY = clefY + clefFontSize * 0.35  // Approximate bottom extent
                } else {
                    // Bass clef sizing
                    clefFontSize = lineSpacing * 2.8
                    let fourthLineY = initialCenterY - lineSpacing
                    let clefY = fourthLineY - lineSpacing * 0.15
                    // Bass clef is more compact vertically
                    clefTopY = clefY - clefFontSize * 0.35
                    clefBottomY = clefY + clefFontSize * 0.35
                }
                
                minY = min(minY, clefTopY)
                maxY = max(maxY, clefBottomY)
            }
            
            // Include notes and stems in bounds
            for note in notes {
                let noteY = initialCenterY - CGFloat(note.step) * (lineSpacing / 2)
                let stemLength = lineSpacing * 3.5
                let stemDown = note.step > 0
                
                if stemDown {
                    minY = min(minY, noteY)
                    maxY = max(maxY, noteY + stemLength)
                } else {
                    minY = min(minY, noteY - stemLength)
                    maxY = max(maxY, noteY)
                }
            }
            
            // Calculate adjustment to center the entire notation
            let notationCenter = (minY + maxY) / 2
            let adjustment = height * 0.5 - notationCenter
            // Minimal downward offset for slight visual balance
            let downwardOffset = height * 0.03
            let centerY = initialCenterY + adjustment + downwardOffset
            
            // Draw only the relevant staff lines - much thinner and lighter for illustration style
            for i in relevantLines.sorted() {
                let y = centerY + CGFloat(i) * lineSpacing
                var p = Path()
                p.move(to: CGPoint(x: staffX0, y: y))
                p.addLine(to: CGPoint(x: staffX1, y: y))
                // Much lighter opacity - subtle hint, not dominant element
                context.stroke(p, with: .color(.primary.opacity(0.25)), lineWidth: staffLineWidth)
            }

            // -----------------------------
            // Clef - Standard notation positions
            // -----------------------------
            // Treble clef (G clef): spiral centered on 2nd line from bottom (G4, step = -2)
            // Bass clef (F clef): dots sandwich 4th line from bottom (F3, step = 2)
            if showClef {
                let clefSymbol = clef == .treble ? "𝄞" : "𝄢"
                
                if clef == .treble {
                    // Treble clef (G clef) sizing and placement
                    // Size based on lineSpacing for proper scaling
                    let secondLineY = centerY + lineSpacing
                    
                    // Size clef based on lineSpacing (not absolute height)
                    let clefFontSize = lineSpacing * 6.5
                    
                    // Position to wrap spiral around second line - moved left for better centering
                    let clefY = secondLineY - lineSpacing * 1.38
                    let clefX = width * 0.14  // Moved from 0.19 to 0.14

                    context.draw(
                        Text(clefSymbol)
                            .font(.system(size: clefFontSize, weight: .ultraLight, design: .serif))
                            .foregroundStyle(.primary.opacity(0.95)),
                        at: CGPoint(x: clefX, y: clefY)
                    )
                } else {
                    // Bass clef: dots sandwich 4th line (step = 2)
                    // Size based on lineSpacing for proper scaling
                    let fourthLineY = centerY - lineSpacing
                    let clefY = fourthLineY - lineSpacing * 0.15
                    
                    // Size clef based on lineSpacing
                    let clefFontSize = lineSpacing * 2.8
                    
                    context.draw(
                        Text(clefSymbol)
                            .font(.system(size: clefFontSize, weight: .bold, design: .serif))
                            .foregroundStyle(.primary.opacity(0.95)),
                        at: CGPoint(x: width * 0.12, y: clefY)  // Moved from 0.16 to 0.12
                    )
                }
            }

            // -----------------------------
            // Shared drawing params - Standard music notation proportions
            // -----------------------------
            // Ledger lines: 0.95x staff line width (professional standard)
            let ledgerThickness: CGFloat = staffLineWidth * 0.95

            // -----------------------------
            // Draw notes
            // -----------------------------
            for (idx, note) in notes.enumerated() {
                // Your mapping: 1 step = (lineSpacing / 2)
                let cy = centerY - CGFloat(note.step) * (lineSpacing / 2)

                let cx: CGFloat = {
                    if showClef {
                        // When clef is shown, add space after clef
                        if notes.count == 1 { 
                            return width * 0.50  // Single note centered - moved left from 0.55
                        } else {
                            // Multiple notes: use reasonable spacing, not stretched to fill all space
                            let leftMargin = width * 0.36   // Start position after clef - moved left from 0.42
                            
                            // Set maximum spacing based on line spacing (musical notation standard)
                            // This prevents notes from being too far apart when there are only 2 notes
                            let maxNoteSpacing = lineSpacing * 4.5  // Reasonable max distance between notes
                            let idealTotalWidth = CGFloat(notes.count - 1) * maxNoteSpacing
                            
                            // Calculate available space
                            let rightMargin = width * 0.08
                            let availableWidth = width - leftMargin - rightMargin
                            
                            // Use the smaller of ideal width or available width
                            let actualTotalWidth = min(idealTotalWidth, availableWidth)
                            let actualSpacing = actualTotalWidth / CGFloat(notes.count - 1)
                            
                            // Center the note group in the available space
                            let groupStart = leftMargin + (availableWidth - actualTotalWidth) / 2
                            return groupStart + CGFloat(idx) * actualSpacing
                        }
                    } else {
                        // When no clef, center the notes in the staff
                        if notes.count == 1 { return width * 0.5 }  // Single note centered
                        
                        // Use reasonable spacing for multiple notes
                        let maxNoteSpacing = lineSpacing * 4.5
                        let idealTotalWidth = CGFloat(notes.count - 1) * maxNoteSpacing
                        let availableWidth = width * 0.8  // 80% of width for note group
                        
                        let actualTotalWidth = min(idealTotalWidth, availableWidth)
                        let actualSpacing = actualTotalWidth / CGFloat(notes.count - 1)
                        
                        // Center the note group
                        let start = (width - actualTotalWidth) / 2
                        return start + CGFloat(idx) * actualSpacing
                    }
                }()

                // -----------------------------
                // Note head (professional music notation proportions)
                // -----------------------------
                // Note head height ≈ one staff space for proper proportion with staff lines
                // Ellipse dimensions: width:height ≈ 1.55:1 (classical engraving proportions)
                // Enlarged by 8% to visually dominate staff lines
                let noteHeight: CGFloat = lineSpacing * 0.88 * 1.08  // Height slightly less than one staff space, enlarged
                let noteWidth: CGFloat = noteHeight * 1.55    // Width elongated for classical oval shape
                let noteRotation: CGFloat = -12.0 * .pi / 180.0  // 12° right-tilt

                // -----------------------------
                // Ledger lines (every 2 steps beyond +/-4 for 5-line staff)
                // Staff lines at -4,-2,0,2,4 (steps) so ledgers start at ±6
                // -----------------------------
                if abs(note.step) >= 6 {
                    let direction = note.step > 0 ? 1 : -1
                    // Ledger line extends ~1/4 note width on each side beyond note head
                    // Total length = noteWidth + 2×(noteWidth/4) = 1.5× noteWidth
                    let ledgerHalfLen: CGFloat = noteWidth * 0.75  // Half of 1.5× noteWidth

                    for s in stride(from: 6, through: abs(note.step), by: 2) {
                        let lineStep = s * direction
                        let ledgerY = centerY - CGFloat(lineStep) * (lineSpacing / 2)

                        var lp = Path()
                        lp.move(to: CGPoint(x: cx - ledgerHalfLen, y: ledgerY))
                        lp.addLine(to: CGPoint(x: cx + ledgerHalfLen, y: ledgerY))
                        context.stroke(lp, with: .color(.primary.opacity(0.55)), lineWidth: ledgerThickness)
                    }
                }

                let headRect = CGRect(
                    x: cx - noteWidth / 2,
                    y: cy - noteHeight / 2,
                    width: noteWidth,
                    height: noteHeight
                )

                var head = Path(ellipseIn: headRect)

                let headTransform = CGAffineTransform(translationX: cx, y: cy)
                    .rotated(by: noteRotation)
                    .translatedBy(x: -cx, y: -cy)

                head = head.applying(headTransform)
                // Deep brown-gray for classical music notation appearance
                context.fill(head, with: .color(Color(red: 0.2, green: 0.18, blue: 0.16)))

                // -----------------------------
                // Stem direction and tangent point calculation
                // -----------------------------
                let stemDown = note.step > 0

                // Calculate stem attachment point at note head edge
                // Using parametric equation for rotated ellipse
                let a = noteWidth / 2  // semi-major axis (horizontal)
                let b = noteHeight / 2 // semi-minor axis (vertical)
                let theta = noteRotation

                // For vertical tangent line, solve: dx/dt = 0
                // This gives: tan(t) = -b*tan(theta)/a
                let t = atan(-b * tan(theta) / a)
                
                // Calculate point on the ellipse edge
                // When stem goes up (on right): use t
                // When stem goes down (on left): use t + π
                let tAdjusted = stemDown ? (t + .pi) : t
                
                // Point on ellipse edge
                let edgeX = cx + a * cos(tAdjusted) * cos(theta) - b * sin(tAdjusted) * sin(theta)
                let edgeY = cy + a * cos(tAdjusted) * sin(theta) + b * sin(tAdjusted) * cos(theta)
                
                // Stem starts at note head edge - more natural connection
                // Smaller offset for smoother visual flow
                let offset: CGFloat = noteHeight * 0.02  // Minimal offset for natural connection
                let stemStartX = edgeX
                let stemStartY = stemDown ? (edgeY + offset) : (edgeY - offset)

                // Stem length: standard 3.5 staff spaces
                let stemLength = lineSpacing * 3.5
                let stemEndY = stemDown ? (stemStartY + stemLength) : (stemStartY - stemLength)

                var stem = Path()
                stem.move(to: CGPoint(x: stemStartX, y: stemStartY))
                stem.addLine(to: CGPoint(x: stemStartX, y: stemEndY))
                
                // Stem width: thicker for warmer, less engineering-like appearance
                let stemWidth = staffLineWidth * 1.25
                // Deep brown-gray matching note head
                context.stroke(stem, with: .color(Color(red: 0.2, green: 0.18, blue: 0.16)), lineWidth: stemWidth)

                // -----------------------------
                // Optional note name
                // -----------------------------
                if showName {
                    let nameY = stemDown ? (cy - base * 0.30) : (cy + base * 0.30)
                    context.draw(
                        Text(note.name)
                            .font(.system(size: base * 0.16, weight: .semibold))
                            .foregroundStyle(.primary.opacity(0.85)),
                        at: CGPoint(x: cx, y: nameY)
                    )
                }
            }
        }
        .aspectRatio(compact ? (200/280) : (300/280), contentMode: .fit)
    }
}
