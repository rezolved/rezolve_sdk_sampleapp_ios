//
//  CategoryViewController.swift
//  Example
//
//  Created by Artur on 20/08/2019.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
    @IBOutlet weak var productCategoryCollectionView: UICollectionView!
    @IBOutlet weak var categoryImageView: UIImageView!
    var category: Category!

    override func viewDidLoad() {
        super.viewDidLoad()
        categoryImageView.contentMode = .scaleAspectFit
        categoryImageView.imageFromUrl(urlString: category.image)
        let nib = UINib(nibName: Constant.catergoryCollectionCellID, bundle: nil)
        productCategoryCollectionView.register(nib, forCellWithReuseIdentifier: Constant.catergoryCollectionCellID)
        productCategoryCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }

}



extension CategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
//
            return UICollectionReusableView()
        default:
            return UICollectionReusableView()
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return category.products.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getConfiguredProductCatergoryCell(forForItemAt: indexPath) ?? UICollectionViewCell()
    }
    
    private func getConfiguredProductCatergoryCell(forForItemAt indexPath: IndexPath) -> ProductCatergoryCollectionViewCell? {
        guard let categoryCell = productCategoryCollectionView.dequeueReusableCell(withReuseIdentifier: Constant.catergoryCollectionCellID,
                                                                                   for: indexPath) as? ProductCatergoryCollectionViewCell else { return nil }
        categoryCell.productItem = category.products.items[indexPath.row]
        
        return categoryCell
    }
    
}


extension CategoryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewWidth = view.bounds.size.width
        let sparator: CGFloat = 5.0
        let viewWdthSplit = viewWidth / 2
        let collectionWidth = viewWdthSplit - sparator
        
        return CGSize(width: collectionWidth, height: 400)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 180.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 60.0, height: 30.0)
    }
}

extension CategoryViewController {
    enum Constant {
        static let catergoryCollectionCellID = "CatergoryCollectionViewCell"
    }
}
