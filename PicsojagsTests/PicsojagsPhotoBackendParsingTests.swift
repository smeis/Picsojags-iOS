//
//  PicsojagsPhotoBackendParsingTests.swift
//  Picsojags
//
//  Created by Boy van Amstel on 19/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import XCTest
import SwiftyJSON

class PicsojagsPhotoBackendParsingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCanParse500pxMetaData() {
        let testBundle = Bundle(for: type(of: self))
        let fileURL = testBundle.url(forResource: "500px", withExtension: "json")
        let jsonData = try! Data(contentsOf: fileURL!)
        let json = JSON(jsonData)
        
        let px = PhotoBackend500px(withAPIKey: "blah")
        let response = px.parse(fromJSON: json)
        let reference = PhotoBackendResponse(success: true, page: 7, pages: 1000, photos: [])
        XCTAssertTrue(response.page == reference.page)
        XCTAssertTrue(response.pages == reference.pages)
    }
    
    func testCanParse500pxPhotos() {
        let testBundle = Bundle(for: type(of: self))
        let fileURL = testBundle.url(forResource: "500px", withExtension: "json")
        let jsonData = try! Data(contentsOf: fileURL!)
        let json = JSON(jsonData)
        
        let px = PhotoBackend500px(withAPIKey: "blah")
        let response = px.parse(fromJSON: json)
        // Create set of photos
        let photos: [Photo] = []
        for (i, photo) in response.photos.enumerated() {
            // Compare photos
            let refPhoto = photos[i]
            XCTAssertTrue(false) // Compare photo to refPhoto
        }
    }
    
}
