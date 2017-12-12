//
//  ConsumerTVCell.swift
//  Project_W
//
//  Created by Abhi Singh on 11/6/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import UIKit

class ConsumerTVCell: UITableViewCell {

    
    @IBOutlet weak var wineImage: UIImageView!
    @IBOutlet weak var wineName: UILabel!
    @IBOutlet weak var winePrice: UILabel!
    @IBOutlet weak var wineRank: UILabel!
    @IBOutlet weak var wineSummary: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
