import AppIntents
import Foundation

struct StartJarvisRecordingIntent: AppIntent {
    static var title: LocalizedStringResource = "Start JARVIS Recording"
    static var description = IntentDescription("Starts a voice recording in JARVIS.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .jarvisStartRecording, object: nil)
        return .result()
    }
}

struct StopJarvisRecordingIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop JARVIS Recording"
    static var description = IntentDescription("Stops the current JARVIS recording.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .jarvisStopRecording, object: nil)
        return .result()
    }
}

struct JarvisShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(intent: StartJarvisRecordingIntent(),
                        phrases: ["Start recording with JARVIS", "JARVIS start a recording"],
                        shortTitle: "Start Recording", systemImageName: "record.circle"),
            AppShortcut(intent: StopJarvisRecordingIntent(),
                        phrases: ["Stop recording with JARVIS", "JARVIS stop recording"],
                        shortTitle: "Stop Recording", systemImageName: "stop.circle")
        ]
    }
}

extension Notification.Name {
    static let jarvisStartRecording = Notification.Name("jarvis.startRecording")
    static let jarvisStopRecording = Notification.Name("jarvis.stopRecording")
}
