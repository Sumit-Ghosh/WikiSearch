//
//  NetworkManager.swift
//  WikiSearch
//
//  Created by Sumit Ghosh on 13/03/20.
//  Copyright © 2020 Sumit Ghosh. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

enum NetworkError: Error {
    case failure
    case success
}

class APIClient {
    var searchResults = [JSON]()
    
    let realm = try! Realm()
    
    func search(searchText: String, gpsOffset: Int, completionHandler: @escaping ([JSON]?, NetworkError) -> ()) {
        
        guard let encodeSearchString = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        let urlToSearch = "https://en.wikipedia.org//w/api.php?action=query&format=json&prop=pageimages%7Cpageterms&generator=prefixsearch&redirects=1&formatversion=2&piprop=thumbnail&pithumbsize=50&pilimit=10&wbptterms=description&gpssearch=\(encodeSearchString)&gpslimit=10&gpsoffset=\(gpsOffset)"
        
        let valueFromDB = realm.object(ofType: SearchModel.self, forPrimaryKey: "\(searchText)")
        let pageObject = valueFromDB?.responseList.filter("offset = \(gpsOffset)")
        if let pageObject = pageObject?.first {
            print("Value from DB \(valueFromDB)")
            let json = JSON(parseJSON: pageObject.responseJSON)
            let results = json["query"]["pages"].arrayValue
            completionHandler(results, .success)
        }
        
        else {
            AF.request(urlToSearch)
                .responseString(completionHandler: { response in
                    //                print(response)
                    guard let responseString = response.value else {
                        completionHandler(nil, .failure)
                        return
                    }
                    

                    let valueFromDB = self.realm.object(ofType: SearchModel.self, forPrimaryKey: "\(searchText)")
                    if let valueFromDB = valueFromDB {
                        let resultData = ResultData()
                        resultData.offset = gpsOffset
                        resultData.responseJSON = responseString
                        
                        
                        try! self.realm.write() {
                            valueFromDB.responseList.append(resultData)
//                            self.realm.add(valueFromDB)
                        }
                    } else {
                        try! self.realm.write() {
                            let searchModel = SearchModel(key: searchText, offset: gpsOffset, json: responseString)
                            self.realm.add(searchModel)
                        }
                    }
                    
                    print("search key \(searchText)")
                    
                    
                })
                .responseJSON { response in
                    guard let data = response.data else {
                        completionHandler(nil, .failure)
                        return
                    }
                    let json = try? JSON(data: data)
                    let results = json?["query"]["pages"].arrayValue
                    guard let empty = results?.isEmpty, !empty else {
                        completionHandler(nil, .failure)
                        return
                    }
                    completionHandler(results, .success)
            }
        }
        
    }
    
    func fetchPageURL(pageid: String, completionHandler: @escaping (JSON?, NetworkError) -> ()) {
        let url = "https://en.wikipedia.org/w/api.php?action=query&prop=info&pageids=\(pageid)&inprop=url&format=json"
        
        AF.request(url).responseJSON { response in
            guard let data = response.data else {
                completionHandler(nil, .failure)
                return
            }
            
            let json = try? JSON(data: data)
            let results = json?["query"]["pages"]["\(pageid)"]
            guard let empty = results?.isEmpty, !empty else {
                completionHandler(nil, .failure)
                return
            }
            
            completionHandler(results, .success)
        }
        
    }
    
    func fetchImage(url: String, completionHandler: @escaping (UIImage?, NetworkError) -> ()) {
        AF.request(url).responseData { responseData in
            
            guard let imageData = responseData.data else {
                completionHandler(nil, .failure)
                return
            }
            
            guard let image = UIImage(data: imageData) else {
                completionHandler(nil, .failure)
                return
            }
            
            completionHandler(image, .success)
        }
    }
}


