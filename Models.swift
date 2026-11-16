import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let role: Role
    let text: String
    let date: Date
    enum Role: String, Codable { case user, assistant, system }
    init(role: Role, text: String) {
        id = UUID(); self.role = role; self.text = text; date = Date()
    }
}

struct JarvisSettings: Codable {
    var activationName = "JARVIS"
    var codePhrase = "BLACKBIRD"
    var aiEndpoint = ""
    var voiceRate: Float = 0.47
    var voicePitch: Float = 1.0
}

enum JarvisState: Equatable {
    case idle, listening, thinking, speaking, recording
    case error(String)
    var label: String {
        switch self {
        case .idle: "STANDBY"
        case .listening: "LISTENING"
        case .thinking: "PROCESSING"
        case .speaking: "SPEAKING"
        case .recording: "RECORDING"
        case .error: "ERROR"
        }
    }
}
