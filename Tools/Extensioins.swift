import Foundation

extension NSObject {
    var className: String {
        return String(describing: NSObject.self)
    }
}
