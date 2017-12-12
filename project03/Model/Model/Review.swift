//
//  Review.swift
//  Project_W
//
//  Created by jun lee on 10/30/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import Foundation
import Firebase

class Review {
    let key: String
    let ref: DatabaseReference?
    var wineID = String()
    var reviewerID = String()
    var rating = String()
    var review = String()
    
    init(wineID: String, reviewerID: String, rating: String, review: String, key: String = "") {
        self.key = key
        self.wineID = wineID
        self.reviewerID = reviewerID
        self.rating = rating
        self.review = review
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        wineID = snapshotValue["wineID"] as! String
        reviewerID = snapshotValue["reviewerID"] as! String
        rating = snapshotValue["rating"] as! String
        review = snapshotValue["review"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "wineID": wineID,
            "reviewerID": reviewerID,
            "rating": rating,
            "review": review,
        ]
    }
}
