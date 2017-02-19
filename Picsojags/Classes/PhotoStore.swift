//
//  PhotoStore.swift
//  Picsojags
//
//  Created by Boy van Amstel on 19/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import UIKit

class PhotoStore: NSObject {

    fileprivate(set) var backend: PhotoBackend!
    
    init(backend: PhotoBackend) {
        self.backend = backend
    }
    
    func fetchPhotos(page: Int, complete: (_ photos: [Photo]) -> ()) {
    }
    
}
