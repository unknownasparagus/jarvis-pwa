# JARVIS iPhone Assistant

A SwiftUI iOS project source set for a personal JARVIS-style assistant.

## Included
- Futuristic custom HUD
- Speech recognition
- Spoken responses
- Explicit voice recording
- Configurable activation name and code phrase
- Local command router
- App Intents / Shortcuts actions
- AI provider abstraction using a secure HTTPS endpoint
- Persistent settings and conversation memory

## Build
1. Create a new Xcode iOS App using SwiftUI/Swift.
2. Copy the files from `JARVISApp` into the project.
3. Set deployment target to iOS 18+.
4. Add microphone and speech-recognition usage descriptions to Info.plist.
5. Run on a real iPhone.
6. Set the AI server URL in JARVIS Settings.

## Important
A third-party iOS app cannot bypass Apple's permission/background restrictions or obtain unrestricted control of the phone. The app therefore uses explicit listening sessions and App Intents/Shortcuts for actions exposed by iOS.

Never put an AI provider secret directly in the iPhone app. Keep it on your server.

## Recording
The code phrase can trigger an explicit recording workflow. iOS microphone permission and indicators remain active, and recordings are saved inside the app's Documents/Recordings folder.
