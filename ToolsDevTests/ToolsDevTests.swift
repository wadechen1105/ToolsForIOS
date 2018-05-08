//
//  ToolsDevTests.swift
//  ToolsDevTests
//
//  Created by Wade H-C Chen on 2018/5/7.
//  Copyright © 2018年 wade.wade. All rights reserved.
//

import XCTest
@testable import Tools_dev

class ToolsDevTests: XCTestCase {
    var dlClient: DownloadTask!
    let session = MockURLSession()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dlClient = DownloadTask(session)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetURL() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let request = URLRequest(url: URL(string: "https://mockurl")!)
        
        let mockTask = dlClient.getSession().download(with: request) as! MockURLSessionDataTask
        
        guard let url = URL(string: "https://mockurl") else {
            fatalError("URL can't be empty")
        }
        
        XCTAssert(mockTask.request.url == url)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

class MockURLSession: URLSessionDownloadProtocol {
    private (set) var lastURL: URL?
    
    func download(with request: URLRequest) -> DataTaskProtocol {
        lastURL = request.url
        return MockURLSessionDataTask(request: request)
    }
    
}

class MockURLSessionDataTask: DataTaskProtocol {
    var request: URLRequest!
    
    init(request: URLRequest) {
        self.request = request
    }
    
    func resume() {
        Log.d("run url : \(String(describing: request.url)) !!!!")
    }
}
