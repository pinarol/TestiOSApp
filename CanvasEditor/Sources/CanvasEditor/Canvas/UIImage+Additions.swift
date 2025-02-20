import UIKit

extension UIImage {
    convenience init?(named name: String) {
        self.init(named: name, in: Bundle.module, compatibleWith: nil)
    }
}
