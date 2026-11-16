import Foundation
import AVFoundation
import Speech

final class SpeechManager: NSObject {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-NZ"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let synthesizer = AVSpeechSynthesizer()

    func startListening(update: @escaping (String) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else { return }
            AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                guard allowed else { return }
                DispatchQueue.main.async { self.begin(update: update) }
            }
        }
    }

    private func begin(update: @escaping (String) -> Void) {
        task?.cancel()
        request = SFSpeechAudioBufferRecognitionRequest()
        let input = audioEngine.inputNode
        input.removeTap(onBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024,
                         format: input.outputFormat(forBus: 0)) { buffer, _ in
            self.request?.append(buffer)
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            audioEngine.prepare()
            try audioEngine.start()

            task = recognizer?.recognitionTask(with: request!) { result, error in
                if let result { update(result.bestTranscription.formattedString) }
                if error != nil { self.stopListening() }
            }
        } catch {
            stopListening()
        }
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        task = nil
        request = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func speak(_ text: String, rate: Float, pitch: Float, completion: @escaping () -> Void) {
        let u = AVSpeechUtterance(string: text)
        u.rate = rate
        u.pitchMultiplier = pitch
        u.voice = AVSpeechSynthesisVoice(language: "en-NZ")
        synthesizer.speak(u)
        DispatchQueue.main.asyncAfter(deadline: .now() + max(1, Double(text.count) * 0.035)) {
            completion()
        }
    }
}
