import SwiftUI

extension Bundle {
    var isAppClip: Bool {
        return bundlePath.contains(".Clip")
    }
}
