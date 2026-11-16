import Foundation
import UIKit

@MainActor
final class ToolRegistry {
    func handle(command: String, store: JarvisStore) async -> String? {
        let c = command.lowercased()

        if c.contains("start recording") ||
           c.contains("begin recording") ||
           c.contains(store.settings.codePhrase.lowercased()) {
            store.startRecording()
            return "Recording started."
        }

        if c.contains("stop recording") {
            store.stopRecording()
            return "Recording stopped and saved."
        }

        if c.contains("battery") {
            UIDevice.current.isBatteryMonitoringEnabled = true
            let level = Int(UIDevice.current.batteryLevel * 100)
            return "Your iPhone battery is at \(max(0, level)) percent."
        }

        if c.contains("open settings") {
            if let u = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(u)
                return "Opening Settings."
            }
        }

        if c.contains("open shortcuts") {
            if let u = URL(string: "shortcuts://") {
                UIApplication.shared.open(u)
                return "Opening Shortcuts."
            }
        }

        return nil
    }

    func execute(action: AIAction, store: JarvisStore) async -> Bool {
        switch action.name {
        case "start_recording":
            store.startRecording(); return true
        case "stop_recording":
            store.stopRecording(); return true
        default:
            return false
        }
    }
}
