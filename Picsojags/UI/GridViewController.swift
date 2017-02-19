//
//  PhotosViewController.swift
//  Picsojags
//
//  Created by Boy van Amstel on 19/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import UIKit

class GridViewController: UIViewController {

    @IBOutlet weak var gridCollectionView: UICollectionView!
    
    var photoStore: PhotoStore?
    var photos: [Photo] = []
    
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
                    self.gridCollectionView.reloadData()
                })
            }
        }
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

// MARK: - Data source

extension GridViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return cell
    }
    
}
