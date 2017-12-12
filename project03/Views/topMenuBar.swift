//
//  topMenuBar.swift
//  project03
//
//  Created by Tennyson Pinheiro on 10/25/17.
//  Copyright © 2017 Tennyson Pinheiro. All rights reserved.
//  Initial position: (0.0, 0.0, 414.0, 100.0)
// rose: UIColor(red: 202/255, green: 26/255, blue: 61/255, alpha: 1)

import UIKit

class TopMenuBar: UIView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, triggerTopMenuBarAnimationsProtocol {

    
   // let originalRect: CGRect = CGRect(x: 0.0, y: 0.0, width: 414.0, height: 100.0)
    
    lazy var collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white //(red: 1, green: 1, blue: 1, alpha: 0.98)
        cv.dataSource = self
        cv.delegate = self
        animationControl.sharedInstance.delegateTopBarAnimation = self
        
        return cv
    }()
    
    let cellId = "cellId"
    var isInCartMode = false
    
    let imageCartFull = ["burger_white","","heart_empty","cart_full"]
    var clickedSection: String?
    
   override init(frame: CGRect) {
    super.init(frame:frame)
    //backgroundColor = UIColor.blue
    
    collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
    
    addSubview(collectionView)
    
    // button c
    addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
    addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
    
    
    
    collectionView.isScrollEnabled = false
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: CollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animationControl.sharedInstance.topMenuIcons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell
        
        cell.imageView.image = UIImage(named: animationControl.sharedInstance.topMenuIcons[indexPath.row])?.withRenderingMode(.alwaysTemplate)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        
        // Menu icon position: 0 - open slide over menu
        if indexPath.row == 0 {
            clickedSection = "home"
            Catalog.sharedInstance.catalogPresentation = .Normal
            Catalog.sharedInstance.refreshCatalog()
        }
        //Menu icon position: 1. Search
        if indexPath.row == 1 && animationControl.sharedInstance.topMenuIcons[indexPath.row] == "search" {
            clickedSection = "search"
            animationControl.sharedInstance.presentOrHideSeachBar()
            
        }
                
        //Menu icon position:2. Favorite icon is clicked
        if indexPath.row == 2 && animationControl.sharedInstance.topMenuIcons[indexPath.row] == "heart_empty" {
            clickedSection = "favorite"
            Catalog.sharedInstance.catalogPresentation = .Favorite
            Catalog.sharedInstance.refreshCatalog() 
        }
                
        //Menu icon position:3. Shopcart is clicked - provisory, will change for navigation
         if (indexPath.row == 3) {
            clickedSection = "shopcart"
            // this below will toggle the button and flag the collection view for the right diplay
            Catalog.sharedInstance.catalogPresentation = .Shopcart
            animationControl.sharedInstance.presentShopCart()
            Catalog.sharedInstance.refreshCatalog()
            ShopCart.sharedInstance.calculateTheShopCartTotal()

        }

    /*
        
         //Switch double / single icons on visualization style chosen.
         if indexPath.row == 1 && animationControl.sharedInstance.topMenuIcons[indexPath.row] == "iconDoubleCell" {
         animationControl.sharedInstance.topMenuIcons[indexPath.row] = "iconSingleCell"
         animationControl.sharedInstance.splitCatalogInTwo()
         let indexPathToUpdate = IndexPath(item: indexPath.item, section: 0)
         
         //avoid the crossing between icons on fade. Comment it to see a weird icon transition
         self.collectionView.cellForItem(at: indexPath)?.fadeOut()
         //update.
         collectionView.reloadItems(at: [indexPathToUpdate])
         // --- switch to double.
         } else if ((indexPath.row == 1) && (animationControl.sharedInstance.topMenuIcons[indexPath.row] == "iconSingleCell")) {
         animationControl.sharedInstance.topMenuIcons[indexPath.item] = "iconDoubleCell"
         animationControl.sharedInstance.resumeCatalogToOne()
         let indexPathToUpdate = IndexPath(item: indexPath.item, section: 0)
         
         //avoid the crossing between icons on fade. Comment it to see a weird icon transition
         self.collectionView.cellForItem(at: indexPath)?.fadeOut()
         //update.
         collectionView.reloadItems(at: [indexPathToUpdate])
         
*/
    }
    
    //MARK: CollectionView layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        // this is controlling the positioning of the icons
        return CGSize(width: (frame.width/CGFloat(animationControl.sharedInstance.topMenuIcons.count)), height: frame.height + 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    //MARK: Animation
    func fadeInTopBar() {
        self.fadeInTopMenu()
    }
    
    func fadeOutTopBar() {
        
        self.fadeOutTopMenu()
        
    }
    
    func slideBarOutFromTop() {
        self.slideOutFromTop()
    }
    
    func slideBarInFromTop() {
        self.slideInFromTop()
    }
    
    private func shakeObject() {
     let indexPath = IndexPath(item: 3, section: 0)
     let swipedCell = (self.collectionView.cellForItem(at: indexPath) as? MenuCell)
     swipedCell?.imageView.blinkLittleCart()
        if ShopCart.sharedInstance.shopCartTotalItems() > 0 {
         swipedCell?.imageView.tintColor = UIColor(red: 202/255, green: 26/255, blue: 61/255, alpha: 1)
        } else {
         swipedCell?.imageView.tintColor = UIColor.black
        }
    }
    
    func addItemToCartIconChange(){
 
        let indexPath = IndexPath(item: 3, section: 0)
        if ShopCart.sharedInstance.shopCartTotalItems() > 0 {
            if ShopCart.sharedInstance.shopCartTotalItems() <= 10 {
            animationControl.sharedInstance.topMenuIcons[indexPath.item] = "cart_full_" + String(ShopCart.sharedInstance.shopCartTotalItems())
            } else {
            animationControl.sharedInstance.topMenuIcons[indexPath.item] = "cart_full_10_plus"
            }
        } else {
            animationControl.sharedInstance.topMenuIcons[indexPath.item] = "cart_empty"
        }
        self.collectionView.reloadItems(at: [indexPath])
        shakeObject()
    }
    
    func removeItemFromCartIconChange() {
        let indexPath = IndexPath(item: 3, section: 0)
        if ShopCart.sharedInstance.shopCartTotalItems() > 0 {
            animationControl.sharedInstance.topMenuIcons[indexPath.item] = "cart_full_" + String(ShopCart.sharedInstance.shopCartTotalItems())
        } else {
            animationControl.sharedInstance.topMenuIcons[indexPath.item] = "cart_empty"
            (self.collectionView.cellForItem(at: indexPath) as? MenuCell)?.imageView.tintColor = UIColor.black
        }
        self.collectionView.reloadItems(at: [indexPath])
        shakeObject()
    }
    
}

// THE CELL
class MenuCell: BaseCell {
    
    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "cart_empty")?.withRenderingMode(.alwaysTemplate)
        //iv.contentMode = .scaleToFill
        iv.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        return iv
    }()
    
    var touchColor: UIColor = UIColor(red: 202/255, green: 26/255, blue: 61/255, alpha: 1) // color when the user touches the icon
    var iconWidth = 25
    var iconHeight = 25
    
    override var isHighlighted: Bool{
        didSet{
            imageView.tintColor = isHighlighted ? touchColor : UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    override var isSelected: Bool{
        didSet{
            imageView.tintColor = isSelected ? touchColor : UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    /* to test
     override var isHighlighted: Bool {
     didSet {
     if isHighlighted {
     UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
     self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
     }, completion: nil)
     } else {
     UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
     self.transform = CGAffineTransform(scaleX: 1, y: 1)
     }, completion: nil)
     }
     }
     }
 */
    
    override func setupViews() {
        super.setupViews()
        
       // backgroundColor = UIColor.yellow
        addSubview(imageView)
        
        //size of the icons
        addConstraintsWithFormat(format: "H:[v0(\(iconWidth))]", views: imageView)
        addConstraintsWithFormat(format: "V:[v0(\(iconHeight))]", views: imageView)
        
        //centering
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
    }

}


// getting rid of the init crazyness

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    func setupViews() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// to normalize use of the swift2 function.
extension UIView{
    func addConstraintsWithFormat(format:String, views: UIView...){
        
        var viewsDictionary = [String:UIView]()
        for (index, view) in views.enumerated(){
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
            
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}


