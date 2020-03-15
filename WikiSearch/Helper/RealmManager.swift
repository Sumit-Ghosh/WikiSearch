//
//  RealmManager.swift
//  WikiSearch
//
//  Created by Sumit Ghosh on 15/03/20.
//  Copyright © 2020 Sumit Ghosh. All rights reserved.
//

import Foundation
import RealmSwift

class RealManager {
    let realm = try! Realm()
    
    func saveResponseToDB(searchText: String, offset: Int, responseString: String) {
        let searchResult = self.realm.object(ofType: SearchResultModel.self, forPrimaryKey: "\(searchText)")
        if let searchResult = searchResult {
            let resultData = ResponseJSON(key: offset, json: responseString)
            try! self.realm.write() {
                searchResult.responseList.append(resultData)
            }
        } else {
            try! realm.write() {
                let searchModel = SearchResultModel(key: searchText, offset: offset, json: responseString)
                realm.add(searchModel)
            }
        }
    }
    
    func fetchDataFromDB(searchText: String, offset: Int) -> ResponseJSON? {
        let searchResult = realm.object(ofType: SearchResultModel.self, forPrimaryKey: "\(searchText)")
        return searchResult?.responseList.filter("offset = \(offset)").first
    }
}
