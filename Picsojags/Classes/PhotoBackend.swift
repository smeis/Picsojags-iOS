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

// MARK: - Backend protocol

/// The photo backend protocol is used by the photo store to make calls to the backend.
protocol PhotoBackend {
    var apiKey: String { get }
    var baseURL: URL { get }
    var urlSessionConfiguration: URLSessionConfiguration { get } // Allow for special configurations, usually auth related
    init(withAPIKey apiKey: String)
    func searchURL(forKeywords keywords: String, page: Int) -> URL?
    func parse(fromJSON json: JSON) -> PhotoBackendResponse
}


/// The standardized response from a photo service.
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

/// The 500px backend.
struct PhotoBackend500px: PhotoBackend {

    /// The API key used by the backend.
    fileprivate(set) var apiKey: String
    /// The base URL used for generating other URLs.
    let baseURL: URL = URL(string: "https://api.500px.com/v1")!
    
    /// Initialize a backend with an API key.
    ///
    /// - Parameter apiKey: The API key to use.
    init(withAPIKey apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - URL Session configuration
   
    /// Returns a customized url session config, often used for authentication.
    var urlSessionConfiguration: URLSessionConfiguration {
        return URLSessionConfiguration.default // No special configuration, consumer key is set in URL
    }
    
    // MARK: - Endpoints
    
    /// Creates a URL that fires a search request at the photo service.
    ///
    /// - Parameters:
    ///   - keywords: The keywords to search for. Escaped automatically.
    ///   - page: The page to fetch.
    /// - Returns: Returns a URL or nil.
    func searchURL(forKeywords keywords: String, page: Int = 1) -> URL? {
        
        // Escape keywords
        let escapedKeywords = keywords.RFC3986UnreservedEncoded

        // Compose URL, maybe use NSURLComponents
        let searchURL = self.baseURL.appendingPathComponent("photos/search")
        let parameters = ["term=\(escapedKeywords)", "page=\(page)", "consumer_key=\(self.apiKey)", "image_size=3,6", "rpp=20"]
        let parameterString = parameters.joined(separator: "&")
        return URL(string: "\(searchURL.absoluteString)?\(parameterString)")
    }
    
    // MARK: - Parsing
    
    /// Parse a response from the photo service.
    ///
    /// - Parameter json: The JSON response from the photo service.
    /// - Returns: A standardized response to be used in the UI.
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
                let parsedPhoto = Photo(squaredPhotoURL: smallURL, fullPhotoURL: largeURL)
                parsedPhotos.append(parsedPhoto)
            }
        }
        return PhotoBackendResponse(success: true, page: page, pages: pages, photos: parsedPhotos)
    }
    
}
