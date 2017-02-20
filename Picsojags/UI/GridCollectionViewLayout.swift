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

    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    func setupLayout() {
        self.minimumInteritemSpacing = 1
        self.minimumLineSpacing = 1
        self.scrollDirection = .vertical
    }
    
    /// Override the item size to fit the items per row.
    override var itemSize: CGSize {
        set {}
        get {
            let availableWidth = self.collectionView!.bounds.width - self.itemsPerRow
            let widthPerItem = floor(availableWidth / self.itemsPerRow)
            return CGSize(width: widthPerItem, height: widthPerItem)
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView!.contentOffset
    }
    
}
