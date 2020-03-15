//
//  UITableView+Extension.swift
//  WikiSearch
//
//  Created by Sumit Ghosh on 15/03/20.
//  Copyright © 2020 Sumit Ghosh. All rights reserved.
//

import UIKit

extension UITableView {

    func setBottomInsetForKeyboard(to value: CGFloat) {
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)

        contentInset = edgeInset
        scrollIndicatorInsets = edgeInset
    }
}
