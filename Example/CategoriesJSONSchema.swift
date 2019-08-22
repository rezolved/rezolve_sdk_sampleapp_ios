//
//  CategoriesJSONSchema.swift
//  Example
//
//  Created by Artur on 21/08/2019.
//  Copyright © 2019 Jakub Bogacki. All rights reserved.
//

import Foundation
import RezolveSDK

// MARK: - Category
struct Category: Codable {
    let id, parentID: Int
    let hasProducts, hasCategories: Bool
    let image: String
    let imageThumbs: [String]
    let name: String
    let categories, products: Categories
    let includeCartButtonOnListing: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case parentID = "parent_id"
        case hasProducts = "has_products"
        case hasCategories = "has_categories"
        case image
        case imageThumbs = "image_thumbs"
        case name, categories, products
        case includeCartButtonOnListing = "include_cart_button_on_listing"
    }
}

// MARK: - Categories
struct Categories: Codable {
    let links: Links
    let count: Int
    let items: [Item]
    let total: Int
}

// MARK: - Item
struct Item: Codable {
    let categoryID, id: Int
    let image: String
    let imageThumbs: [String]?
    let name: String
    let price: Double
    let isVirtual, hasRequiredOptions: Bool
    let maximumQty: Int
    
    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case id, image
        case imageThumbs = "image_thumbs"
        case name, price
        case isVirtual = "is_virtual"
        case hasRequiredOptions = "has_required_options"
        case maximumQty = "maximum_qty"
    }
}

// MARK: - Links
struct Links: Codable {
    let current, first: Current
    let prev, next: JSONNull?
    let last: Current
}

// MARK: - Current
struct Current: Codable {
    let count, page: Int
    let sortBy, sort: String
    
    enum CodingKeys: String, CodingKey {
        case count, page
        case sortBy = "sort_by"
        case sort
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
