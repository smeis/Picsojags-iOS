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

struct PhotoBackendResponse {
    fileprivate(set) var success: Bool
    fileprivate(set) var page: Int
    fileprivate(set) var pages: Int
    fileprivate(set) var photos: [Photo]
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
        let parameters = ["term=\(escapedKeywords)", "page=\(page)", "consumer_key=\(self.apiKey)"]
        let parameterString = parameters.joined(separator: "&")
        return URL(string: "\(searchURL.absoluteString)?\(parameterString)")
    }
    
    // MARK: - parameterString
    
    func parse(fromJSON json: JSON) -> PhotoBackendResponse {
        return PhotoBackendResponse(success: true, page: 1, pages: 100, photos: [])
    }
    
}
