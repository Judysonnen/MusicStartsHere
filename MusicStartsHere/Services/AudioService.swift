//
//  AudioService.swift
//  MusicStartsHere
//
//  Created by Di on 12/15/25.
//

import AVFoundation
import Foundation

class AudioService {
    private static var audioEngine: AVAudioEngine = {
        let engine = AVAudioEngine()
        return engine
    }()
    
    private static var playerNode: AVAudioPlayerNode = {
        let player = AVAudioPlayerNode()
        return player
    }()
    
    private static var isEngineSetup = false
    
    private static func setupEngineIfNeeded(format: AVAudioFormat) {
        guard !isEngineSetup else { return }
        
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
        
        do {
            try audioEngine.start()
            isEngineSetup = true
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    static func playTone(frequency: Double, duration: Double = 1.5) {
        // Configure audio session
        do {
            #if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            #endif
        } catch {
            print("Failed to configure audio session: \(error)")
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let sampleRate = 44100.0
            let samples = Int(sampleRate * duration)
            
            guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else { return }
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples)) else { return }
            
            buffer.frameLength = AVAudioFrameCount(samples)
            guard let channelData = buffer.floatChannelData else { return }
            let channel = channelData[0]
            
            // Pre-calculate constants for optimization
            let twoPiFreq = 2.0 * .pi * frequency
            let invSampleRate = 1.0 / sampleRate
            let attackTime = 0.02
            let attackSamples = Int(attackTime * sampleRate)
            let decayRate = 3.0 / duration
            
            // Generate optimized tone with simple envelope
            for i in 0..<samples {
                let t = Double(i) * invSampleRate
                
                // Simplified envelope calculation
                let envelope: Double
                if i < attackSamples {
                    envelope = Double(i) / Double(attackSamples)
                } else {
                    let normalized = (t - attackTime) / duration
                    envelope = exp(-normalized * decayRate)
                }
                
                // Single optimized sine wave with harmonic
                let fundamental = sin(twoPiFreq * t)
                let harmonic = sin(twoPiFreq * 2.0 * t) * 0.2
                
                // Simple percussive attack
                let attackEnv = i < attackSamples ? exp(-Double(i) * invSampleRate * 30.0) * 0.05 : 0.0
                
                channel[i] = Float((fundamental + harmonic) * envelope + attackEnv) * 0.75
            }
            
            DispatchQueue.main.async {
                playBuffer(buffer, format: format)
            }
        }
    }
    
    private static func generateEnvelope(time: Double, duration: Double) -> Double {
        let attack = 0.02
        let decay = duration
        
        if time < attack {
            // Linear ramp up
            return time / attack
        } else {
            // Exponential decay
            let normalized = (time - attack) / (decay - attack)
            return exp(-normalized * 3.0) // Exponential decay to 0.01
        }
    }
    
    private static func triangleWave(frequency: Double, time: Double) -> Double {
        let period = 1.0 / frequency
        let t = time.truncatingRemainder(dividingBy: period)
        let phase = t / period
        
        if phase < 0.5 {
            return 4.0 * phase - 1.0
        } else {
            return 3.0 - 4.0 * phase
        }
    }
    
    private static func squareWave(frequency: Double, time: Double) -> Double {
        let period = 1.0 / frequency
        let t = time.truncatingRemainder(dividingBy: period)
        return (t < period / 2.0) ? 1.0 : -1.0
    }
    
    private static func playBuffer(_ buffer: AVAudioPCMBuffer, format: AVAudioFormat) {
        setupEngineIfNeeded(format: format)
        
        // Stop any currently playing sound
        playerNode.stop()
        
        // Schedule and play the buffer
        playerNode.scheduleBuffer(buffer) {
            // Cleanup after playback completes
        }
        
        if !playerNode.isPlaying {
            playerNode.play()
        }
    }
}
