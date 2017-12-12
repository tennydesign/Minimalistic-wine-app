//
//  MainCollectionViewController.swift
//  project03
//
//  Created by Tennyson Pinheiro on 10/24/17.
//  Copyright © 2017 Tennyson Pinheiro. All rights reserved.
// SFixing not showing qty on shopcart
// Fix search shit

import UIKit
import CTSlidingUpPanel
import Firebase

class MainCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout,triggerCollectionViewAnimmationsProtocol, CTBottomSlideDelegate, UISearchBarDelegate, CatalogControlProtocol {


    

    @IBOutlet weak var wineSearch: UISearchBar!
    //DB reference
    var ref = Database.database().reference()
    var listOfItemsToPresent: [item] = []
    var wineList = [WineInfo]()
    var itemArrayForCollectionView = [item]()
    var listOfLabel = [String:UIImage]()
    var CurrentIteminDetailViewMode: IndexPath?
    var selectedCellIndex: IndexPath?
    var itemsCount : CGFloat?
    var isShopCartView: Bool?
    var screenWidthForMenu: CGFloat?
    var screenHeightForMenu: CGFloat?
    var bottomMenuRect: CGRect?
    var bottomController:CTBottomSlideController?
    var shopBottomController:CTBottomSlideController?
    var isSearching: Bool = false
    var cellWasClicked: Bool = false
    
    var showSearch = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
  
        // Register cell classes
        self.collectionView?.register(UINib(nibName: "MainCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MainCollectionViewCell")
        collectionView?.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "searchCellID")
        
        // load up the animation control delegate
        animationControl.sharedInstance.delegateCollectionAnimation = self
        Catalog.sharedInstance.delegate = self
   
        //wineSearch.delegate = self as UISearchBarDelegate
        
        
        // Grab screen coordinates for prepping UX elements.
        let screenSize = UIScreen.main.bounds
        screenWidthForMenu = screenSize.width
        screenHeightForMenu = screenSize.height - 70.0
        bottomMenuRect = CGRect(x: 0.0, y: screenHeightForMenu!, width: 414.0, height: 70.0)
        
        
         // Set the collectionview insets.
        self.collectionView?.contentInset = UIEdgeInsetsMake(80, 0, 40, 0)
        self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 0, 0)
     
 
        createMenuBars()

        // prepare swipe gestures.
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeToAddToCart))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeToRemoveFromCart))
        
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.collectionView?.addGestureRecognizer(swipeRight)
        
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.collectionView?.addGestureRecognizer(swipeLeft)
    
        // Trigger the explainer animation for the pullup menu
        
        self.view.subviews[2].bounce()
        
        
        // Fetch the catalog
        getCurrentCatalogInFirebase()
        

    }
    
    func reloadCollectionView() {
        
        switch Catalog.sharedInstance.catalogPresentation {
        case .Normal:
            
            if isSearching == false {
                listOfItemsToPresent = Catalog.sharedInstance.listOfItemsToPresent
            }
             isShopCartView = false
            if Catalog.sharedInstance.idFromImage != "" {
                let widFromImage = Catalog.sharedInstance.idFromImage
                listOfItemsToPresent = listOfItemsToPresent.filter({ $0.itemID!.lowercased().contains(widFromImage.lowercased()) })
                Catalog.sharedInstance.idFromImage = ""
            }
            self.view.subviews[2].isHidden = false
            self.view.subviews[3].isHidden = true
            collectionView?.reloadData()
            
            
        case .Favorite:
             CurrentIteminDetailViewMode = nil
            isShopCartView = false
            var favoritesOnly:[item] = []
            for item in Catalog.sharedInstance.listOfItemsToPresent {
                if (Catalog.sharedInstance.favoritesForLoggedUser?.contains(item.itemID!))! {
                    favoritesOnly.append(item)
                }
            }
            self.view.subviews[2].isHidden = false
            self.view.subviews[3].isHidden = true
            listOfItemsToPresent = favoritesOnly
            
            self.collectionView?.performBatchUpdates(
                {
                    self.collectionView?.reloadSections(NSIndexSet(index: 0) as IndexSet)
            }, completion: { (finished:Bool) -> Void in
            })
            
        case .Shopcart:
             CurrentIteminDetailViewMode = nil
            listOfItemsToPresent = Array(ShopCart.sharedInstance.allItemsInCart.values)
            isShopCartView = true
            self.view.subviews[3].isHidden = false
            self.view.subviews[2].isHidden = true

            self.collectionView?.performBatchUpdates(
                {
                    self.collectionView?.reloadSections(NSIndexSet(index: 0) as IndexSet)
            }, completion: { (finished:Bool) -> Void in
            })
            
        case .Rose:
            CurrentIteminDetailViewMode = nil
            isShopCartView = false
            listOfItemsToPresent = Catalog.sharedInstance.listOfItemsToPresent.filter({ $0.color!.lowercased() == "rose" })
            self.collectionView?.performBatchUpdates(
                {
                    self.collectionView?.reloadSections(NSIndexSet(index: 0) as IndexSet)
            }, completion: { (finished:Bool) -> Void in
                

            })

            
        case .Red:
            isShopCartView = false
             CurrentIteminDetailViewMode = nil
            listOfItemsToPresent = Catalog.sharedInstance.listOfItemsToPresent.filter({ $0.color!.lowercased() == "red" })
            self.collectionView?.performBatchUpdates(
                {
                    self.collectionView?.reloadSections(NSIndexSet(index: 0) as IndexSet)
            }, completion: { (finished:Bool) -> Void in
                
            })
            
        case .White:
             CurrentIteminDetailViewMode = nil
            isShopCartView = false
            listOfItemsToPresent = Catalog.sharedInstance.listOfItemsToPresent.filter({ $0.color!.lowercased() == "white" })
            self.collectionView?.performBatchUpdates(
                {
                    self.collectionView?.reloadSections(NSIndexSet(index: 0) as IndexSet)
            }, completion: { (finished:Bool) -> Void in

            })
        
        
        case .Price:
            isShopCartView = false
             CurrentIteminDetailViewMode = nil
            listOfItemsToPresent = Catalog.sharedInstance.listOfItemsToPresent.filter({ Double(truncating: $0.amount!) <= Catalog.sharedInstance.priceFilter })
            self.collectionView?.performBatchUpdates(
                {
                    self.collectionView?.reloadSections(NSIndexSet(index: 0) as IndexSet)
            }, completion: { (finished:Bool) -> Void in
                
            })
        }


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


 
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath) as! SearchCollectionReusableView
            headerView.slideInFromTop()
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        //toggle and show searchbar.
        if showSearch == false {
            return CGSize(width:0,height:0)
        } else {
            return CGSize(width:50,height:50) //size of your UICollectionReusableView
        }
    }
    
    // MARK: SearchBar
    
 
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
        } else {
            isSearching = true
            listOfItemsToPresent = listOfItemsToPresent.filter({ $0.label!.lowercased().contains(searchText.lowercased()) })

            let when = DispatchTime.now() + 3  // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.collectionView?.reloadData()
            }
            
            
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
      
    }


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        reloadCollectionView()
        self.isSearching = false
        
    }

    // MARK: Main Collection view controls

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
 
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
 
        return listOfItemsToPresent.count //listOfItemsToPresent.count // FIREBASE
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell

        // configure cells to appear, this cancels shadow for 2x2 cells.
         if itemsCount == 2.0 {
            cell.withShadow = false
        } else {
            cell.withShadow = true

        }
        
        
        // FIREBASE: Get WID and wine info
        let wineID = listOfItemsToPresent[indexPath.row].itemID
        cell.itemStored = listOfItemsToPresent[indexPath.row]
        cell.productID = wineID
        
        
        // Favorite from firebase
        if let favoriteCatalog = Catalog.sharedInstance.favoritesForLoggedUser {
            if (favoriteCatalog.contains(wineID!)) {
                cell.favoriteIcon.image = UIImage(named: "Love")
                cell.isFavorite = true
            } else {
                cell.favoriteIcon.image = UIImage(named: "Love")?.withRenderingMode(.alwaysTemplate)
                cell.favoriteIcon.tintColor = UIColor(red: 0, green: 0, blue:0, alpha: 0.2)
                cell.isFavorite = false
            }
        }
        
        cell.wineTitle.text = listOfItemsToPresent[indexPath.row].label
        cell.starRatings.rating = listOfItemsToPresent[indexPath.row].rating ?? 0.0
        cell.starRatings.text = String(listOfItemsToPresent[indexPath.row].rating ?? 0.0)
        cell.reviewRating.rating = listOfItemsToPresent[indexPath.row].rating ?? 0.0
        cell.purchaseButton.setTitle("$\(String(describing: listOfItemsToPresent[indexPath.row].amount!))", for: .normal)
        cell.bottomPurchaseButton.setTitle("$\(String(describing: listOfItemsToPresent[indexPath.row].amount!))", for: .normal)
        cell.price = listOfItemsToPresent[indexPath.row].amount!
        cell.wineVintage.text = listOfItemsToPresent[indexPath.row].wineVintage
        cell.wineDescription.text = listOfItemsToPresent[indexPath.row].summary
  
        
        // QTY in the bottom: toggle on and off
       if let itemIsInCart = ShopCart.sharedInstance.allItemsInCart[listOfItemsToPresent[indexPath.row].itemID!]
      {
            
            // this is to toggle visibility of the bottom qty indicator when qty > 0
            if itemIsInCart.qty > 0 {
                cell.itemQty.text = String(describing: itemIsInCart.qty)
                cell.plusSignButton.isHidden = false
                cell.minusSignButton.isHidden = false
                cell.itemQty.isHidden = false
            }
        }
        
        cell.reviewDescription.text = listOfItemsToPresent[indexPath.row].review
        cell.reviewRating.rating = listOfItemsToPresent[indexPath.row].reviewRating ?? 0
        
        switch listOfItemsToPresent[indexPath.row].color {
        case "rose"?:
            cell.wineTypeColor.backgroundColor = UIColor(red: 214/255, green: 65/255, blue: 86/255, alpha: 1)
             cell.purchaseButton.backgroundColor = UIColor(red: 214/255, green: 65/255, blue: 86/255, alpha: 1)
            cell.bottomPurchaseButton.backgroundColor = UIColor(red: 214/255, green: 65/255, blue: 86/255, alpha: 1)
        case "white"?: cell.wineTypeColor.backgroundColor = UIColor(red: 70/255, green: 190/255, blue: 188/255, alpha: 1)
            cell.purchaseButton.backgroundColor = UIColor(red: 70/255, green: 190/255, blue: 188/255, alpha: 1)
            cell.bottomPurchaseButton.backgroundColor = UIColor(red: 70/255, green: 190/255, blue: 188/255, alpha: 1)
        case "red"?: cell.wineTypeColor.backgroundColor = UIColor(red: 131/255, green: 30/255, blue: 62/255, alpha: 1)
            cell.purchaseButton.backgroundColor = UIColor(red: 131/255, green: 30/255, blue: 62/255, alpha: 1)
            cell.bottomPurchaseButton.backgroundColor = UIColor(red: 131/255, green: 30/255, blue: 62/255, alpha: 1)
        default:
            cell.wineTypeColor.backgroundColor = UIColor(red: 214/255, green: 65/255, blue: 86/255, alpha: 1)
        }
        

        

        cell.wineLabelImage.image = listOfItemsToPresent[indexPath.row].mainImage
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        //returns cells to natural state before showing. If its open, show the detailsView content. If its closed, hides it.
        if let cell = cell as? MainCollectionViewCell {
            if cell.layer.frame.size.height > 1000 {
                cell.detailsView.isHidden = false
            } else {
                cell.detailsView.isHidden = true
            }
        }

    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let mainCellWidth: CGFloat = 335//335
        let mainCellHeight: CGFloat = 430//430
        var returnSizeForCell: CGSize?
        let defaultSize = CGSize(width: self.view.frame.width - 40/(itemsCount ?? 1.0) - 0, height: mainCellHeight/mainCellWidth * (self.view.frame.width/(itemsCount ?? 1.0) - 0))
        let expandedSize = CGSize(width: self.view.bounds.width - 40 , height: 1049)
        let shopcartSize = CGSize(width: (self.view.frame.width/1.5), height: (mainCellHeight/mainCellWidth) * (self.view.frame.width/1.5))
        
        //this tests if the user actually have selected some cell or not.
        switch self.collectionView?.indexPathsForSelectedItems?.first {
        case .some(indexPath): // yes
            
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell else {
                return defaultSize
            }
            
            if indexPath.row == CurrentIteminDetailViewMode?.row // user clicked in the same cell that was already opened.
            {
                // Retract cell when user clicks area of the expanded cell.
                print("you clicked to close a cell")
                
                //trigger animations.
                animationControl.sharedInstance.slideTopBarInFromTop()
                self.view.subviews[2].fadeInBottomMenu()
                self.view.subviews[3].fadeInBottomMenu()
                
                //clean current item in detailmode
                CurrentIteminDetailViewMode = nil
                
                //hide details
                cell.detailsView.isHidden = true
                cell.scaled = false
                
                //choose to which size return the cell (if shopcart, size is smaller)
                if isShopCartView == false || isShopCartView == nil {
                    returnSizeForCell = defaultSize
                } else {
                    returnSizeForCell = shopcartSize //CGSize(width: (self.view.frame.width/1.5), height: (mainCellHeight/mainCellWidth) * (self.view.frame.width/1.5))
                }
            } else
            {
                
                // user clicked to open a cell when there is one already opened. In case its needed for diff animations
                if CurrentIteminDetailViewMode != nil && cellWasClicked == true{
                    
                    
                    print("you clicked on a diff cell than the one that is open")
                    
                    // subview[2] is bottom menu
                    self.view.subviews[2].fadeOutBottomMenu()
                    
                    // let the system know which one is the current clicked cell.
                    CurrentIteminDetailViewMode = indexPath
                    
                    
                    //loadsubview with product information.
                    cell.detailsView.isHidden = false
                    cell.detailsView.fadeIn()
                    cell.scaled = true
                    self.cellWasClicked = false
                    returnSizeForCell = expandedSize //self.view.bounds.height - 20)
                    
                } else if self.cellWasClicked == true {
                    //loadsubview with product information.
                    cell.detailsView.isHidden = false
                    cell.detailsView.fadeIn()
                    cell.scaled = true
                    returnSizeForCell = expandedSize//self.view.bounds.height * 1.5)
                    // user clicked to open a cell (no previous cell is open)
                    
                    //loadsubview with product information.
                    print("you clicked to open a cell when no other is open")
                    
                    // fade bottom menu
                    if isShopCartView == false || isShopCartView == nil {
                        self.view.subviews[2].fadeOutBottomMenu()
                    } else {
                        self.view.subviews[3].fadeOutBottomMenu()
                    }
                    // fade top menu
                    animationControl.sharedInstance.slideTopBarOutFromTop()
                    self.cellWasClicked = false
                    CurrentIteminDetailViewMode = indexPath
                    
                }
            }
            
        default: // No click event (viewloads)
            //hide details content
            //CurrentIteminDetailViewMode = nil
            if isShopCartView == false || isShopCartView == nil {
                returnSizeForCell = defaultSize
            } else {
                returnSizeForCell = shopcartSize// CGSize(width: (self.view.frame.width/1.5), height: (mainCellHeight/mainCellWidth) * (self.view.frame.width/1.5))
            }
        }
        
       // self.cellWasClicked = false
        return returnSizeForCell ?? defaultSize
    }

    


    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //this animates the selected cell, expanding it to top and back to center

        self.cellWasClicked = true
        collectionView.performBatchUpdates(nil, completion: nil)
        if CurrentIteminDetailViewMode != nil {
            // reconfigures the collectionview to use the area the Top bar is freeing by retracting.
            self.collectionView?.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
            self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(10, 0, 0, 0)
            self.collectionView?.scrollToItem(at: CurrentIteminDetailViewMode!, at: .top, animated: true)
        } else {
            // position it back to co-exist with the topbar
            self.collectionView?.contentInset = UIEdgeInsetsMake(80, 0, 0, 0)
            self.collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 0, 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        }

        
    }
    
    
    // MARK: Shopcart Functionality
    
    @objc func swipeToAddToCart(recognizer: UIGestureRecognizer) {
        
        
        // Detect cell location and turn into an instance of the cell for work.
        if  recognizer.state == UIGestureRecognizerState.ended {
            let swipeLocation = recognizer.location(in: self.collectionView)
            if let swipedIndexPath = collectionView?.indexPathForItem(at: swipeLocation) {
                if let swipedCell = self.collectionView?.cellForItem(at: swipedIndexPath) as? MainCollectionViewCell {

                    // adding to cart
                    if let productID = swipedCell.productID {
                        //old implementation
                        //let itemQtdInCart = ShopCart.sharedInstance.shopcart[productID] ?? 0 // if nil gives it zero.
                        //ShopCart.sharedInstance.shopcart[productID] = itemQtdInCart + 1
                        
                        //new implementation
                        if swipedCell.itemStored != nil {
                            
                            var newItemToAdd = swipedCell.itemStored!
                            
                            //check if item alreayd has it in cart, if not gives it zero qty
                            let qtyAlreadyInCart = (ShopCart.sharedInstance.allItemsInCart[productID])?.qty ?? 0
                            //adds one to the current qty (even if zero, cause the user swiped)
                            newItemToAdd.qty = qtyAlreadyInCart + 1
                            // add product info
                            newItemToAdd.amount = swipedCell.price
                            
                            newItemToAdd.label = productID //swipedCell.label
                            
                            ShopCart.sharedInstance.allItemsInCart[productID] = newItemToAdd
                            print("added: \(newItemToAdd) ")
                            
                            //make firebase current.
                            ShopCart.sharedInstance.FireBaseShopcart[productID] = newItemToAdd.qty
                            animationControl.sharedInstance.addItemToCartAnimation()
                            
                            
                            // this is to trigger the number in the cart animation

                            
                            // this is to show the qty in the footer.
                            swipedCell.itemQty.text = String(describing: newItemToAdd.qty)
                            swipedCell.itemQty.isHidden = false
                            swipedCell.plusSignButton.isHidden = false
                            swipedCell.minusSignButton.isHidden = false
                        }
                        //DispatchQueue.global(qos: .userInteractive).async {

                        //}
                       // DispatchQueue.global(qos: .background).sync {

                       
                            let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
                            DispatchQueue.main.asyncAfter(deadline: when) {
                                let qtyUpdateFirebaseRef = self.ref.child("UserInfo").child("z7uAqS56pOMoNWCLkotfGnZyUCv1")
                                //update in firebase
                                qtyUpdateFirebaseRef.updateChildValues(["cart": ShopCart.sharedInstance.FireBaseShopcart as Any ])
                                
                            }
                        
                          //  DispatchQueue.main.sync {

                                swipedCell.animateCellAfterAdd()
                          //  }
                       // }

                        
                        ShopCart.sharedInstance.calculateTheShopCartTotal()
                    } else {
                        // treats for when the cell is returning a non-existent product ID. (not supposed to happen as each cell is embeded with a WID, maybe failure in the firebase query in cellForRowAt
                    }


                    }
                }
            }
        }
    
    @objc func swipeToRemoveFromCart(recognizer: UIGestureRecognizer) {

        
        // Detect cell location and turn into an instance of the cell for work.
        if  recognizer.state == UIGestureRecognizerState.ended {
            let swipeLocation = recognizer.location(in: self.collectionView)
            if let swipedIndexPath = collectionView?.indexPathForItem(at: swipeLocation) { // this gets the indexpath for a coordinate (CGPoint) in the screen. Neat!
                if let swipedCell = self.collectionView?.cellForItem(at: swipedIndexPath) as? MainCollectionViewCell {
                    if let productID = swipedCell.productID {
                        
                        
                        var itemInCart = ShopCart.sharedInstance.allItemsInCart[productID]
                        
                        // item exists inside shopcart to be removed
                        if itemInCart != nil {
                            
                           
                            
                            // only subtracts if > 0 , avoid going negative
                            if (itemInCart!.qty > 0) {
                                itemInCart!.qty = itemInCart!.qty - 1
                                ShopCart.sharedInstance.allItemsInCart[productID] = itemInCart
                                
                                //make firebase current.
                                ShopCart.sharedInstance.FireBaseShopcart[productID] = itemInCart!.qty
                                
                                
                                swipedCell.itemQty.text = String(describing: itemInCart!.qty)
                                if itemInCart!.qty == 0 {
                                    ShopCart.sharedInstance.allItemsInCart.removeValue(forKey: productID)
                                    ShopCart.sharedInstance.FireBaseShopcart.removeValue(forKey: productID)
                                    swipedCell.itemQty.isHidden = true
                                    swipedCell.plusSignButton.isHidden = true
                                    swipedCell.minusSignButton.isHidden = true
                                    
                                }
                            } else {
                                ShopCart.sharedInstance.allItemsInCart.removeValue(forKey: productID)
                                ShopCart.sharedInstance.FireBaseShopcart.removeValue(forKey: productID)
                                swipedCell.itemQty.isHidden = true
                                swipedCell.plusSignButton.isHidden = true
                                swipedCell.minusSignButton.isHidden = true
                                
                            }
                                swipedCell.animateCellAfterRemove()
                                animationControl.sharedInstance.removeItemFromCartAnimation()
                                ShopCart.sharedInstance.calculateTheShopCartTotal()
                            
                                if ShopCart.sharedInstance.FireBaseShopcart.count == 0 {
                                    let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
                                    DispatchQueue.main.asyncAfter(deadline: when) {
                                    let qtyUpdateFirebaseRef = self.ref.child("UserInfo").child("z7uAqS56pOMoNWCLkotfGnZyUCv1")
                                    //update in firebase
                                    qtyUpdateFirebaseRef.updateChildValues(["cart": ["item": 0] as Any ])
                                    
                                    }
                                } else {
                                    let when = DispatchTime.now() + 1.5 // change 2 to desired number of seconds
                                    DispatchQueue.main.asyncAfter(deadline: when) {
                                        let qtyUpdateFirebaseRef = self.ref.child("UserInfo").child("z7uAqS56pOMoNWCLkotfGnZyUCv1")
                                        //update in firebase
                                        qtyUpdateFirebaseRef.updateChildValues(["cart": ShopCart.sharedInstance.FireBaseShopcart as Any ])
                                        
                                    }
                                }
                            
                            

                            }

                            

                            
                            // this is to trigger the number in the cart animation

                        } else {
                            // treats for when the cell is returning a non-existent product ID. (not supposed to happen as each cell is embeded with a WID, maybe failure in the firebase query in cellForRowAt
                            print("oh.. oh...non-existent productID")
                        }
                    
                }
            }
        }
        
        
    }
    
    //MARK: UX related functions
    
    let topMenuBar: TopMenuBar = {
        let tmb = TopMenuBar()
        return tmb
    }()
    
    
    private func createMenuBars() {
        
        // add top menu bar - self.view.subviews[1]
        view.addSubview(topMenuBar)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: topMenuBar)
        view.addConstraintsWithFormat(format: "V:|[v0(80)]|", views: topMenuBar)
        
        
        // add bottom menu bar -  self.view.subviews[2]
        createBottomMenu()
        createShopCartMenu()
        self.view.subviews[3].isHidden = true //shopcart menu
        
    }
    
    func createShopCartMenu(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let shopBottomMenuBar = storyboard.instantiateViewController(withIdentifier: "shopCartMenu")
        shopBottomMenuBar.view.isOpaque = false
        
        // if you don't add the view controller first functions will not trigger.
        self.addChildViewController(shopBottomMenuBar)
        
        
        view.addSubview(shopBottomMenuBar.view)
        
        
        shopBottomController = CTBottomSlideController(parent: view, bottomView: shopBottomMenuBar.view, tabController: nil, navController: nil, visibleHeight: 60)
        shopBottomController?.setAnchorPoint(anchor: 0.40)
        shopBottomController?.delegate = self as CTBottomSlideDelegate
    }
    
    func createBottomMenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let bottomMenuBar = storyboard.instantiateViewController(withIdentifier: "pullupMenu")
        bottomMenuBar.view.isOpaque = false
        
        // if you don't add the view controller first functions will not trigger.
        self.addChildViewController(bottomMenuBar)
        
        
        view.addSubview(bottomMenuBar.view)
        
        
        bottomController = CTBottomSlideController(parent: view, bottomView: bottomMenuBar.view, tabController: nil, navController: nil, visibleHeight: 54)
        bottomController?.setAnchorPoint(anchor: 0.37)
        bottomController?.delegate = self as CTBottomSlideDelegate
    }
    
    @objc func colorFilterTapped(_ sender: UITapGestureRecognizer) {
        print("rose tapped")
    }
    
    
    func splitCellsIntoPairs() {
        itemsCount = 2.0
        reloadCollectionView() //self.collectionView?.reloadData()
    }
    
    func cellsShowAsOne() {
        itemsCount = 1.0
        reloadCollectionView() // self.collectionView?.reloadData()
    }
    
    func presentShopCart() {
        if isShopCartView == false || isShopCartView == nil  {
            // btn clicked to turn shopcart on. [2] is bottom menu. [3] is shopcart
            self.view.subviews[3].isHidden = false
            self.view.subviews[2].isHidden = true
            isShopCartView = true
            Catalog.sharedInstance.catalogPresentation = .Shopcart
            reloadCollectionView()// self.collectionView?.reloadData()
        } else {
            // btn clicked to turn it off
            self.view.subviews[2].isHidden = false
            self.view.subviews[3].isHidden = true
            isShopCartView = false
            //Catalog.sharedInstance.catalogPresentation = .Normal
            reloadCollectionView()
        }
    }
    
    func showHideSearchBar() {
        if showSearch == true {
            reloadCollectionView()
            showSearch = false
        } else {
            showSearch = true
            reloadCollectionView()
        }
    }
    
    //MARK: Bottom menu delegates

    func didPanelCollapse() {
        
    }
    
    func didPanelExpand() {
        print("expanded")
    }
    
    func didPanelAnchor() {
        
    }
    
    func didPanelMove(panelOffset: CGFloat) {
        
    }
    
    
    func getCurrentCatalogInFirebase() {
        //Load list of wines from Firebase
        
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                print("Connected")
            } else {
                print("Not connected")
            }
        })
 
        let wineRef = ref.child("Vendor").queryOrdered(byChild: "vendorID").queryEqual(toValue: "juntomlee@gmail.com")
        wineRef.observe(.value, with: { snapshot in
            
            //print(snapshot.childrenCount)
            var newItems: [WineInfo] = []
            self.listOfLabel.removeAll()
            
            
            
            for unit in snapshot.children {
                
                
                let wineItem = WineInfo(snapshot: unit as! DataSnapshot)
                newItems.append(wineItem)
                
                let url = URL(string: wineItem.thumbnail)
                let savedImage = try? Data(contentsOf: url!)
                self.listOfLabel[wineItem.code] = UIImage(data: savedImage!)!
               // print(wineItem.name)
                
                var itemToPresent = item(itemUniqueID: wineItem.code)
                itemToPresent.amount = NSDecimalNumber(value: wineItem.vendorPrice)
                
                
                itemToPresent.mainImage = UIImage(data: savedImage!)
                itemToPresent.rating = Double(wineItem.rating)
                //print(itemToPresent.rating)
                itemToPresent.vendorQty = wineItem.quantity
                itemToPresent.label = wineItem.name
                itemToPresent.wineVintage = String(wineItem.vintage)
                itemToPresent.summary = wineItem.summary
                itemToPresent.review = wineItem.review
                itemToPresent.reviewRating = wineItem.reviewRating
                
                
                
                itemToPresent.color = wineItem.color
                
              //  print("This is to Present: \(itemToPresent)")
                Catalog.sharedInstance.listOfItemsToPresent.append(itemToPresent)
                    
                    Catalog.sharedInstance.refreshCatalog()
            }
            
            self.wineList = newItems
            //print("count", self.wineList.count)
            
        
        })
        
        // Initializes ShopCart:
        let shopCartRef = ref.child("UserInfo").queryOrdered(byChild: "email").queryEqual(toValue: "juntomlee@gmail.com")
        shopCartRef.observe(.value, with: { snapshot in
            
            for itemInCart in snapshot.children {
                let shopCartForUser = ConsumerInfo(snapshot: itemInCart as! DataSnapshot)
                ShopCart.sharedInstance.FireBaseShopcart = shopCartForUser.cart
            }

            
            // This updates the local shopcart with the server shopcart for every item that contains qty.
            for item in Catalog.sharedInstance.listOfItemsToPresent {
                var itemToCart = item
                if (Array(ShopCart.sharedInstance.FireBaseShopcart.keys).contains(item.itemID!)) {
                    itemToCart.qty = ShopCart.sharedInstance.FireBaseShopcart[item.itemID!]!
                    ShopCart.sharedInstance.allItemsInCart[item.itemID!] = itemToCart
                }
            }
            
            Catalog.sharedInstance.refreshCatalog()
            animationControl.sharedInstance.addItemToCartAnimation()
        })
        

        
        
        
        //test if the user is logged.
        let favoriteRef = ref.child("UserInfo").queryOrdered(byChild: "email").queryEqual(toValue: "juntomlee@gmail.com")
        //print(User.sharedInstance.email)
        
        // Get all the favorites.
        
        favoriteRef.observe(.value, with: { snapshot in
            
            for item in snapshot.children {
                let favoritesForUser = ConsumerInfo(snapshot: item as! DataSnapshot)
                Catalog.sharedInstance.favoritesForLoggedUser = favoritesForUser.favorite
            }
            Catalog.sharedInstance.refreshCatalog()
        })
        
        // Get all reviews for the vendor.
        
 
    }

    
    
}


