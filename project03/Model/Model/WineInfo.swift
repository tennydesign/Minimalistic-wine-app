//
//  WineInfo.swift
//  Project_W
//
//  Created by jun lee on 10/23/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class WineInfo: NSObject {
    
    let key: String
    let ref: DatabaseReference?
    var uuid = String() //UUID
    var name = String() //Wine name
    var code = String() //Wine specific barcode?
    var wineType = String() //Grape type (If Blend, add detail)
    var vendorPrice = Double() //Volumn of wine bottle
    var price = Double() //In dollars
    var zipcode = String() //Country name (ex: France)
    var region = String() //State in country (ex: Bordeaux)
    var vintage = Int() //Vintage year
    var vineyard = String() //Name of producer
    var summary = String() //Short description
    var quantity = Int() //Quantity
    var labelImage = String() //Label Image (resized version)
    var thumbnail = String() //Thumbnail Image (300x300)
    var color = String() //Wine colour
    var rating = String()
    var vendorID = String() //VendorID
    var review = String()
    var reviewRating = Double()
    
    init(uuid: String, name: String, code: String, wineType: String, vendorPrice: Double, price: Double, zipcode: String, region: String, vintage: Int, vineyard: String, summary: String, quantity: Int, labelImage: String, thumbnail: String, color: String, rating: String, vendorID: String, review: String, reviewRating: Double, key: String = "") {
        self.key = key
        self.uuid = uuid
        self.name = name
        self.code = code
        self.wineType = wineType
        self.vendorPrice = vendorPrice
        self.price = price
        self.zipcode = zipcode
        self.region = region
        self.vintage = vintage
        self.vineyard = vineyard
        self.summary = summary
        self.quantity = quantity
        self.labelImage = labelImage
        self.thumbnail = thumbnail
        self.color = color
        self.vendorID = vendorID
        self.rating = rating
        self.review = review
        self.reviewRating = reviewRating
        self.ref = nil
    }
    // Firebase----------------------
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        uuid = snapshotValue["uuid"] as! String
        name = snapshotValue["name"] as! String
        code = snapshotValue["code"] as! String
        wineType = snapshotValue["wineType"] as! String
        vendorPrice = snapshotValue["vendorPrice"] as! Double
        price = snapshotValue["price"] as! Double
        zipcode = snapshotValue["zipcode"] as! String
        region = snapshotValue["region"] as! String
        vintage = snapshotValue["vintage"] as! Int
        vineyard = snapshotValue["vineyard"] as! String
        summary = snapshotValue["summary"] as! String
        quantity = snapshotValue["quantity"] as! Int
        labelImage = snapshotValue["labelImage"] as! String
        thumbnail = snapshotValue["thumbnail"] as! String
        color = snapshotValue["color"] as! String
        vendorID = snapshotValue["vendorID"] as! String
        rating = snapshotValue["rating"] as! String
        review = snapshotValue["review"] as! String
        reviewRating = snapshotValue["reviewRating"] as! Double
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "uuid": uuid,
            "name": name,
            "code": code,
            "wineType": wineType,
            "vendorPrice": vendorPrice,
            "price": price,
            "zipcode": zipcode,
            "region" : region,
            "vintage" : vintage,
            "vineyard" : vineyard,
            "summary" : summary,
            "quantity" : quantity,
            "labelImage": labelImage,
            "thumbnail" : thumbnail,
            "color" : color,
            "vendorID" : vendorID,
            "rating" : rating,
            "review": review,
            "reviewRating" : reviewRating
        ]
    }
}
