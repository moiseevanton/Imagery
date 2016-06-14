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
    
    var type: GPUImageFilter
    var name: String
    
    init(type: GPUImageFilter, name: String) {
        self.type = type
        self.name = name
    }
}