//
//  PhotoStore.swift
//  Picsojags
//
//  Created by Boy van Amstel on 19/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import UIKit
import SwiftyJSON

class PhotoStore {

    private var backend: PhotoBackend! // Set in init
    private var urlSession: URLSession! // Set in init
    
    init(backend: PhotoBackend) {
        self.backend = backend
        self.urlSession = URLSession(configuration: self.backend.urlSessionConfiguration)
    }
    
    // MARK: - Making API calls
    
    func fetchPhotos(page: Int, complete: @escaping (_ photos: [Photo]) -> ()) {
        
        if let searchURL = self.backend.searchURL(forKeywords: "jaguar car", page: page) {
            // Create data task and run it
            self.urlSession.dataTask(with: searchURL) { (data, response, error) in
                
                // Return early if response is empty
                if response == nil || error != nil {
                    // Execute on main thread to allow for UI updates
                    OperationQueue.main.addOperation({
                        complete([])
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
                        
                        
                    }
                default: break
                }
            }.resume() // Execute task
        } else {
            // Handle error
        }
        
    }
    
}
