//
//  WineListTableViewCell.swift
//  Project_W
//
//  Created by jun lee on 10/23/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import UIKit

class WineListTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var grapeTypeLabel: UILabel!
    @IBOutlet weak var vineyardLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var labelImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
