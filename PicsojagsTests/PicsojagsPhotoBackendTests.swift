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
    
    func test500PXURLContainsAPIKey() {
        let apiKey = "API_KEY"
        let px = PhotoBackend500px(apiKey: apiKey)
        XCTAssertTrue(px.searchURL(keywords: "test", page: 0).path.contains(apiKey))
    }
    
}
