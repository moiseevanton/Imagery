//
//  ViewController.swift
//  Imagery
//
//  Created by Anton Moiseev on 2016-06-14.
//  Copyright © 2016 Anton Moiseev. All rights reserved.
//

import UIKit
import GPUImage

class EditViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var filterCollection: UICollectionView!
    var filterArray = [Filter.init(type: GPUImageSepiaFilter.init(), name: "SP"),
                       Filter.init(type: GPUImageColorInvertFilter.init(), name: "CI"),
                       Filter.init(type: GPUImageHazeFilter.init(), name: "HZ"),
                       Filter.init(type: GPUImageGrayscaleFilter.init(), name: "GS"),
                       Filter.init(type: GPUImageMotionBlurFilter.init(), name: "MB"),
                       Filter.init(type: GPUImagePixellateFilter.init(), name: "PX"),
                       Filter.init(type: GPUImagePolkaDotFilter.init(), name: "PD"),
                       Filter.init(type: GPUImageSketchFilter.init(), name: "SK"),
                       Filter.init(type: GPUImagePosterizeFilter.init(), name: "PS")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make EVC the data source and the delegate for the filter collection
        self.filterCollection.dataSource = self
        self.filterCollection.delegate = self
        
        // move the first and last cells by 10
        self.filterCollection.contentInset = UIEdgeInsetsMake(0, 9, 0, 9)
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("filterCell", forIndexPath: indexPath) as! FilterCell
        let filter = filterArray[indexPath.item]
        cell.displayFilter(filter.name, filter: filter.type, image: UIImage(named: "supremeCat")!)
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 15
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! FilterCell
        photoView.image = cell.filterImageView.image
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(51, 60)
    }
}

