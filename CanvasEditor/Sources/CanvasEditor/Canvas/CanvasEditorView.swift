import SwiftUI
import UIKit

public struct CanvasEditorView: UIViewControllerRepresentable {
    let inputImage: UIImage?
    let onCompletion: ((UIImage) -> Void)?
    let onCancel: (() -> Void)?

    public init(
        inputImage: UIImage? = nil,
        onCompletion: ((UIImage) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self.inputImage = inputImage
        self.onCompletion = onCompletion
        self.onCancel = onCancel
    }

    public func makeUIViewController(context: Context) -> CanvasViewController {
        let viewController = CanvasViewController(inputImage: inputImage, onCompletion: onCompletion, onCancel: onCancel)
        return viewController
    }

    public func updateUIViewController(_ uiViewController: CanvasViewController, context: Context) {
        // If you need to update the view controller when SwiftUI state changes,
        // do it here.
    }

    // Optional: Coordinator for communication
    // (only needed if you want to send data back to SwiftUI)
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject {
        var parent: CanvasEditorView
        
        init(_ parent: CanvasEditorView) {
            self.parent = parent
        }
        
        // Put additional communication logic here if needed
    }
}
