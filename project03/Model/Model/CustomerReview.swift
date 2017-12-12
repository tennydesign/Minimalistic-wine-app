//
//  CustomerReview.swift
//  Project_W
//
//  Created by jun lee on 11/7/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import Foundation
import Firebase

class CustomerReview {
    let key: String
    let ref: DatabaseReference?
    var vendorID = String()
    var customerID = String()
    var review = String()
    
    init(vendorID: String, customerID: String, review: String, key: String = "") {
        self.key = key
        self.vendorID = vendorID
        self.customerID = customerID
        self.review = review
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        vendorID = snapshotValue["vendorID"] as! String
        customerID = snapshotValue["customerID"] as! String
        review = snapshotValue["review"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "vendorID": vendorID,
            "customerID": customerID,
            "review": review,
        ]
    }
}
