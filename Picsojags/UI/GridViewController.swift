//
//  PhotosViewController.swift
//  Picsojags
//
//  Created by Boy van Amstel on 19/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import UIKit
import Kingfisher

class GridViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var refreshControl = UIRefreshControl()
    
    var photoStore: PhotoStore?
    
    fileprivate var photos: [Photo] = []
    
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // WARN: This allows me to hide the API key from git and upload this project to GitHub, not suited for real world apps
        if let path = Bundle.main.path(forResource: "PhotoServices", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            // Use the 500px backend
            if let apiKey = dict["500px"] as? String {
                let photoBackend = PhotoBackend500px(withAPIKey: apiKey)
                self.photoStore = PhotoStore(backend: photoBackend)
                self.photoStore?.fetchPhotos(page: 1, complete: { (response) in
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

// MARK: - Refreshing and endless scrolling

extension GridViewController {
    
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
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
        })
    }
    
}

// MARK: - Data source

extension GridViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCollectionViewCell
        let photo = self.photos[indexPath.row]
        cell.imageView.kf.setImage(with: photo.squaredPhotoURL)
        return cell
    }
    
}

// MARK: - Flow layout

extension GridViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = self.sectionInsets.left * (self.itemsPerRow + 1)
        let availableWidth = self.view.frame.width - paddingSpace
        let widthPerItem = floor(availableWidth / self.itemsPerRow)
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return self.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.sectionInsets.left
    }
    
}
