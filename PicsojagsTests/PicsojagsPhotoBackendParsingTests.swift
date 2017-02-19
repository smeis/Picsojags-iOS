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
    
    private var json: JSON!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let testBundle = Bundle(for: type(of: self))
        let fileURL = testBundle.url(forResource: "500px", withExtension: "json")
        let jsonData = try! Data(contentsOf: fileURL!)
        self.json = JSON(data: jsonData)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCanParse500pxMetaData() {
        let px = PhotoBackend500px(withAPIKey: "blah")
        let response = px.parse(fromJSON: self.json)
        let reference = PhotoBackendResponse(success: true, page: 7, pages: 1000, photos: [])
        XCTAssertTrue(response.page == reference.page)
        XCTAssertTrue(response.pages == reference.pages)
    }
    
    func testCanParse500pxPhotos() {
        let px = PhotoBackend500px(withAPIKey: "blah")
        let response = px.parse(fromJSON: self.json)
        // Create set of photos
        let photos: [Photo] = [
            Photo(lowQualityURL: URL(string: "https://drscdn.500px.org/photo/134409827/w%3D280_h%3D280/9164ee6eda03e9bc9f7d8ff4dace9d1e?v=2")!, highQualityURL: URL(string: "https://drscdn.500px.org/photo/134409827/h%3D1080_k%3D1_a%3D1/249cd5c1dbe7fd4184e337cb0c23449d")!),
            Photo(lowQualityURL: URL(string: "https://drscdn.500px.org/photo/80843747/w%3D280_h%3D280/8cdaa92d4183c29f05afe871f65c5e22?v=1")!, highQualityURL: URL(string: "https://drscdn.500px.org/photo/80843747/h%3D1080_k%3D1_a%3D1/fa0ebea3f0b6a6d01d166dbf45d6f70e")!),
            Photo(lowQualityURL: URL(string: "https://drscdn.500px.org/photo/139654091/w%3D280_h%3D280/7bf64dab5c544fc59abb7166d57e111d?v=2")!, highQualityURL: URL(string: "https://drscdn.500px.org/photo/139654091/h%3D1080_k%3D1_a%3D1/125c64717e0d0a6d68eb412852278be4")!),
            Photo(lowQualityURL: URL(string: "https://drscdn.500px.org/photo/115302493/w%3D280_h%3D280/fa09474e472a6c2efe17f4dcb2c4095d?v=1")!, highQualityURL: URL(string: "https://drscdn.500px.org/photo/115302493/h%3D1080_k%3D1_a%3D1/d02235636ebff0c1537384fd27e2fd7e")!),
            Photo(lowQualityURL: URL(string: "https://drscdn.500px.org/photo/69583011/w%3D280_h%3D280/78d45602edc58b71549af65b88993f3f?v=0")!, highQualityURL: URL(string: "https://drscdn.500px.org/photo/69583011/h%3D1080_k%3D1_a%3D1/50bac14d082174060b2b3c1925d3194a")!),
            ]
        XCTAssertTrue(response.photos.count == 5) // Mock json contains 5 photos
        for (i, photo) in response.photos.enumerated() {
            let refPhoto = photos[i]
            XCTAssertTrue(photo == refPhoto) // Compare photo to refPhoto
        }
    }
    
}
