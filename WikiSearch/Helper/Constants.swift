//
//  Constants.swift
//  WikiSearch
//
//  Created by Sumit Ghosh on 15/03/20.
//  Copyright © 2020 Sumit Ghosh. All rights reserved.
//

import Foundation

struct Constants {
    
    static let searchVCTitle: String =                 "WikiSearch"
    static let searchPlaceholder: String =             "Search Wikipedia...."
    static let searchMessage: String =                 "Search Wikipedia and see result here ......!"
    static let noResultFoundMessage: String =          "No result found \nTry a different keyword"
    static let errorMessage: String =                  "Some error occured \nTry Again!"
    static let timeDelayInSearch: Double =             0.1
    static let baseURL: String =                       "https://en.wikipedia.org/"
    static let pageQuery: String =                     "w/api.php?action=query&prop=info&inprop=url&format=json&"
    static let searchQuery: String = "w/api.php?action=query&format=json&prop=pageimages%7Cpageterms&generator=prefixsearch&redirects=1&formatversion=2&piprop=thumbnail&pithumbsize=50&pilimit=10&wbptterms=description&gpslimit=10&"
    
    
    
    
}
