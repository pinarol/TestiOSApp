//
//  ContentView.swift
//  TestiOSApp
//
//  Created by Pinar Olguc on 16.02.2025.
//

import SwiftUI
import CanvasEditor

enum NavigationElement: Hashable {
    case imageResult(image: UIImage)
}

struct ContentView: View {
   // @State private var selectedImage: UIImage?
    @State private var path: [NavigationElement] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            CanvasEditorView(inputImage: nil) { image in
                //selectedImage = image
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
        }
    }
    
    @ViewBuilder
    func imageResultView(image: UIImage) -> some View {
        ImageResultView(image: image)
    }
}

#Preview {
    ContentView()
}
