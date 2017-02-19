//
//  PhotoBackend.swift
//  Picsojags
//
//  Created by Boy van Amstel on 19/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import UIKit

protocol PhotoBackend {
    var identifier: String { get }
    var baseURL: URL { get }
    var apiKey: String { get }
}

struct PhotoBackend500px: PhotoBackend {

    let identifier = "500px"
    fileprivate(set) var apiKey: String
    let baseURL: URL = URL(string: "https://api.500px.com/v1")!
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
}
