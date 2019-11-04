//
//  UIImageView.swift
//  Example
//
//  Created by Jakub Bogacki on 17/04/2019.
//  Copyright © 2019 Rezolve. All rights reserved.
//

import UIKit

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        let url = URL(string: urlString)
        DispatchQueue.global().async {
            let data = try! Data(contentsOf: url!)
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }
    }
}
