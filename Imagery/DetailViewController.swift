//
//  DetailViewController.swift
//  Imagery
//
//  Created by Anton Moiseev on 2016-06-27.
//  Copyright © 2016 Anton Moiseev. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var detailImageView: UIImageView!
    var photo: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set the photo
        self.navigationController?.navigationBarHidden = true
        detailImageView.image = photo
    }
    
    // dismiss dvc when touch event ends
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // hide status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
