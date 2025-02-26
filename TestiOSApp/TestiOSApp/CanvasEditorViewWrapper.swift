//
//  CanvasEditorViewWrapper.swift
//  Gravatar Test
//
//  Created by Pinar Olguc on 26.02.2025.
//

import SwiftUI
import CanvasEditor
import Gravatar

enum NavigationElement: Hashable {
    case imageResult(image: UIImage)
}

struct CanvasEditorViewWrapper: View {
     @State private var path: [NavigationElement] = []

    var body: some View {
        NavigationStack(path: $path) {
            CanvasEditorView(inputImage: nil) { image in
                path.append(.imageResult(image: image))
            } onCancel: {
                
            }
            .background(Color.black)
            .statusBarHidden(true)
            .ignoresSafeArea(.all)
            .navigationDestination(for: NavigationElement.self) { dest in
                switch dest {
                case .imageResult(let image):
                    imageResultView(image: image)
                }
            }
            .onAppear() {
                Task {
                    await Configuration.shared.configure(
                        with: Secrets.apiKey,
                        oauthSecrets: .init(
                            clientID: Secrets.clientID,
                            redirectURI: Secrets.redirectURI
                        )
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    func imageResultView(image: UIImage) -> some View {
        ImageResultView(image: image)
            .colorScheme(.dark)
    }
}

#Preview {
    CanvasEditorViewWrapper()
}
