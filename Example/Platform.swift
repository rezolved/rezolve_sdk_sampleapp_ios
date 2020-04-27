//
//  Platform.swift
//  Example
//
//  Modified by Dennis Koluris on 27/04/2020.
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
