//
//  MainCollectionViewCell.swift
//  project03
//
//  Created by Tennyson Pinheiro on 10/24/17.
//  Copyright © 2017 Tennyson Pinheiro. All rights reserved.
//

import UIKit
import CoreMotion
import Cosmos
import Firebase

class MainCollectionViewCell: UICollectionViewCell {
    
    //Mark: Layout outlets
    var ref = Database.database().reference()
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cellFrame: UIView!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var itemQty: UILabel!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var wineLabelImage: UIImageView!
    @IBOutlet weak var plusSignButton: UIButton!
    @IBOutlet weak var minusSignButton: UIButton!
    
    // this is where we pass the rating to the cell
    @IBOutlet weak var starRatings: CosmosView!
    
    // MARK: Data outlets
    @IBOutlet weak var photoFrame: UIView!
    //@IBOutlet weak var productSwitch: UISwitch!
    @IBOutlet weak var wineVintage: UITextView!
    
    @IBOutlet weak var wineTitle: UITextView!
    @IBOutlet weak var wineDescription: UITextView!
    @IBOutlet weak var reviewDescription: UITextView!
    @IBOutlet weak var reviewRating: CosmosView!
    
    @IBOutlet weak var bottomPurchaseButton: UIButton!
    @IBOutlet weak var wineTypeColor: UIView!
    
    let motionManager = CMMotionManager()
    var withShadow: Bool?
    var productID: String?
    var scaled: Bool?
    var isFavorite: Bool?
    var winecolor: String?
    var rating: Double?
    var price: NSDecimalNumber?
    var itemStored: item?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // reset favorite
        favoriteIcon.image = UIImage(named: "Love")?.withRenderingMode(.alwaysTemplate)
        favoriteIcon.tintColor = UIColor(red: 0, green: 0, blue:0, alpha: 0.2)
        itemQty.isHidden = true
        plusSignButton.isHidden = true
        minusSignButton.isHidden = true
        wineDescription.text = ""
        reviewDescription.text = ""
        wineTitle.text = ""
        
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        plusSignButton.isHidden = true
        minusSignButton.isHidden = true
        purchaseButton.layer.masksToBounds = false
        purchaseButton.layer.shadowColor = UIColor.darkGray.cgColor
        purchaseButton.layer.shadowOpacity = 0.2
        purchaseButton.layer.shadowRadius = 4
    
        detailsView.isHidden = true
        detailsView.alpha = 0.0
        
        // change favorite icon if its a favorite product
        if isFavorite != nil {
            favoriteIcon.image = UIImage(named: "Love")
        } else {
            favoriteIcon.image = UIImage(named: "Love")?.withRenderingMode(.alwaysTemplate)
            favoriteIcon.tintColor = UIColor(red: 0, green: 0, blue:0, alpha: 0.2)
        }
        

    }
    
    // Executes when AutoLayout executes.
    override func layoutSubviews() {
        super.layoutSubviews()
        photoFrame.layer.cornerRadius = 20
        cellFrame.layer.cornerRadius = 20
        
        //forces shadow mask out.
        cellFrame.layer.masksToBounds = true
        
        //gets shadow mask in for single (1.0) cells.
        shadowConfiguration(status: withShadow ?? false)
    }

    

    @IBAction func loveClicked(_ sender: UIButton) {
        print("favorite")
        if productID != nil {
            let favoriteRef = self.ref.child("UserInfo").child("z7uAqS56pOMoNWCLkotfGnZyUCv1")
            if isFavorite == true {
                //UI
                favoriteIcon.image = UIImage(named: "Love")?.withRenderingMode(.alwaysTemplate)
                favoriteIcon.tintColor = UIColor(red: 0, green: 0, blue:0, alpha: 0.2)
                //FIREBASE: remove from Favorites
                isFavorite = false
                Catalog.sharedInstance.favoritesForLoggedUser = Catalog.sharedInstance.favoritesForLoggedUser?.filter() { $0 != productID }
               
                if Catalog.sharedInstance.favoritesForLoggedUser != nil {
                    if Catalog.sharedInstance.favoritesForLoggedUser!.count > 0 {
                        favoriteRef.updateChildValues(["favorite": Catalog.sharedInstance.favoritesForLoggedUser as Any ])
                    } else {
                        favoriteRef.updateChildValues(["favorite": ["n/a"] as Any ])
                    }
                }

            } else {
                //FIREBASE: add to favorites
                
                isFavorite = true
                if !((Catalog.sharedInstance.favoritesForLoggedUser?.contains(productID!))!) {
                    Catalog.sharedInstance.favoritesForLoggedUser?.append(productID!)
                }
                
                //update in firebase
               favoriteRef.updateChildValues(["favorite": Catalog.sharedInstance.favoritesForLoggedUser as Any ])
                //UI
                favoriteIcon.image = UIImage(named: "Love")
                
            }
        }
    }
    
    func shadowConfiguration(status: Bool) {
        // This disables shadow in views that carry more than one card per row.
        if status == true {
            cellFrame.layer.masksToBounds = false
            cellFrame.layer.shadowColor = UIColor.black.cgColor
            cellFrame.layer.shadowOpacity = 0.37
            cellFrame.layer.shadowRadius = 10
            applyMotionToShadow()
        }
    }
    
    @IBAction func AddToCartButtonClicked(_ sender: UIButton) {
        
        if itemStored != nil {
            
            var newItemToAdd = itemStored!
        
            let qtyAlreadyInCart = (ShopCart.sharedInstance.allItemsInCart[productID!])?.qty ?? 0
        
            newItemToAdd.qty = qtyAlreadyInCart + 1
            newItemToAdd.amount = price
            newItemToAdd.label = productID
            ShopCart.sharedInstance.allItemsInCart[productID!] = newItemToAdd
            //keeping firebase current
            ShopCart.sharedInstance.FireBaseShopcart[productID!] = newItemToAdd.qty
            
            let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                let qtyUpdateFirebaseRef = self.ref.child("UserInfo").child("z7uAqS56pOMoNWCLkotfGnZyUCv1")
                //update in firebase
                qtyUpdateFirebaseRef.updateChildValues(["cart": ShopCart.sharedInstance.FireBaseShopcart as Any ])
                
            }
            
            
            itemQty.text = String(describing: newItemToAdd.qty)
            itemQty.isHidden = false
            minusSignButton.isHidden = false
            plusSignButton.isHidden = false
            animationControl.sharedInstance.addItemToCartAnimation()
            ShopCart.sharedInstance.calculateTheShopCartTotal()
        }
        
       //print(ShopCart.sharedInstance.FireBaseShopcart)
    }
  
    @IBAction func RemoveFromCartButtonClicked(_ sender: UIButton) {
        
        var itemInCart = ShopCart.sharedInstance.allItemsInCart[productID!]
        if itemInCart != nil {
                let qtyAlreadyInCart = (ShopCart.sharedInstance.allItemsInCart[productID!])?.qty ?? 0
                if qtyAlreadyInCart > 0 {
                    itemInCart!.qty = qtyAlreadyInCart - 1
                    ShopCart.sharedInstance.allItemsInCart[productID!] = itemInCart!
                    //keeping firebase current
                    ShopCart.sharedInstance.FireBaseShopcart[productID!] = itemInCart!.qty
                    itemQty.text = String(describing: itemInCart!.qty)
                    if itemInCart!.qty  == 0 {
                        ShopCart.sharedInstance.allItemsInCart.removeValue(forKey: productID!)
                        ShopCart.sharedInstance.FireBaseShopcart.removeValue(forKey: productID!)
                        itemQty.isHidden = true
                        minusSignButton.isHidden = true
                        plusSignButton.isHidden = true
                    }
                } else {
                    ShopCart.sharedInstance.allItemsInCart.removeValue(forKey: productID!)
                    ShopCart.sharedInstance.FireBaseShopcart.removeValue(forKey: productID!)
                    itemQty.isHidden = true
                    minusSignButton.isHidden = true
                    plusSignButton.isHidden = true
                }
            
            if ShopCart.sharedInstance.FireBaseShopcart.count == 0 {
                let qtyUpdateFirebaseRef = self.ref.child("UserInfo").child("fXiQy4jSvDYKd6RVgdKaqOMJXrn1")
                //update in firebase
                qtyUpdateFirebaseRef.updateChildValues(["cart": ["item": 0] as Any ])
            } else {
                let qtyUpdateFirebaseRef = self.ref.child("UserInfo").child("fXiQy4jSvDYKd6RVgdKaqOMJXrn1")
                //update in firebase
                qtyUpdateFirebaseRef.updateChildValues(["cart": ShopCart.sharedInstance.FireBaseShopcart as Any ])
            }
        }
        animationControl.sharedInstance.addItemToCartAnimation()
        ShopCart.sharedInstance.calculateTheShopCartTotal()
      //  print(ShopCart.sharedInstance.FireBaseShopcart)
    }
    
    
    @IBAction func clickedMoreReviews(_ sender: UIButton) {
        //present control with more reviews
    }
    
    
    
    func applyMotionToShadow() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.02
            motionManager.startDeviceMotionUpdates(to: .main, withHandler: { (motion, error) in
                if let motion = motion {
                    
                    let pitch = abs(motion.attitude.pitch * 10) // aka: x-axis
                    let roll = abs(motion.attitude.roll * 10) // aka: y-axis
                    self.cellFrame.layer.shadowOffset = CGSize(width: roll, height: pitch)
                    //self.xLabel.text = pitch.description :: DEBUG OUTLET
                    //self.yLabel.text = roll.description :: DEBUG OUTLET
                }
            })
        }
        
    }
    
    
}
