//
//  PhotosViewController.swift
//  Picsojags
//
//  Created by Boy van Amstel on 19/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var refreshControl = UIRefreshControl()
    
    var photoStore: PhotoStore?
    
    fileprivate var photos: [Photo] = []
    fileprivate var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        
        // Setup collectionview
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.collectionViewLayout = GridCollectionViewLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UI methods

extension PhotoViewController {
    
    @IBAction func backToGrid(sender: AnyObject) {
        self.collectionView.setCollectionViewLayout(GridCollectionViewLayout(), animated: true) { [unowned self] (finished) in
            if finished {
                self.collectionView.isPagingEnabled = false
                self.collectionView.bounces = true
                self.collectionView.backgroundColor = .white
                self.collectionView.reloadData()
                self.navigationItem.setLeftBarButton(nil, animated: true)
            }
        }
    }
    
}

// MARK: - Refreshing and endless scrolling

extension PhotoViewController: UIScrollViewDelegate {
    
    func pullToRefresh() {
        guard let photoStore = self.photoStore else {
            self.refreshControl.endRefreshing()
            return
        }
        
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
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        guard let photoStore = self.photoStore else {
            return
        }
        var fetchNextPage = false
        if self.collectionView.collectionViewLayout is GridCollectionViewLayout {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            if offsetY > contentHeight - scrollView.frame.size.height {
                fetchNextPage = true
            }
        } else {
            // Check if at the last page
            let pageWidth = collectionView.bounds.size.width
            let currentPage = Int(ceil(collectionView.contentOffset.x / pageWidth) + 1)
            if currentPage >= self.photos.count {
                fetchNextPage = true
            }
        }
        if fetchNextPage {
            self.currentPage += 1 // Fetch next page
            photoStore.fetchPhotos(page: self.currentPage, complete: { (response) in
                self.photos = self.photos + response.photos
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
        if collectionView.collectionViewLayout is FullCollectionViewLayout {
            cell.imageView.contentMode = .scaleAspectFit
            cell.imageView.kf.setImage(with: photo.fullPhotoURL)
        } else {
            cell.imageView.contentMode = .scaleAspectFill
            cell.imageView.kf.setImage(with: photo.squaredPhotoURL)
        }
        return cell
    }
    
}

extension PhotoViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.collectionView.collectionViewLayout is FullCollectionViewLayout {
            return
        }
        self.collectionView.setCollectionViewLayout(FullCollectionViewLayout(), animated: true) { [unowned self] (finished) in
            if finished {
                self.collectionView.isPagingEnabled = true
                self.collectionView.bounces = false
                self.collectionView.backgroundColor = .black
                self.collectionView.reloadData()
                let leftMenuItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.backToGrid));
                self.navigationItem.setLeftBarButton(leftMenuItem, animated: false);
            }
        }
    }
    
}
