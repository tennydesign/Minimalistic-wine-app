//
//  ShopMenuViewController.swift
//  project03
//
//  Created by Tenny on 06/11/17.
//  Copyright © 2017 Tennyson Pinheiro. All rights reserved.
//

import UIKit
import PassKit
import Firebase
class ShopMenuViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate, shopCartFunctionsProtocol, UITableViewDataSource {


    var ref = Database.database().reference()
    @IBOutlet weak var vendorReview: UIView!
    @IBOutlet weak var moneySymbolLabel: UILabel!
    @IBOutlet weak var TotalLabel: UILabel!
    @IBOutlet weak var totalDisplayed: UILabel!
    @IBOutlet weak var btnViewApplePay: UIView!
    @IBOutlet weak var vendorReviewsTableView: UITableView!
    
    var paymentRequest: PKPaymentRequest!
    var itemInCart: item?
    var toDisplayAmountInLabel: NSDecimalNumber = 0.00

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ShopCart.sharedInstance.delegate = self
        //setting up the applePayButton
        let button = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: .black)
        button.addTarget(self, action: #selector(self.applePayButtonPressed), for: .touchUpInside)
        button.center = btnViewApplePay.center
        btnViewApplePay.addSubview(button)
        vendorReview.layer.cornerRadius = 20
        vendorReviewsTableView.dataSource = self
        vendorReviewsTableView.rowHeight = 130
        getReviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calculating items in the cart
    func calculateShopCart() {
        //clear the shopcart. Change this fot the current shopcart in firebase.
        //ShopCart.sharedInstance.allItemsInCart = [:]
        var totalforItem: Double = 0.0
        toDisplayAmountInLabel = 0.00

        print("calculated cart again")
        for (_,v) in ShopCart.sharedInstance.allItemsInCart {

            if v.amount != nil {
                totalforItem = (v.amount?.doubleValue)! * Double(v.qty)
            }
            
            toDisplayAmountInLabel = toDisplayAmountInLabel.adding(NSDecimalNumber(value: totalforItem))
        }
        totalDisplayed.text = String(describing: toDisplayAmountInLabel)
    }
    
    //calculate the cart everytime it shows the view
    override func viewWillAppear(_ animated: Bool) {
       // print("view shows")
        calculateShopCart()
        totalDisplayed.text = String(describing: toDisplayAmountInLabel.doubleValue)
    }
    
    override func viewDidAppear(_ animated: Bool) {
           print("view shows")
    }
    
    // Calls the ApplePay API
    @objc func applePayButtonPressed() {
        print("pressed Apple Pay")
        
        //setup Networks and primary config
        let paymentNetworks = [PKPaymentNetwork.amex,PKPaymentNetwork.visa,PKPaymentNetwork.masterCard]
        paymentRequest = PKPaymentRequest()
        paymentRequest.currencyCode = "USD"
        paymentRequest.countryCode = "US"
        paymentRequest.merchantIdentifier = "merchant.Tenny.applePayDemo"
        
        // check if ApplePay is configured in the phone for the user
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks)
        {
            paymentRequest.supportedNetworks = paymentNetworks
            paymentRequest.merchantCapabilities = .capability3DS
            paymentRequest.requiredShippingContactFields = [.postalAddress]
            
            var itemsForPurchase:[item] = []
            for (_,value) in ShopCart.sharedInstance.allItemsInCart
            {
                itemsForPurchase.append(value)
            }
            
            paymentRequest.paymentSummaryItems = self.itemToSell(Items: itemsForPurchase)
            
            
            let sameDayShipping = PKShippingMethod(label: "Same day delivery", amount: 1)
            sameDayShipping.detail = "Delivery is guaranteed for the same day."
            sameDayShipping.identifier = "SameDay"
            let twoDayShipping = PKShippingMethod(label: "Two day delivery", amount: 1)
            twoDayShipping.detail = "Delivered within 2-days."
            twoDayShipping.identifier = "twoDay"
            let freeShipping = PKShippingMethod(label: "Free shipping", amount: 0)
            freeShipping.detail = "Delivered whenever the fuck we want."
            freeShipping.identifier = "freeShipping"
            
            paymentRequest.shippingMethods = [sameDayShipping,twoDayShipping,freeShipping]
            
            let applePayVC = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            applePayVC?.delegate = self
            self.present(applePayVC!, animated: true, completion: nil)
        } else {
            // show an alert saying Apple Pay is not configured
            print("Please setup Apple Pay")
            
        }
        
    }
    
    func itemToSell(Items: [item]) -> [PKPaymentSummaryItem]{
        
        /*
         let wine = PKPaymentSummaryItem(label: "wid09332", amount: 39.99)
         let shippingCost = PKPaymentSummaryItem(label: "Shipping Cost", amount: 4.99)
         let totalAmount = wine.amount.adding(shippingCost.amount)
         let totalPrice = PKPaymentSummaryItem(label: "my wine store", amount: totalAmount)
         */
        
        var wineItem: PKPaymentSummaryItem!
        var shopcartProducts: [PKPaymentSummaryItem] = []
        var totalAmountInCart: NSDecimalNumber = 0.0
        
        // this is the shopcart
        for item in Items {
            for _ in 1...item.qty {
            wineItem = PKPaymentSummaryItem(label: item.label!, amount: item.amount!)
            totalAmountInCart = totalAmountInCart.adding(wineItem.amount)
            shopcartProducts.append(wineItem)
            }
        }
        
        let shippingCost = PKPaymentSummaryItem(label: "Shipping Cost", amount: 1)
        let taxes = PKPaymentSummaryItem(label: "SF Tax", amount: 1)
        let totalAmount = totalAmountInCart.adding(shippingCost.amount).adding(taxes.amount)
        let totalPrice = PKPaymentSummaryItem(label: "Lovely Wine Store", amount: totalAmount)
        shopcartProducts.append(taxes)
        shopcartProducts.append(shippingCost)
        shopcartProducts.append(totalPrice)
        
        
        return shopcartProducts //[wine,shippingCost,totalPrice]
    }
    
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        //completion(PKPaymentRequestShippingMethodUpdate)
    }
    
    
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
        

    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping ((PKPaymentAuthorizationStatus) -> Void)) {
        completion(PKPaymentAuthorizationStatus.success)
        ShopCart.sharedInstance.allItemsInCart = [:]
        ShopCart.sharedInstance.FireBaseShopcart = ["item": 0]
        let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            let qtyUpdateFirebaseRef = self.ref.child("UserInfo").child("fXiQy4jSvDYKd6RVgdKaqOMJXrn1")
            //update in firebase
            qtyUpdateFirebaseRef.updateChildValues(["cart": ShopCart.sharedInstance.FireBaseShopcart as Any ])
            
        }
        print("send notification... you just purchased wines, congrats")

            self.totalDisplayed.text = "0.00"
            self.moneySymbolLabel.text = "$"
            self.TotalLabel.text = "Total"
            self.btnViewApplePay.subviews[0].isHidden = false
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    var reviews = [CustomerReview]()
    func getReviews() {
        let reviewRef = ref.child("CustomerReview").queryOrdered(byChild: "vendorID").queryEqual(toValue: "juntomlee@gmail.com")
        reviewRef.observe(.value, with: { snapshot in
            for item in snapshot.children {
                let reviewItem = CustomerReview(snapshot: item as! DataSnapshot)
                self.reviews.append(reviewItem)
            }
            self.vendorReviewsTableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.vendorReviewsTableView.dequeueReusableCell(withIdentifier: "vendorReviewCell") as! VendorReviewTableViewCell
        
        cell.vendorReview.text = reviews[indexPath.row].review
        return cell
    }
}
