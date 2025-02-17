//
//  Gravatar_App_ClipApp.swift
//  Gravatar App Clip
//
//  Created by Pinar Olguc on 17.02.2025.
//

import SwiftUI

@main
struct Gravatar_App_ClipApp: App {
    @State private var shouldCreateAvatar: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    guard let incomingURL = activity.webpageURL,
                          let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else { return }
                    // direct to the linked content
                    if components.path?.starts(with: "create-avatar") == true {
                        shouldCreateAvatar = true
                    }
                }
        }
    }
}
