//
//  GridCollectionViewLayout.swift
//  Picsojags
//
//  Created by Boy van Amstel on 20/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import UIKit

/// Draws a grid layout.
class GridCollectionViewLayout: UICollectionViewFlowLayout {

    /// The maximum items to appear in the row.
    fileprivate let itemsPerRow: CGFloat = 3

    override func prepare() {
        super.prepare()
        self.minimumInteritemSpacing = 1
        self.minimumLineSpacing = 1
        self.scrollDirection = .vertical
        let availableWidth = self.collectionView!.bounds.width - self.itemsPerRow
        let widthPerItem = floor(availableWidth / self.itemsPerRow)
        self.itemSize = CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attr = self.layoutAttributesForItem(at: itemIndexPath) {
            attr.alpha = 0 // Fade in
            let scaleFactor = CGFloat(0.2)
            let transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            attr.transform = transform
            return attr
        }
        return nil
    }
    
}
