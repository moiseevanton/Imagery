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
    
    func displayFilter(filterTuple: (UIImage, Filter)) {
        let filterName = filterTuple.1.name
        filterImageView.image = filterTuple.0
        nameLabel.text = filterName
    }
}
