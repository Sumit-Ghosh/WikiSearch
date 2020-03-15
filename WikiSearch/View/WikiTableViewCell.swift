//
//  WikiTableViewCell.swift
//  WikiSearch
//
//  Created by Sumit Ghosh on 13/03/20.
//  Copyright © 2020 Sumit Ghosh. All rights reserved.
//

import UIKit

class WikiTableViewCell: UITableViewCell {
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellDescriptionLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellImageView.layer.cornerRadius = 5
        cellImageView.clipsToBounds = true
        cellImageView.backgroundColor = .black
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.image = nil
        cellTitleLabel.text = ""
        cellDescriptionLabel.text = ""
    }
}
