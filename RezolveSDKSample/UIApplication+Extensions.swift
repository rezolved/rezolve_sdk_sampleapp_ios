//
//  UIApplication+Extensions.swift
//  RezolveSDKSample
//
//  Created by Dennis Koluris on 9/5/22.
//  Copyright © 2022 Rezolve. All rights reserved.
//

import UIKit

extension UIApplication {
    
    class func appBundle() -> String {
        return Bundle.main.bundleIdentifier ?? ""
    }

    class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
}
