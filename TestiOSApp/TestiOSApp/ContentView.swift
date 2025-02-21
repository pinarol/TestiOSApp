//
//  ContentView.swift
//  TestiOSApp
//
//  Created by Pinar Olguc on 16.02.2025.
//

import SwiftUI
import CanvasEditor

struct ContentView: View {
    @State private var selectedImage: UIImage?
    var body: some View {
        //VStack {
            CanvasEditorView(inputImage: nil) { image in
                selectedImage = image
            } onCancel: {
                
            }
            .background(Color.black)
            .statusBarHidden(true)
            .ignoresSafeArea(.all)
        //}
        //.padding()
    }
}

#Preview {
    ContentView()
}
