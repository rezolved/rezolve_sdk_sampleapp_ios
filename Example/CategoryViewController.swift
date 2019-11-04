//
//  CategoryViewController.swift
//  Example
//
//  Created by Artur on 20/08/2019.
//  Copyright © 2019 Rezolve. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
    @IBOutlet weak var productCategoryCollectionView: UICollectionView!
    private var presentationData: CategoryPresentationData!

    override func viewDidLoad() {
        super.viewDidLoad()
        let nibCollectionCel = UINib(nibName: Constant.catergoryCollectionCellID, bundle: nil)
        productCategoryCollectionView.register(nibCollectionCel, forCellWithReuseIdentifier: Constant.catergoryCollectionCellID)
        
        let categorySectionHeaderNIB = UINib(nibName: Constant.catergoryCollectionHeaderID, bundle: nil)
        productCategoryCollectionView.register(categorySectionHeaderNIB, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constant.catergoryCollectionHeaderID)
    }

    func set(category presentationData: CategoryPresentationData) {
        self.presentationData = presentationData
    }
}

extension CategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let categoryHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constant.catergoryCollectionHeaderID, for: indexPath) as? CategoryCollectionReusableView {
            categoryHeader.categoryImage.imageFromUrl(urlString: presentationData.categoryImage)
            return categoryHeader
        } else {
            return UICollectionReusableView()
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presentationData.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getConfiguredProductCatergoryCell(forForItemAt: indexPath) ?? UICollectionViewCell()
    }
    
    private func getConfiguredProductCatergoryCell(forForItemAt indexPath: IndexPath) -> ProductCatergoryCollectionViewCell? {
        guard let categoryCell = productCategoryCollectionView.dequeueReusableCell(withReuseIdentifier: Constant.catergoryCollectionCellID,
                                                                                   for: indexPath) as? ProductCatergoryCollectionViewCell else { return nil }
        categoryCell.productItem = presentationData.products[indexPath.row]
        
        return categoryCell
    }
    
}


extension CategoryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewWidth = collectionView.bounds.size.width
        let sparator: CGFloat = 5.0
        let viewWdthSplit = viewWidth / 2
        let collectionWidth = viewWdthSplit - sparator
        let cellHeight: CGFloat = 200
        
        return CGSize(width: collectionWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width / 2)
    }
    
}

extension CategoryViewController {
    enum Constant {
        static let catergoryCollectionCellID = "CatergoryCollectionViewCell"
        static let catergoryCollectionHeaderID = "CategoryCollectionReusableView"
    }
}
