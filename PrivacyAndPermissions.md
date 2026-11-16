# Permissions

Add these Info.plist keys:

NSMicrophoneUsageDescription = JARVIS uses the microphone for voice commands and voice recordings.
NSSpeechRecognitionUsageDescription = JARVIS uses speech recognition to understand your commands.

JARVIS starts microphone sessions only after explicit user activation or a Shortcut/App Intent. iOS does not permit a normal third-party app to bypass Apple's privacy/background rules or gain unrestricted system control.
