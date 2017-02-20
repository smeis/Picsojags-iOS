//
//  FullCollectionViewLayout.swift
//  Picsojags
//
//  Created by Boy van Amstel on 20/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import UIKit

class FullCollectionViewLayout: UICollectionViewFlowLayout {

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
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
        self.scrollDirection = .horizontal
    }
    
    override var itemSize: CGSize {
        set {}
        get {
            let insetRect = self.collectionView!.contentInset
            var size = self.collectionView!.bounds.size
            size.height -= insetRect.top + insetRect.bottom
            size.width -= insetRect.left + insetRect.right
            return size
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView!.contentOffset
    }

}
