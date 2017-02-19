//
//  Photo.swift
//  Picsojags
//
//  Created by Boy van Amstel on 19/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import UIKit

struct Photo: Equatable {
    
    fileprivate(set) var lowQualityURL: URL
    fileprivate(set) var highQualityURL: URL

}

func ==(lhs: Photo, rhs: Photo) -> Bool {
    return lhs.lowQualityURL == rhs.lowQualityURL && lhs.highQualityURL == rhs.highQualityURL
}
