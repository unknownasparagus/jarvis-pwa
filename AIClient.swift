import Foundation

struct AIResponse: Codable {
    let text: String
    let actions: [AIAction]
}

struct AIAction: Codable {
    let name: String
    let arguments: [String: String]
}

final class AIClient {
    func ask(endpoint: String, messages: [[String: String]]) async throws -> AIResponse {
        guard let url = URL(string: endpoint) else { throw URLError(.badURL) }
        var r = URLRequest(url: url)
        r.httpMethod = "POST"
        r.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "messages": messages,
            "system": "You are JARVIS, a concise personal iPhone assistant. Return JSON with text and actions. Never claim an action succeeded unless the app executes it."
        ]
        r.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: r)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode)
        else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(AIResponse.self, from: data)
    }
}
