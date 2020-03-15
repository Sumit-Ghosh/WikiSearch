//
//  APIClient.swift
//  WikiSearch
//
//  Created by Sumit Ghosh on 13/03/20.
//  Copyright © 2020 Sumit Ghosh. All rights reserved.
//

import Foundation
import Alamofire

enum NetworkError: Error {
    case failure
    case success
}

class APIClient {
    
    let realmManager = RealManager()
    
    func fetchSearchResult(searchText: String, gpsOffset: Int, completionHandler: @escaping ([Page]?, NetworkError) -> ()) {
        
        guard let encodeSearchString = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }

        let urlToSearch = Constants.baseURL + Constants.searchQuery + "gpssearch=\(encodeSearchString)&gpsoffset=\(gpsOffset)"
        
        if let cachedResponse = realmManager.fetchDataFromDB(searchText: searchText, offset: gpsOffset),
            let jsonData = cachedResponse.responseJSON.data(using: .utf8) {
            
            let result = try? JSONDecoder().decode(BaseResultModel.self, from: jsonData)
            let actualValue = result?.query.pages
            completionHandler(actualValue, .success)
        }
        
        else {
            AF.request(urlToSearch)
                .responseJSON { response in
                    guard let data = response.data else {
                        completionHandler(nil, .failure)
                        return
                    }
                    
                    let responseString = String(data: data, encoding: .utf8)
                    if let responseString = responseString {
                        self.realmManager.saveResponseToDB(searchText: searchText, offset: gpsOffset, responseString: responseString)
                    }

                    let result = try? JSONDecoder().decode(BaseResultModel.self, from: data)
                    let pages = result?.query.pages

                    guard !(pages?.isEmpty ?? true) else {
                        completionHandler(nil, .failure)
                        return
                    }

                    completionHandler(pages, .success)
            }
        }
        
    }
    
    func fetchPageURL(pageid: Int, completionHandler: @escaping (String?, NetworkError) -> ()) {
        let url = Constants.baseURL + Constants.pageQuery +  "pageids=\(pageid)"
        
        AF.request(url).responseJSON { response in
            guard let data = response.data else {
                completionHandler(nil, .failure)
                return
            }
            let jsonData = try! JSONDecoder().decode(BasePageModel.self, from: data)
            let pageURL = jsonData.query.pages["\(pageid)"]?.fullurl
            
            guard !(pageURL?.isEmpty ?? true) else {
                completionHandler(nil, .failure)
                return
            }
            
            completionHandler(pageURL, .success)
        }
    }
}


