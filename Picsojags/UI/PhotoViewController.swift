//
//  PhotosViewController.swift
//  Picsojags
//
//  Created by Boy van Amstel on 19/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import UIKit
import Kingfisher

/// Displays the retrieved photos.
class PhotoViewController: UIViewController {

    /// The main collection view, displays photos.
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// The photo store uses the backend to retrieve images.
    var photoStore: PhotoStore?
    
    /// Draws the empty state view
    lazy var emptyStateViewController: EmptyStateViewController = {
        return EmptyStateViewController(nibName: "EmptyStateViewController", bundle: nil)
    }()
    
    /// Refresh control allows for pull to refresh.
    fileprivate var refreshControl = UIRefreshControl()
    /// The array of photos retrieved from the photo service, NSSet might be better suited.
    fileprivate var photos: [Photo] = []
    /// The current page.
    fileprivate var currentPage = 1
    /// The last page to fetch, returned by the photo service.
    fileprivate var maxPage = 1
    /// The flow layout item size.
    fileprivate var itemSize: CGSize = CGSize(width: 100, height: 100)
    
    /// Sets up the photo store and UI.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Setup collectionview
        self.changeCollectionViewLayout(GridCollectionViewLayout(), fromIndexPath: IndexPath(row: 0, section: 0))
        self.collectionView.backgroundView = self.emptyStateViewController.view
        
        // WARN: This allows me to hide the API key from git and upload this project to GitHub, not suited for real world apps
        if let path = Bundle.main.path(forResource: "PhotoServices", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            // Use the 500px backend
            if let apiKey = dict["500px"] as? String {
                let photoBackend = PhotoBackend500px(withAPIKey: apiKey)
                self.photoStore = PhotoStore(backend: photoBackend)
                self.photoStore?.fetchPhotos(page: self.currentPage, complete: { [unowned self] (response) in
                    guard response.success else {
                        // TODO: Handle error
                        return
                    }
                    self.photos = response.photos
                    self.collectionView.reloadSections(IndexSet(integer: 0))
                    self.maxPage = response.pages
                    self.emptyStateViewController.hideProgress()
                })
            }
        }
        
        // Setup refresh control
        self.refreshControl.tintColor = PicsojagsStyleKit.featureColor
        self.refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        self.collectionView.addSubview(refreshControl)
        self.collectionView.alwaysBounceVertical = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        // Kingfisher empties its cache automatically when we receive a warning
    }

}

// MARK: - UI methods

extension PhotoViewController {
    
    /// Takes the UI back from the fullscreen view to the grid view.
    ///
    /// - Parameter sender: The object making the call.
    @IBAction func backToGrid(sender: AnyObject) {
        guard let indexPath = collectionView.indexPathsForVisibleItems.first else {
            // We need the index path to return to
            return
        }
        // FIXME: This is a workaround, should be able to get this working by customizing UICollectionViewFlowLayout
        UIView.animate(withDuration: 0.1, animations: {
            self.collectionView.alpha = 0
        }) { (finished) in
            self.changeCollectionViewLayout(GridCollectionViewLayout(), fromIndexPath: indexPath)
            UIView.animate(withDuration: 0.2, animations: {
                self.collectionView.alpha = 1
            }, completion: nil)
        }
    }
    
    fileprivate func changeCollectionViewLayout(_ layout: UICollectionViewLayout, fromIndexPath indexPath: IndexPath) {
        if layout == self.collectionView.collectionViewLayout {
            return // Don't replace identical layout
        }
        
        self.collectionView.setCollectionViewLayout(layout, animated: false) { [unowned self] (finished) in
            if finished {
                
                var scrollPos: UICollectionViewScrollPosition!
                
                if layout is GridCollectionViewLayout {
                    
                    // Grid
                    
                    // Visually update collection view
                    self.collectionView.isPagingEnabled = false
                    self.collectionView.bounces = true
                    // Scroll to appropriate item
                    // Hide back button
                    self.navigationItem.setLeftBarButton(nil, animated: true)
                    scrollPos = UICollectionViewScrollPosition.centeredVertically
                    self.collectionView.reloadData()
                    
                } else {
                    
                    // Full
                    
                    // Visisually update collection view
                    self.collectionView.isPagingEnabled = true
                    self.collectionView.bounces = false
                    // Scroll to correct item
                    // Add back button
                    let leftMenuItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.backToGrid));
                    self.navigationItem.setLeftBarButton(leftMenuItem, animated: true);
                    scrollPos = UICollectionViewScrollPosition.centeredHorizontally
                    self.collectionView.reloadData()
                    
                }
                
                // Update item size
                if let layout = layout as? UICollectionViewFlowLayout {
                    self.itemSize = layout.itemSize
                }

                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: scrollPos)
            }
        }
    
    }
    
}

// MARK: - Refreshing and endless scrolling

extension PhotoViewController: UIScrollViewDelegate {
    
    /// Handles pull to refresh
    internal func pullToRefresh() {
        guard let photoStore = self.photoStore else {
            self.refreshControl.endRefreshing() // Ensure pull to refresh animation ends
            return
        }
        
        // Fetch the original set of photos, loses any paged content
        photoStore.fetchPhotos(page: 1, complete: { (response) in
            guard response.success else {
                // TODO: Handle error
                return
            }
            self.photos = response.photos
            self.maxPage = response.pages
            self.currentPage = 1 // Reset paging
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
        })
    }
    
    fileprivate func fetchNextPage() {
        guard let photoStore = self.photoStore else {
            return
        }
        
        self.currentPage += 1 // Fetch next page
        guard self.currentPage <= self.maxPage else {
            return // No pages left
        }
        photoStore.fetchPhotos(page: self.currentPage, complete: { [unowned self] (response) in
            guard response.success else {
                // TODO: Handle error
                return
            }
            self.photos = self.photos + response.photos // Append new photos
            self.maxPage = response.pages
            self.collectionView.reloadData() // Crashes when using reloadItemsAt or reloadSections
        })
    }
    
    /// Handle endless scrolling.
    ///
    /// - Parameter scrollView: The scrollview that contains the collection view.
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        // For the grid view, monitor scroll offset
        if self.collectionView.collectionViewLayout is GridCollectionViewLayout {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            if offsetY > contentHeight - scrollView.frame.size.height {
                self.fetchNextPage()
            }
        }
        else { // For the fullscreen view, monitor item index
            // Check if at the last page (item)
            if let indexPath = self.collectionView.indexPathsForVisibleItems.last {
                if indexPath.item >= self.photos.count - self.currentPage { // Not sure why, but there's a self.currentPage offset
                    self.fetchNextPage()
                }
            }
        }
    }
    
}

// MARK: - Data source

extension PhotoViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
        let photo = self.photos[indexPath.row]
        
        // Load the fullscreen image when using the fullscreen layout
        if collectionView.collectionViewLayout is FullCollectionViewLayout {
            
            cell.backgroundColor = .black
            cell.imageView.contentMode = .scaleAspectFit
            let placeholderSize = CGSize(width: self.itemSize.width, height: self.itemSize.width)
            let placeholder = PicsojagsStyleKit.imageOfPhotoPlaceholderFull(imageSize: placeholderSize)
//            cell.imageView.image = placeholder
            cell.imageView.kf.setImage(with: photo.fullPhotoURL, placeholder: placeholder)
            
        } else { // Use a squared image when using the grid layout
            
            cell.backgroundColor = .white
            cell.imageView.contentMode = .scaleAspectFill
            let placeholder = PicsojagsStyleKit.imageOfPhotoPlaceholderGrid(imageSize: self.itemSize)
//            cell.imageView.image = placeholder
            cell.imageView.kf.setImage(with: photo.squaredPhotoURL, placeholder: placeholder)
            
        }
        return cell
    }
    
}

// MARK: - Collection view delegate

extension PhotoViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Only select items in grid view
        guard self.collectionView.collectionViewLayout is GridCollectionViewLayout else {
            return
        }
        
        // FIXME: This is a workaround, should be able to get this working by customizing UICollectionViewFlowLayout
        
        // Create frame size
        var rect = self.collectionView.frame
        let offset = self.collectionView.contentOffset
        rect.origin.x += offset.x
        rect.origin.y += offset.y + 34 // TODO: Get title bar height programmatically
        
        // Update cell to show hq image
        let photo = self.photos[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        cell.backgroundColor = .black
        let placeholder = PicsojagsStyleKit.imageOfPhotoPlaceholderFull(imageSize: CGSize(width: rect.size.width, height: rect.size.width))
        cell.imageView.contentMode = .scaleAspectFit
        cell.imageView.kf.setImage(with: photo.fullPhotoURL, placeholder: placeholder)
        cell.layer.zPosition = 99999999
        
        // Animate into view
        UIView.animate(withDuration: 0.2, animations: {
            cell.frame = rect
        }) { (finished) in
            // Set the new layout
            self.changeCollectionViewLayout(FullCollectionViewLayout(), fromIndexPath: indexPath)
        }
        
        // Fetch next page if the last item was selected
        if indexPath.item >= self.photos.count - self.currentPage { // Not sure why, but there's a self.currentPage offset
            self.fetchNextPage()
        }
    }
    
}
