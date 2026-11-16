import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: JarvisStore
    @State private var settingsShown = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 22) {
                    Spacer()
                    JarvisCore(state: store.state)
                    Text(store.state.label)
                        .font(.system(.caption, design: .monospaced))
                        .tracking(4)
                        .foregroundStyle(.cyan)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(store.messages.suffix(8)) { m in
                                HStack {
                                    if m.role == .assistant { Spacer(minLength: 30) }
                                    Text(m.text)
                                        .font(.system(.body, design: .monospaced))
                                        .foregroundStyle(m.role == .assistant ? .white : .cyan)
                                        .padding(12)
                                        .background(.white.opacity(0.06))
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                    if m.role == .user { Spacer(minLength: 30) }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    if !store.transcript.isEmpty {
                        Text(store.transcript)
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }

                    HStack(spacing: 18) {
                        Button {
                            store.state == .listening ? store.stopListeningAndExecute() : store.activate()
                        } label: {
                            Image(systemName: store.state == .listening ? "stop.fill" : "mic.fill")
                                .font(.system(size: 24, weight: .bold))
                                .frame(width: 68, height: 68)
                                .background(.cyan.opacity(0.15))
                                .overlay(Circle().stroke(.cyan.opacity(0.8), lineWidth: 1))
                                .clipShape(Circle())
                        }

                        Button {
                            store.state == .recording ? store.stopRecording() : store.startRecording()
                        } label: {
                            Image(systemName: store.state == .recording ? "stop.circle.fill" : "waveform")
                                .font(.system(size: 22, weight: .bold))
                                .frame(width: 58, height: 58)
                                .background(.red.opacity(0.12))
                                .overlay(Circle().stroke(.red.opacity(0.7), lineWidth: 1))
                                .clipShape(Circle())
                        }
                    }
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { settingsShown = true } label: { Image(systemName: "gearshape") }
                }
            }
            .sheet(isPresented: $settingsShown) {
                SettingsView().environmentObject(store)
            }
        }
    }
}

struct JarvisCore: View {
    let state: JarvisState
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle().stroke(.cyan.opacity(0.15), lineWidth: 18)
                .frame(width: 220, height: 220)
                .scaleEffect(pulse ? 1.08 : 0.94)
            Circle().stroke(.cyan.opacity(0.35), lineWidth: 3)
                .frame(width: 180, height: 180)
            Circle().fill(.cyan.opacity(0.06))
                .frame(width: 135, height: 135)

            VStack(spacing: 4) {
                Text("JARVIS")
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .tracking(5)
                Text("ONLINE")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(3)
                    .foregroundStyle(.cyan)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var store: JarvisStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Activation") {
                    TextField("Activation name", text: $store.settings.activationName)
                    TextField("Code phrase", text: $store.settings.codePhrase)
                        .textInputAutocapitalization(.characters)
                }
                Section("AI") {
                    TextField("HTTPS AI server endpoint", text: $store.settings.aiEndpoint)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                Section("Voice") {
                    Slider(value: Binding(
                        get: { Double(store.settings.voiceRate) },
                        set: { store.settings.voiceRate = Float($0) }
                    ), in: 0.35...0.6)
                    Slider(value: Binding(
                        get: { Double(store.settings.voicePitch) },
                        set: { store.settings.voicePitch = Float($0) }
                    ), in: 0.8...1.2)
                }
            }
            .navigationTitle("JARVIS Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
