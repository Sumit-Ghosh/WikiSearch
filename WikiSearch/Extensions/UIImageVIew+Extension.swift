//
//  UIImageVIew+Extension.swift
//  WikiSearch
//
//  Created by Sumit Ghosh on 15/03/20.
//  Copyright © 2020 Sumit Ghosh. All rights reserved.
//

import Foundation
import Alamofire

extension UIImageView {
    func setImage(with url: String) {
        AF.request(url).responseData { responseData in
            guard let imageData = responseData.data, let image = UIImage(data: imageData) else { return }
            self.image = image
        }
    }
}
