//
//  FullCollectionViewLayout.swift
//  Picsojags
//
//  Created by Boy van Amstel on 20/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import UIKit

/// Draws a fullscreen layout.
class FullCollectionViewLayout: UICollectionViewFlowLayout {

    override func prepare() {
        super.prepare()
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
        self.scrollDirection = .horizontal
        let insetRect = self.collectionView!.contentInset
        var size = self.collectionView!.bounds.size
        size.height -= insetRect.top + insetRect.bottom
        size.width -= insetRect.left + insetRect.right
        self.itemSize = size
    }
   
//    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        if let attr = self.layoutAttributesForItem(at: itemIndexPath) {
//            attr.alpha = 0 // Fade in
//            let scaleFactor = CGFloat(0.2)
//            let transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
//            attr.transform = transform
//            return attr
//        }
//        return nil
//    }
    
}
