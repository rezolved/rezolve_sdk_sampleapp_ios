//
//  DecimalExtensions.swift
//  Example
//
//  Created by Vasyl Skop on 08/08/2019.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import Foundation

extension Decimal {
    
    func toDouble() -> Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
    
    func toInt() -> Int {
        return NSDecimalNumber(decimal: self).intValue
    }
}
