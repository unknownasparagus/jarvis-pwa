import Foundation
import Combine

@MainActor
final class JarvisStore: ObservableObject {
    @Published var state: JarvisState = .idle
    @Published var transcript = ""
    @Published var messages: [ChatMessage] = []
    @Published var settings: JarvisSettings { didSet { persistSettings() } }

    let speech = SpeechManager()
    let recorder = VoiceRecorder()
    let ai = AIClient()
    let tools = ToolRegistry()

    init() {
        if let d = UserDefaults.standard.data(forKey: "jarvis.settings"),
           let s = try? JSONDecoder().decode(JarvisSettings.self, from: d) { settings = s }
        else { settings = JarvisSettings() }

        if let d = UserDefaults.standard.data(forKey: "jarvis.messages"),
           let m = try? JSONDecoder().decode([ChatMessage].self, from: d) { messages = m }
    }

    func activate() {
        state = .listening
        transcript = ""
        speech.startListening { [weak self] text in
            Task { @MainActor in self?.transcript = text }
        }
    }

    func stopListeningAndExecute() {
        speech.stopListening()
        let command = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !command.isEmpty else { state = .idle; return }
        Task { await execute(command) }
    }

    func execute(_ command: String) async {
        state = .thinking
        messages.append(ChatMessage(role: .user, text: command))
        persistMessages()

        if let local = await tools.handle(command: command, store: self) {
            await finish(local)
            return
        }

        guard !settings.aiEndpoint.isEmpty else {
            await finish("My AI server is not configured yet.")
            return
        }

        do {
            let response = try await ai.ask(
                endpoint: settings.aiEndpoint,
                messages: messages.suffix(20).map {
                    ["role": $0.role.rawValue, "content": $0.text]
                }
            )
            await finish(response.text)
            for action in response.actions { _ = await tools.execute(action: action, store: self) }
        } catch {
            await finish("AI connection failed: \(error.localizedDescription)")
        }
    }

    func startRecording() {
        do {
            try recorder.start()
            state = .recording
            speak("Recording started.")
        } catch {
            state = .error(error.localizedDescription)
            speak("I could not start the recording.")
        }
    }

    func stopRecording() {
        recorder.stop()
        state = .idle
        speak("Recording saved.")
    }

    func speak(_ text: String) {
        state = .speaking
        speech.speak(text, rate: settings.voiceRate, pitch: settings.voicePitch) { [weak self] in
            Task { @MainActor in
                if self?.state == .speaking { self?.state = .idle }
            }
        }
    }

    private func finish(_ text: String) async {
        messages.append(ChatMessage(role: .assistant, text: text))
        persistMessages()
        transcript = text
        speak(text)
    }

    private func persistSettings() {
        if let d = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(d, forKey: "jarvis.settings")
        }
    }

    private func persistMessages() {
        if let d = try? JSONEncoder().encode(Array(messages.suffix(100))) {
            UserDefaults.standard.set(d, forKey: "jarvis.messages")
        }
    }
}
