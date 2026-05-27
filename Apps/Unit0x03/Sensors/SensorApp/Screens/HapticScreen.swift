// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CoreHaptics
import CblUI

struct HapticScreen: View {
    
    var body: some View {
        CblScreen(title: "Haptic", image: "haptic") {
            VStack(spacing: 5) {
                Spacer()
                Button("Softy") {
                    HapticManager.shared.playHaptic(intensity: 0.3, sharpness: 0.3)
                }.padding(15)
                    .buttonStyle(ScreenButtonStyle())
                Button("Nudge") {
                    HapticManager.shared.playHaptic(intensity: 0.6, sharpness: 0.3)
                }.padding(15)
                    .buttonStyle(ScreenButtonStyle())
                Button("Kick") {
                    HapticManager.shared.playHaptic(intensity: 1.0, sharpness: 1.0)
                }.padding(15)
                    .buttonStyle(ScreenButtonStyle())
                Spacer()
            }
        }
    }
}

class HapticManager {
    static let shared = HapticManager()
    
    private var engine: CHHapticEngine?
    
    private init() {
        prepareHaptics()
    }
    
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            self.engine = try CHHapticEngine()

            // The engine can stop due to interruptions (phone call, Siri, alarm, etc.).
            // stoppedHandler lets us know it happened; resetHandler lets us restart it.
            engine?.stoppedHandler = { reason in
                print("Haptic engine stopped: \(reason)")
            }
            engine?.resetHandler = { [weak self] in
                do {
                    try self?.engine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error.localizedDescription)")
                }
            }

            try engine?.start()
        } catch {
            print("There was an error creating the haptic engine: \(error.localizedDescription)")
        }
    }
    
    func playHaptic(intensity: Float, sharpness: Float) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        events.append(event)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}

/*
  - Intensity (CHHapticEventParameterID.hapticIntensity):
    Definition: Intensity controls the strength or amplitude 
    of the haptic feedback.
      * Range: The value ranges from 0.0 (minimum intensity) to 
        1.0 (maximum intensity).
      * Effect: A higher intensity value results in a stronger, 
        more forceful haptic feedback, while a lower value results
        in a softer, more subtle feedback.
  - Sharpness (CHHapticEventParameterID.hapticSharpness):
    Definition: Sharpness controls the frequency content of the 
    haptic feedback, affecting how “sharp” or “crisp” the sensation feels.
      * Range: The value ranges from 0.0 (minimum sharpness) to 
        1.0 (maximum sharpness).
      * Effect: A higher sharpness value results in a more precise,
        defined, and crisp haptic sensation, while a lower value results
        in a more dull, broad, and soft sensation.
 */

