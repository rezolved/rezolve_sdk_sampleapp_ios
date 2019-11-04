//
//  SignedNumericExtentions.swift
//  Example
//
//  Created by Vasyl Skop on 08/08/2019.
//  Copyright © 2019 Rezolve. All rights reserved.
//

import Foundation

extension SignedNumeric {
    
    public var asAppCurrency: String {
        guard let number = (self as? NSNumber)?.decimalValue else {
            return "$ -"
        }
        return String(format: "$%.2f", number.toDouble())
    }
}
