//
//  PicsojagsPhotoBackendTests.swift
//  Picsojags
//
//  Created by Boy van Amstel on 19/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import XCTest

class PicsojagsPhotoBackendTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test500pxURLContainsAPIKey() {
        let apiKey = "API_KEY"
        let px = PhotoBackend500px(withAPIKey: apiKey)
        guard let searchURL = px.searchURL(forKeywords: "test", page: 0) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertTrue(searchURL.absoluteString.contains("consumer_key=\(apiKey)"))
    }
    
    func test500pxURLEscapesKeywords() {
        let apiKey = "API_KEY"
        let px = PhotoBackend500px(withAPIKey: apiKey)
        guard let searchURL = px.searchURL(forKeywords: "testing?spaces=blah&yo=hello! spaces", page: 0) else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertTrue(searchURL.absoluteString.contains("testing%3Fspaces%3Dblah%26yo%3Dhello%21%20spaces"))
    }
    
}
