//
//  Singletons.swift
//  project03
//
//  Created by Tennyson Pinheiro on 10/26/17.
//  Copyright © 2017 Tennyson Pinheiro. All rights reserved.
//

import Foundation
import UIKit

protocol triggerCollectionViewAnimmationsProtocol {
    func splitCellsIntoPairs()
    func cellsShowAsOne()
    func presentShopCart()
    func showHideSearchBar()
    
}

protocol triggerTopMenuBarAnimationsProtocol {
    func fadeInTopBar()
    func fadeOutTopBar()
    func addItemToCartIconChange()
    func removeItemFromCartIconChange()
    func slideBarOutFromTop()
    func slideBarInFromTop()
}

protocol shopCartFunctionsProtocol {
    func calculateShopCart()
}

protocol CatalogControlProtocol {
    func reloadCollectionView()
}

class animationControl {
    static var sharedInstance = animationControl()
    var delegateCollectionAnimation: triggerCollectionViewAnimmationsProtocol?
    var delegateTopBarAnimation: triggerTopMenuBarAnimationsProtocol?
    var topMenuIcons = ["home","search","heart_empty","cart_empty"]
    var showSearchbar = false
    
    private init() {
        
    }
    

    
    func splitCatalogInTwo(){
        delegateCollectionAnimation?.splitCellsIntoPairs()
    }
    
    func resumeCatalogToOne(){
        delegateCollectionAnimation?.cellsShowAsOne()
    }
    
    func presentShopCart(){
        delegateCollectionAnimation?.presentShopCart()
    }
    
    func presentOrHideSeachBar(){
        delegateCollectionAnimation?.showHideSearchBar()
    }
    
    func fadeOutTopMenuBar(){
        delegateTopBarAnimation?.fadeOutTopBar()
    }
    
    func fadeInTopMenuBar(){
        delegateTopBarAnimation?.fadeInTopBar()
    }
    
    
    func addItemToCartAnimation(){
        delegateTopBarAnimation?.addItemToCartIconChange()
    }
    
    func removeItemFromCartAnimation(){
        delegateTopBarAnimation?.removeItemFromCartIconChange()
    }
    
    func slideTopBarOutFromTop(){
        delegateTopBarAnimation?.slideBarOutFromTop()
    }
    
    func slideTopBarInFromTop(){
        delegateTopBarAnimation?.slideBarInFromTop()
    }
}

class ShopCart {
    static var sharedInstance = ShopCart()
    private init() {}
    var delegate: shopCartFunctionsProtocol?
    
    // FIREBASE: get saved shopcart
    var FireBaseShopcart: [String: Int] = [:] // This is the placeholder for the swipe to add system. Replace it by "AllItemsInCart"
    
    // Return of this function is used to create the numbered shopcart item
    func shopCartTotalItems() -> Int {
       
        var totalBottlesInCart: Int = 0
        for i in allItemsInCart.values {
            totalBottlesInCart += i.qty
        }
        return totalBottlesInCart
    }
    
    func shopCartTotalAmount() -> NSDecimalNumber {
        var totalAmount:NSDecimalNumber = 0.0
        
        for item in allItemsInCart.values {
            totalAmount = totalAmount.adding(item.amount ?? 0.0)
        }
        return totalAmount
    }
    
    //THIS IS THE LOCAL SHOPCART - USE ONLY THIS ONE TO SEGUES AND UPDATE FIREBASE
    var allItemsInCart: [String:item] = [:]
    
    func calculateTheShopCartTotal() {
        delegate?.calculateShopCart()
    }
    
}

struct item {
    //needed for applepay
    var itemID: String?
    var label: String? //wineItem.name
    var wineVintage: String?
    var amount: NSDecimalNumber?
    var qty: Int = 0
    var mainImage: UIImage?
    var rating: Double?
    var vendorQty: Int?
    var summary: String?
    var isFavorite: Bool?
    var color: String?
    var review: String?
    var reviewRating: Double? 
    init(itemUniqueID: String) {
        itemID = itemUniqueID
    }
}

class Catalog {
    static var sharedInstance = Catalog()
    private init() {}
    var idFromImage:String = ""
    var delegate: CatalogControlProtocol?
    
    var listOfItemsToPresent: [item] = []
    
    func refreshCatalog(){
        delegate?.reloadCollectionView()
    }
    
    enum CatalogType: Int {
        case Normal=1,Favorite,Shopcart,Rose,Red,White,Price
    }
    
    var favoritesForLoggedUser: [String]?
    
    var catalogPresentation: CatalogType = .Normal
    
    var priceFilter: Double = 125
}
