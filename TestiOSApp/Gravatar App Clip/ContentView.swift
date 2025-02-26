//
//  ContentView.swift
//  Gravatar App Clip
//
//  Created by Pinar Olguc on 17.02.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: Model

    var body: some View {
        CanvasEditorViewWrapper()
    }
}

#Preview {
    ContentView()
        .environmentObject(Model(email: "pinar@example.com"))
}
