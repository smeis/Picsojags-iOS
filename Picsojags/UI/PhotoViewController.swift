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
    
    /// Refresh control allows for pull to refresh.
    fileprivate var refreshControl = UIRefreshControl()
    /// The array of photos retrieved from the photo service, NSSet might be better suited.
    fileprivate var photos: [Photo] = []
    /// The current page.
    fileprivate var currentPage = 1
    
    /// Sets up the photo store and UI.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Setup collectionview
        self.collectionView.collectionViewLayout = GridCollectionViewLayout()
        
        // WARN: This allows me to hide the API key from git and upload this project to GitHub, not suited for real world apps
        if let path = Bundle.main.path(forResource: "PhotoServices", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            // Use the 500px backend
            if let apiKey = dict["500px"] as? String {
                let photoBackend = PhotoBackend500px(withAPIKey: apiKey)
                self.photoStore = PhotoStore(backend: photoBackend)
                self.photoStore?.fetchPhotos(page: self.currentPage, complete: { (response) in
                    guard response.success else {
                        // TODO: Handle error
                        return
                    }
                    self.photos = response.photos
                    self.collectionView.reloadData()
                })
            }
        }
        
        // Setup refresh control
        self.refreshControl.tintColor = .blue // TODO: Override color with PaintCode
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
        self.collectionView.setCollectionViewLayout(GridCollectionViewLayout(), animated: false) { [unowned self] (finished) in
            if finished {
                // Visually update collection view
                self.collectionView.isPagingEnabled = false
                self.collectionView.bounces = true
                self.collectionView.backgroundColor = .white
                self.collectionView.reloadData()
                // Scroll to appropriate item
                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
                // Hide back button
                self.navigationItem.setLeftBarButton(nil, animated: true)
            }
        }
    }
    
}

// MARK: - Refreshing and endless scrolling

extension PhotoViewController: UIScrollViewDelegate {
    
    /// Handles pull to refresh
    func pullToRefresh() {
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
            self.currentPage = 1 // Reset paging
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
        })
    }
    
    /// Handle endless scrolling.
    ///
    /// - Parameter scrollView: The scrollview that contains the collection view.
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        guard let photoStore = self.photoStore else {
            return
        }
        var fetchNextPage = false
        // For the grid view, monitor scroll offset
        if self.collectionView.collectionViewLayout is GridCollectionViewLayout {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            if offsetY > contentHeight - scrollView.frame.size.height {
                fetchNextPage = true
            }
        }
        else { // For the fullscreen view, monitor item index
            // Check if at the last page (item)
            if let indexPath = self.collectionView.indexPathsForVisibleItems.last {
                if indexPath.item >= self.photos.count - self.currentPage { // Not sure why, but there's a self.currentPage offset
                    fetchNextPage = true
                }
            }
        }
        if fetchNextPage {
            self.currentPage += 1 // Fetch next page
            photoStore.fetchPhotos(page: self.currentPage, complete: { (response) in
                self.photos = self.photos + response.photos // Append new photos
                self.collectionView.reloadData()
            })
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
            cell.imageView.contentMode = .scaleAspectFit
            cell.imageView.kf.setImage(with: photo.fullPhotoURL)
        } else { // Use a squared image when using the grid layout
            cell.imageView.contentMode = .scaleAspectFill
            cell.imageView.kf.setImage(with: photo.squaredPhotoURL)
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
        // Set the new layout
        self.collectionView.setCollectionViewLayout(FullCollectionViewLayout(), animated: false) { [unowned self] (finished) in
            if finished {
                // Visisually update collection view
                self.collectionView.isPagingEnabled = true
                self.collectionView.bounces = false
                self.collectionView.backgroundColor = .black
                self.collectionView.reloadData()
                // Scroll to correct item
                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
                // Add back button
                let leftMenuItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.backToGrid));
                self.navigationItem.setLeftBarButton(leftMenuItem, animated: false);
            }
        }
    }
    
}
