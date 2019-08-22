//
//  CatergoryCollectionViewCell.swift
//  Example
//
//  Created by Artur on 20/08/2019.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import UIKit

class ProductCatergoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryUIImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var productItem: CategoryProduct? {
        willSet {
            conifgureCell(with: newValue)
        }
    }
    
    private func conifgureCell(with item: CategoryProduct?) {
        guard let item = item else { return }
        categoryUIImageView.imageFromUrl(urlString: item.image)
        titleLabel.text = item.name
    }
    
}
