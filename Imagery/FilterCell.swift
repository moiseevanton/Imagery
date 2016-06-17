//
//  FilterCell.swift
//  Imagery
//
//  Created by Anton Moiseev on 2016-06-14.
//  Copyright © 2016 Anton Moiseev. All rights reserved.
//

import UIKit
import GPUImage

class FilterCell: UICollectionViewCell {
    
    // MARK: Properties
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func displayFilter(filter: Filter, image: UIImage) {
        var quickFilteredImage: UIImage?
        if (filter.source != nil) {
            filter.type.useNextFrameForImageCapture()
            filter.source?.processImage()
            quickFilteredImage = filter.type.imageFromCurrentFramebuffer()
        } else {
            quickFilteredImage = filter.type.imageByFilteringImage(image)
        }
        filterImageView.image = quickFilteredImage
        nameLabel.text = filter.name
    }
}
