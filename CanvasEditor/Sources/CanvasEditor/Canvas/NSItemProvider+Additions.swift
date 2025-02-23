import UIKit

extension NSItemProvider {
    func loadUIImage() async -> UIImage {
        await withCheckedContinuation { continuation in
            loadObject(ofClass: UIImage.self) { itemReading, _ in
                guard let image = itemReading as? UIImage else {
                    return
                }

                continuation.resume(returning: image)
            }
        }
    }
}
