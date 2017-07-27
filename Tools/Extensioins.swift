import Foundation

extension NSObject {
    var className: String {
        return String(describing: NSObject.self)
    }
}

extension Data {
    func toBytes() -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: self.count)
        (self as NSData).getBytes(&bytes, length: self.count)
        return bytes
    }
}

extension Array {
    func containSameElements<T: Comparable>(_ array1: [T], _ array2: [T]) -> Bool {
        guard array1.count == array2.count else {
            return false // No need to sorting if they already have different counts
        }

        return array1.sorted() == array2.sorted()
    }
}
