//
//  PhotoBackend.swift
//  Picsojags
//
//  Created by Boy van Amstel on 19/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import UIKit
import SwiftyJSON

// MARK: - String extension for parameter escaping

extension String {
    
    var RFC3986UnreservedEncoded:String {
        let unreservedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
        let unreservedCharsSet: CharacterSet = CharacterSet(charactersIn: unreservedChars)
        let encodedString: String = self.addingPercentEncoding(withAllowedCharacters: unreservedCharsSet)!
        return encodedString
    }
}

// MARK: - Protocol and struct

protocol PhotoBackend {
    var apiKey: String { get }
    var baseURL: URL { get }
    var urlSessionConfiguration: URLSessionConfiguration { get } // Allow for special configurations, usually auth related
    init(withAPIKey apiKey: String)
    func searchURL(forKeywords keywords: String, page: Int) -> URL?
    func parse(fromJSON json: JSON) -> PhotoBackendResponse
}

struct PhotoBackendResponse: Equatable {
    fileprivate(set) var success: Bool
    fileprivate(set) var page: Int
    fileprivate(set) var pages: Int
    fileprivate(set) var photos: [Photo]
}


func ==(lhs: PhotoBackendResponse, rhs: PhotoBackendResponse) -> Bool {
    if lhs.success != rhs.success { return false }
    if lhs.page != rhs.page { return false }
    if lhs.pages != rhs.pages { return false }
    if lhs.photos.count != rhs.photos.count { return false }
    // Somes down to comparing photos
    var match = true
    for (i, lPhoto) in lhs.photos.enumerated() {
        let rPhoto = rhs.photos[i]
        if lPhoto != rPhoto {
            match = false
            break
        }
    }
    return match
}

// MARK: - Backends

struct PhotoBackend500px: PhotoBackend {

    fileprivate(set) var apiKey: String
    let baseURL: URL = URL(string: "https://api.500px.com/v1")!
    
    init(withAPIKey apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - URL Session configuration
    
    var urlSessionConfiguration: URLSessionConfiguration {
        return URLSessionConfiguration.default // No special configuration, consumer key is set in URL
    }
    
    // MARK: - Endpoints
    
    func searchURL(forKeywords keywords: String, page: Int = 1) -> URL? {
        
        // Escape keywords
        let escapedKeywords = keywords.RFC3986UnreservedEncoded

        // Compose URL, maybe use NSURLComponents
        let searchURL = self.baseURL.appendingPathComponent("photos/search")
        let parameters = ["term=\(escapedKeywords)", "page=\(page)", "consumer_key=\(self.apiKey)", "image_size=3,6"]
        let parameterString = parameters.joined(separator: "&")
        return URL(string: "\(searchURL.absoluteString)?\(parameterString)")
    }
    
    // MARK: - parameterString
    
    func parse(fromJSON json: JSON) -> PhotoBackendResponse {
        let page = json["current_page"].intValue
        let pages = json["total_pages"].intValue
        let photos = json["photos"].arrayValue
        var parsedPhotos: [Photo] = []
        for photo in photos {
            let images = photo["images"].arrayValue
            let small = images.first(where: { $0["size"] == 3 }) // Get thumbnail (280 x 280)
            let large = images.first(where: { $0["size"] == 6 }) // Get larger size 1080p
           
            // Skip if small or large aren't available
            guard let smallJSON = small, let largeJSON = large else {
                break
            }
            // Create photo
            if let smallURL = URL(string: smallJSON["https_url"].stringValue), let largeURL = URL(string: largeJSON["https_url"].stringValue) {
                let parsedPhoto = Photo(lowQualityURL: smallURL, highQualityURL: largeURL)
                parsedPhotos.append(parsedPhoto)
            }
        }
        return PhotoBackendResponse(success: true, page: page, pages: pages, photos: parsedPhotos)
    }
    
}
