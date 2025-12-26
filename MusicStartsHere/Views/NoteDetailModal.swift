//
//  NoteDetailModal.swift
//  MusicStartsHere
//
//  Created by Di on 12/15/25.
//

import SwiftUI

struct NoteDetailModal: View {
    let note: NoteData
    let progress: UserProgress
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        let isTreble = note.clef == .treble
        let themeColor: Color = isTreble ? Constants.TREBLE_THEME_COLOR : Constants.BASS_THEME_COLOR
        
        GeometryReader { _ in
            VStack(spacing: 0) {
                // Header with back button - title centered to screen
                ZStack {
                    Color(hex: 0x191919)
                        .ignoresSafeArea(edges: .top)
                    
                    // Back button pinned to leading
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    
                    // Title absolutely centered relative to full width
                    HStack(spacing: 4) {
                        Text(note.clef == .treble ? "𝄞" : "𝄢")
                            .font(.system(size: 18, weight: .ultraLight))
                            .foregroundColor(themeColor.opacity(0.9))
                        Text(note.solfege.lowercased())
                            .font(.system(size: 19, weight: .semibold, design: .default))
                            .kerning(0.5)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .frame(height: 40)
                
                ScrollView {
                    VStack(spacing: 12) {
                        // Staff Note Display
                        StaffNoteView(note: note, clef: note.clef, scale: 0.8)
                            .frame(maxWidth: .infinity, maxHeight: 280)
                            .padding(.top, 15)
                            .padding(.bottom, 15)
                        
                        // Note Info Card
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "music.note")
                                    .foregroundColor(themeColor)
                                Text("音符要点")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Speaker button
                                Button(action: {
                                    AudioService.playTone(frequency: note.frequency)
                                }) {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .foregroundColor(themeColor)
                                        .font(.system(size: 16))
                                        .padding(8)
                                        .background(themeColor.opacity(0.1))
                                        .clipShape(Circle())
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                InfoRow(label: "音名", value: getFullNoteName(for: note), color: themeColor)
                                InfoRow(label: "唱名", value: note.solfege.uppercased(), color: themeColor)
                                InfoRow(label: "频率", value: String(format: "%.1f Hz", note.frequency), color: themeColor)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                        .padding(.horizontal)
                        
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 60)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .navigationBarHidden(true)
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    // Right swipe to dismiss (positive translation.width)
                    if gesture.translation.width > 100 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
    }
}

func getFullNoteName(for note: NoteData) -> String {
    // Extract full note name (e.g., "C4") from note.id (e.g., "treble-C4" or "bass-C4")
    let components = note.id.split(separator: "-")
    if components.count >= 2 {
        return String(components[1])
    }
    return note.name
}

func getMemoryTip(for note: NoteData) -> String {
    let tips: [String: String] = [
        // 高音谱号 - 从下加五间到上加三线
        "treble-D3": "🕳️ 下加五间最深谷，re（瑞）在谷底响",
        "treble-E3": "🌋 下加四线岩石层，mi（咪）在地层深处",
        "treble-F3": "🗻 下加四间深山底，fa（发）从深处启程",
        "treble-G3": "🏞️ 下加三线山谷间，sol（索）在幽谷中",
        "treble-A3": "🏔️ 下加三线是山腰，la（啦）开始往上",
        "treble-B3": "🎪 下加三间近地面，si（西）在平地玩",
        "treble-C4": "🌉 中央C是彩虹桥！连接高低音谱表",
        "treble-D4": "🌺 下加一间花园美，re（瑞）在花间飞",
        "treble-E4": "🏠 第一线像地板，mi（咪）站在地板上",
        "treble-F4": "🚪 第一间第一个房间，fa（发）住在这里",
        "treble-G4": "☀️ 第二线像太阳，sol（索）闪闪发光",
        "treble-A4": "🎹 第二间是调音室，la（啦）440Hz标准音",
        "treble-B4": "🎯 第二线在正中央，si（西）最好找",
        "treble-C5": "🏰 第三间高音do，高音do（哆）住在这",
        "treble-D5": "🪜 第四线像梯子，re（瑞）往上爬",
        "treble-E5": "⭐️ 第四间住着高音，mi（咪）声音更亮",
        "treble-F5": "⛰️ 第五线像屋顶，fa（发）在山顶",
        "treble-G5": "🚀 上加一间飞出屋顶，sol（索）飞得高",
        "treble-A5": "✨ 上加一线在空中，la（啦）更响亮",
        "treble-B5": "☁️ 上加二间在云端，si（西）飘在天上",
        "treble-C6": "🎆 上加二线很高，高音do（哆）闪耀",
        "treble-D6": "🌠 上加三间在星空，re（瑞）像流星",
        "treble-E6": "🌟 上加三线最高处，mi（咪）在顶峰",
        
        // 低音谱号 - 从下加五间到上加三线 (固定唱名法)
        "bass-D1": "🌌 下加五间宇宙底，re（瑞）是最低音",
        "bass-E1": "⚫ 下加四线黑洞处，mi（咪）在暗处鸣",
        "bass-F1": "🌑 下加四间深渊处，fa（发）最低沉的音",
        "bass-G1": "🐙 下加三线黑暗处，sol（索）像深海章鱼",
        "bass-A1": "🌊 下加三线深海底，la（啦）声音低沉",
        "bass-B1": "🐋 下加三间海底深，si（西）像鲸鱼唱",
        "bass-C2": "🦑 下加二线在暗处，do（哆）在深海游",
        "bass-D2": "🐠 下加二间海底暗，re（瑞）在珊瑚间",
        "bass-E2": "🦈 下加一线海底层，mi（咪）声音深沉",
        "bass-F2": "🐡 下加一间海底探险，fa（发）在深处",
        "bass-G2": "🌊 第一线像深海，sol（索）声音低沉",
        "bass-A2": "🐟 第一间有小鱼，la（啦）游在这里",
        "bass-B2": "➡️ 第二线水平线，si（西）在这里",
        "bass-C3": "🏡 第二间是小房子，do（哆）住得舒服",
        "bass-D3": "⚓ 第三线是锚点，re（瑞）最好找",
        "bass-E3": "🎭 第三间在表演，mi（咪）在中间",
        "bass-F3": "⬆️ 第四线快到顶，fa（发）往上走",
        "bass-G3": "🎨 第四间是画室，sol（索）在创作",
        "bass-A3": "🎪 第五线是舞台，la（啦）在表演",
        "bass-B3": "🌉 上加一间快到桥了，si（西）要过桥",
        "bass-C4": "🌈 中央C是彩虹桥！连接高低音谱表",
        "bass-D4": "🎈 上加二间飞得高，re（瑞）接近高音",
        "bass-E4": "🎪 上加二线在高处，mi（咪）声音亮",
        "bass-F4": "🎯 上加三间飞更高，fa（发）快到顶",
        "bass-G4": "🚁 上加三线最高处，sol（索）在顶峰"
    ]
    
    return tips[note.id] ?? "🎵 多听多唱 \(note.solfege)，熟能生巧！"
}

struct InfoRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .leading)
            
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(color)
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}
