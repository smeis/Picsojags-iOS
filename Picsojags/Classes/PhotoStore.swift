//
//  PhotoStore.swift
//  Picsojags
//
//  Created by Boy van Amstel on 19/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import UIKit
import SwiftyJSON

/// The photo store talks to the backend and returns retrieved images.
class PhotoStore {

    /// The backend to use.
    private var backend: PhotoBackend! // Set in init
    /// The standard URL session. Might contain authentication data set by the backend.
    private var urlSession: URLSession! // Set in init
    
    /// Initialize with a backend.
    ///
    /// - Parameter backend: The backend to use.
    init(backend: PhotoBackend) {
        self.backend = backend
        // Set default config
        self.urlSession = URLSession(configuration: self.backend.urlSessionConfiguration)
    }
    
    // MARK: - Making API calls
    
    /// Fire a photo fetch request at the photo service.
    ///
    /// - Parameters:
    ///   - page: The page to fetch.
    ///   - complete: Fires when the request completes successfully, or fails.
    func fetchPhotos(page: Int, complete: @escaping (_ response: PhotoBackendResponse) -> ()) {
        
        if let searchURL = self.backend.searchURL(forKeywords: "jaguar car", page: page) {
            // Create data task and run it
            self.urlSession.dataTask(with: searchURL) { (data, response, error) in
                
                // Return early if response is empty
                if response == nil || error != nil {
                    let response = PhotoBackendResponse(success: false, page: 0, pages: 0, photos: [])
                    OperationQueue.main.addOperation({ // Allow UI updates
                        complete(response)
                    })
                    return
                }
                
                // Cast response to http response so we can use it as such
                let httpResponse = response as! HTTPURLResponse
                
                // Determine course of action based on status code
                switch httpResponse.statusCode {
                case 200:
                    if let jsonData = data {
                        let json = JSON(data: jsonData)
                        
                        // Parse JSON
                        let response = self.backend.parse(fromJSON: json)
                        OperationQueue.main.addOperation({ // Allow UI updates
                            complete(response)
                        })
                    }
                default:
                    // TODO: Handle error
                    break
                }
            }.resume() // Execute task
        } else {
            // TODO: Handle error
        }
        
    }
    
}
