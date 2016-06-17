//
//  Filter.swift
//  Imagery
//
//  Created by Anton Moiseev on 2016-06-14.
//  Copyright © 2016 Anton Moiseev. All rights reserved.
//

import Foundation
import GPUImage

class Filter: NSObject {
    
    // MARK: Properties
    
    var type: GPUImageOutput
    var group: FilterGroup
    var name: String
    var source: GPUImagePicture?
    
    init(type: GPUImageOutput, name: String, group: FilterGroup, source: GPUImagePicture?) {
        self.type = type
        self.name = name
        self.group = group
        self.source = source
    }
}