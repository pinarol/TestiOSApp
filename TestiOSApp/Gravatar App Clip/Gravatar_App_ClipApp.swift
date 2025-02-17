//
//  Gravatar_App_ClipApp.swift
//  Gravatar App Clip
//
//  Created by Pinar Olguc on 17.02.2025.
//

import SwiftUI

@main
struct Gravatar_App_ClipApp: App {
    @StateObject private var model: Model = .init()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { activity in
                    guard let incomingURL = activity.webpageURL,
                          let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else { return }
                    // direct to the linked content
                    if components.path?.starts(with: "/iosdemo/create-avatar") == true {
                        model.email = components.queryItems?.first(where: { $0.name == "email" })?.value
                    }
                }
        }
    }
}

class Model: ObservableObject {
    @Published var email: String?
    init(email: String? = nil) {
        self.email = email
    }
}
