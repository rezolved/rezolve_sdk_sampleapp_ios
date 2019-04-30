//
//  Platform.swift
//  Example
//
//  Created by Jakub Bogacki on 17/04/2019.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import Foundation

struct Platform {
    static let isSimulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
}
