//
//  SearchDataModel.swift
//  WikiSearch
//
//  Created by Sumit Ghosh on 13/03/20.
//  Copyright © 2020 Sumit Ghosh. All rights reserved.
//


import Foundation

// MARK: - BaseResultModel
struct BaseResultModel: Codable {
    let query: Query

    enum CodingKeys: String, CodingKey {
        case query
    }
}

// MARK: - Query
struct Query: Codable {
    let pages: [Page]
}

// MARK: - Page
struct Page: Codable {
    let pageid : Int
    let title: String
    let thumbnail: Thumbnail?
    let terms: Terms?
}

// MARK: - Terms
struct Terms: Codable {
    let description: [String]

    enum CodingKeys: String, CodingKey {
        case description
    }
}

// MARK: - Thumbnail
struct Thumbnail: Codable {
    let source: String
    let width, height: Int
}
