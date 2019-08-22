//
//  CategoryPresentationData.swift
//  Example
//
//  Created by Artur on 22/08/2019.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import Foundation
import RezolveSDK

class ProductCategoryLoader {
    private let merchantId: String
    private let category: RezolveCategory
    
    private var parameters: PageNavigationParameters {
        return PageNavigationParameters(
            categoryFilter: PageNavigationFilter(navigationType: .Category, sortDirection: .ASC, itemsPerPage: 100, pageNumber: 1),
            productsFilter: PageNavigationFilter(navigationType: .Products, sortDirection: .ASC, itemsPerPage: 100, pageNumber: 1)
        )
    }
    
    init(merchantId: String, category: RezolveCategory) {
        self.merchantId = merchantId
        self.category = category
    }
    
    func loadCategoryPresentationData(with session: RezolveSession, completionHandler: @escaping (CategoryPresentationData?) -> ()) {
        session.productManager.getProductsAndCategoriesV2(merchantId: merchantId, category: category, pageNavigationParameters: parameters, callback: { _, products in
            completionHandler(CategoryPresentationData(categoryImage: self.category.image, productPage: products))
        }) { response in
            completionHandler(nil)
        }
    }
}

class CategoryPresentationData {
    let categoryImage: String
    var products: [CategoryProduct]
    
    init(categoryImage: String, productPage: PageResult<DisplayProduct>) {
        self.categoryImage = categoryImage
        
        let displayProducts = productPage.embedded
        self.products = displayProducts.map { CategoryProduct(displayProduct: $0) }
    }
    
}

struct CategoryProduct {
    let name: String
    let image: String
}

extension CategoryProduct {
    init(displayProduct: DisplayProduct) {
        self.name = displayProduct.name
        self.image = displayProduct.thumbs?.first ?? displayProduct.image ?? ""
    }
}


