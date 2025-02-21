import UIKit

extension UIImage {
    convenience init?(named name: String) {
        self.init(named: name, in: Bundle.module, compatibleWith: nil)
    }

    func withColorOverlay(_ color: UIColor = UIColor.black.withAlphaComponent(0.4)) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext(), self.cgImage != nil else { return nil }

        // Draw original image
        self.draw(at: .zero)

        // Apply overlay only where there's content
        context.setBlendMode(.sourceAtop) // Adjust blend mode if needed
        color.setFill()
        context.fill(CGRect(origin: .zero, size: self.size))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
