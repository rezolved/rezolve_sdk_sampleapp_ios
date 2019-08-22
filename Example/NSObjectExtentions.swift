//
//  NSObjectExtentions.swift
//  Example
//
//  Created by Vasyl Skop on 07/08/2019.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import Foundation

extension NSObject {
    
    func UIUpdate(_ block: @escaping () -> Void) {
        DispatchQueue.main.async(execute: block)
    }
}

