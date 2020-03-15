//
//  SearchResultModel.swift
//  WikiSearch
//
//  Created by Sumit Ghosh on 14/03/20.
//  Copyright © 2020 Sumit Ghosh. All rights reserved.
//

import Foundation
import RealmSwift

class SearchResultModel: Object {
    @objc dynamic var searchKey = ""
    let responseList = List<ResponseJSON>()
    
    convenience init(key: String, offset: Int, json: String) {
        self.init()
        searchKey = key
        let resultData = ResponseJSON(key: offset, json: json)
        responseList.append(resultData)
    }
    
    override class func primaryKey() -> String? {
        return "searchKey"
    }
}

class ResponseJSON: Object {
    @objc dynamic var offset = 0
    @objc dynamic var responseJSON = ""
    
    convenience init(key: Int, json: String) {
        self.init()
        offset = key
        responseJSON = json
    }
}
