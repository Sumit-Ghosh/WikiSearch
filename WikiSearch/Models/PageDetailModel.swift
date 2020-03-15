//
//  PageDetailModel.swift
//  WikiSearch
//
//  Created by Sumit Ghosh on 15/03/20.
//  Copyright © 2020 Sumit Ghosh. All rights reserved.
//

import Foundation

// MARK: - BasePageModel
struct BasePageModel: Codable {
    let query: QueryPage
}

// MARK: - Query
struct QueryPage: Codable {
    let pages: [String:Item]
}

// MARK: - Item
struct Item: Codable {
    let fullurl: String?
    let editurl: String?
    let canonicalurl: String?
}


