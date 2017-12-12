//
//  VendorReviewTableViewCell.swift
//  
//
//  Created by Tenny on 09/11/17.
//

import UIKit

class VendorReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var vendorReview: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
