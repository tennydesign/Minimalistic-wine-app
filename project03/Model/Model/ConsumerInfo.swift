//
//  ConsumerInfo.swift
//
//
//  Created by Abhi Singh on 11/6/17.
//

import Foundation
import FirebaseAuth
import Firebase

class ConsumerInfo {
    
    let uid: String
    let email: String
    var zipCode: String
    var favorite: [String]
    var cart: [String:Int]
    var ref: DatabaseReference
    var key: String
    
    
    init(authData: ConsumerInfo) {
        uid = authData.uid
        email = authData.email
        zipCode = authData.zipCode
        ref = authData.ref
        key = authData.key
        favorite = authData.favorite
        cart = authData.cart
    }
    
    init(uid: String, email: String, ref: DatabaseReference, key: String, zipCode: String, favorite: [String], cart: [String:Int]) {
        self.uid = uid
        self.email = email
        self.zipCode = zipCode
        self.favorite = favorite
        self.cart = cart
        self.ref = ref
        self.key = key
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        ref = snapshot.ref
        let snapshotValue = snapshot.value as! [String: AnyObject]
        zipCode = snapshotValue["zipCode"] as! String
        favorite = snapshotValue["favorite"] as! [String]
        email = snapshotValue["email"] as! String
        uid = snapshotValue["uid"] as! String
        cart = snapshotValue["cart"] as! [String:Int]
    }
    
    func toAnyObject() -> Any {
        return [
            "zipCode": zipCode,
            "email": email,
            "uid": uid,
            "favorite": favorite,
            "cart": cart
        ]
    }
    
}
