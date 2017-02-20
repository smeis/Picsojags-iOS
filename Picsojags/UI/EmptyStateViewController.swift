//
//  EmptyStateViewController.swift
//  Picsojags
//
//  Created by Boy van Amstel on 20/02/2017.
//  Copyright © 2017 Danger Cove. All rights reserved.
//

import UIKit

class EmptyStateViewController: UIViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - Showing and hiding

extension EmptyStateViewController {
    
    func showProgress() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 1.0
        })
    }
    
    func hideProgress() {
        UIView.animate(withDuration: 0.2, animations: { 
            self.view.alpha = 0.0
        }) { (complete) in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
    
}
