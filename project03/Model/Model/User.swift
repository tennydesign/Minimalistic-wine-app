//
//  User.swift
//  Project_W
//
//  Created by jun lee on 10/26/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import Foundation
import Firebase

class User {
    static var sharedInstance = User()
    
    var uid = ""
    var email = ""
    var zipcode = ""
    
    private init() {
        
    }
    
    init(authData: User) {
        uid = authData.uid
        email = authData.email
        zipcode = authData.zipcode
    }
    
    init(uid: String, email: String, zipcode: String) {
        self.uid = uid
        self.email = email
        self.zipcode = zipcode
    }
}
