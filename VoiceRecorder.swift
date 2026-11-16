import Foundation
import AVFoundation

final class VoiceRecorder {
    private var recorder: AVAudioRecorder?

    private var folder: URL {
        let d = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let f = d.appendingPathComponent("Recordings", isDirectory: true)
        try? FileManager.default.createDirectory(at: f, withIntermediateDirectories: true)
        return f
    }

    func start() throws {
        let s = AVAudioSession.sharedInstance()
        try s.setCategory(.playAndRecord, mode: .default)
        try s.setActive(true)

        let file = folder.appendingPathComponent("JARVIS-\(Int(Date().timeIntervalSince1970)).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        recorder = try AVAudioRecorder(url: file, settings: settings)
        recorder?.prepareToRecord()
        recorder?.record()
    }

    func stop() {
        recorder?.stop()
        recorder = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
