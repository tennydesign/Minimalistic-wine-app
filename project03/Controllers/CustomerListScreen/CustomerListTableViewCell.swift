//
//  CustomerListTableViewCell.swift
//  Project_W
//
//  Created by jun lee on 11/7/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import UIKit

class CustomerListTableViewCell: UITableViewCell {

    @IBOutlet weak var customerIDLabel: UILabel!
    @IBOutlet weak var customerReviewLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
