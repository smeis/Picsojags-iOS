//
//  Photo.swift
//  Picsojags
//
//  Created by Boy van Amstel on 19/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import UIKit

/// Photo model.
struct Photo: Equatable {
    
    /// Squared photo URL to be used in a grid.
    fileprivate(set) var squaredPhotoURL: URL
    /// Larger size image URL to be used fullscreen.
    fileprivate(set) var fullPhotoURL: URL

}

func ==(lhs: Photo, rhs: Photo) -> Bool {
    return lhs.squaredPhotoURL == rhs.squaredPhotoURL && lhs.fullPhotoURL == rhs.fullPhotoURL
}
