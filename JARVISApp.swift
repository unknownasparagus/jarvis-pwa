import SwiftUI

@main
struct JARVISApp: App {
    @StateObject private var store = JarvisStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
