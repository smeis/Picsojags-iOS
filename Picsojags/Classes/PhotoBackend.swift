//
//  PhotoBackend.swift
//  Picsojags
//
//  Created by Boy van Amstel on 19/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import UIKit

protocol PhotoBackend {
    var apiKey: String { get }
    var baseURL: URL { get }
    func searchURL(keywords: String, page: Int) -> URL
}

struct PhotoBackend500px: PhotoBackend {

    fileprivate(set) var apiKey: String
    let baseURL: URL = URL(string: "https://api.500px.com/v1")!
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: Endpoints
    
    func searchURL(keywords: String, page: Int) -> URL {
        let searchURL = baseURL.appendingPathComponent("photos/search")
        return searchURL
    }
    
}
