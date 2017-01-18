//
//  Log.swift
//  BLEStudy
//
//  Created by Wade.Chen on 2016/7/11.
//  Copyright © 2016年 Facebook. All rights reserved.
//

import Foundation

let formatter = DateFormatter()

extension String {

    //put string return index --> ex: "Hello".[e]  --> 1
    subscript(str: String) -> Int{
        let range: Range<String.Index> = self.range(of: str)!
        return characters.distance(from: startIndex, to: range.lowerBound)
    }

    //index to index --> ex: "Hello".[0..<2] --> he
    func trim (_ from: Int, _ to: Int) -> String {
        let range = NSMakeRange(from, to)
        return (self as NSString).substring(with: range)
    }
}

class Log {

    private enum T {
        case DEBUG, INFO, WRAN
    }

    private class func getThreadInfo() -> String {
        let isMain = Thread.current.isMainThread
        let tStr = Thread.current.description
        let filter1  = "number = "
        let filter2 = ","
        let indexStart = tStr[filter1] + filter1.characters.count
        let indexEnd = tStr[filter2] - indexStart
        let id = tStr.trim(indexStart, indexEnd)

        return isMain ? "main (\(id))": "thread (\(id))"
    }

    class func d(_ description: String, lineNumber: Int = #line, file: String = #file) {
        NSLog("\(getThreadInfo()) [\(T.DEBUG)] >> [\((file as NSString).lastPathComponent) : \(lineNumber)] \(description)")
    }


    class func i(_ description: String, lineNumber: Int = #line, file: String = #file) {
        print("\(getThreadInfo()) [\(T.INFO)] >> [\((file as NSString).lastPathComponent) : \(lineNumber)] \(description)")
    }

    class func w(_ description: String, lineNumber: Int = #line, file: String = #file) {
        print("\(getThreadInfo()) [\(T.WRAN)] >> [\((file as NSString).lastPathComponent) : \(lineNumber)] \(description)")
    }
    
    
}
