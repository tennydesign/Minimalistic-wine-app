//
//  AddItemViewController.swift
//  Project_W
//
//  Created by jun lee on 10/26/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import UIKit
import Firebase
import Foundation

class AddItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: Variables
    var wineData: WineInfo?
    var wineList = [WineInfo]()
    var review: Review?
    var reviewList = [Review]()
    var myImage: UIImage? = #imageLiteral(resourceName: "noImage")
    var picker: UIImagePickerController? = UIImagePickerController()
    var referenceVariable = false
    
    //MARK: Firebase Variables
    var items: [WineInfo] = []
    var ref = Database.database().reference()
    var downloadURL = String()
    var thumbnailURL = String()
    var color = "red" // Default value
    var imageName = String()
    var shortURL = String()
    
    //MARK: TinEye WID
    var WID = "NA"
    
    //MARK: Outlets
    @IBOutlet weak var addItemCollectionView: UICollectionView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var codeText: UITextField!
    @IBOutlet weak var grapeTypeText: UITextField!
    @IBOutlet weak var volumeText: UITextField!
    @IBOutlet weak var priceText: UITextField!
    @IBOutlet weak var zipcodeText: UITextField!
    @IBOutlet weak var regionText: UITextField!
    @IBOutlet weak var vintageText: UITextField!
    @IBOutlet weak var vineyardText: UITextField!
    @IBOutlet weak var summaryText: UITextField!
    @IBOutlet weak var quantityText: UITextField!
    @IBOutlet weak var labelImage: UIImageView!
    @IBOutlet weak var reviewText: UITextField!
    @IBOutlet weak var reviewRatingText: UITextField!
    
    
    @IBOutlet weak var wineSegment: UISegmentedControl!
    @IBOutlet weak var addItemView: UIView!
    @IBOutlet weak var addImageView: UIView!
    @IBOutlet weak var wineScrollView: UIScrollView!
    @IBOutlet weak var addImageButton: UIButton!
    
    //MARK: Actions
    @IBAction func signOutButton(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Goodbye!")
        } catch let signOutError {
            print ("Error signing out: %@", signOutError)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getReview(_ sender: Any) {
        getReviews()
    }
    
    @IBAction func wineColorSegment(_ sender: UISegmentedControl) {
        switch wineSegment.selectedSegmentIndex
        {
        case 0:
            UIView.animate(withDuration: 0.7, animations: { () -> Void in
                self.addImageView.backgroundColor = UIColor(red: 189/255.0, green: 43/255.0, blue: 109/255.0, alpha: 0.5)
                self.color = "red"
            })
        case 1:
            UIView.animate(withDuration: 0.7, animations: { () -> Void in
                self.addImageView.backgroundColor = UIColor(red: 255/255.0, green: 249/255.0, blue: 206/255.0, alpha: 0.7)
                self.color = "white"
            })
        case 2:
            UIView.animate(withDuration: 0.7, animations: { () -> Void in
                self.addImageView.backgroundColor = UIColor(red: 254/255.0, green: 214/255.0, blue: 255/255.0, alpha: 0.7)
                self.color = "rose"
            })
        default:
            break;
        }
    }
    
    @IBAction func submitButton(_ sender: UIButton) {
        getData()
        view.endEditing(true)
    }
    
    @IBAction func addPhotoButton(_ sender: UIButton) {
        let addAlert = UIAlertController(title: "Select Image Source", message: "", preferredStyle: .actionSheet)
        
        addAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
            self.openCamera()
        }))
        
        addAlert.addAction(UIAlertAction(title: "Gallary", style: .default, handler: { (_) in
            self.openGallary()
        }))
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        self.present(addAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Add Item"
        backgroundColorByType()
        // Mockup User Info

        if wineData?.wineType != "" {
            segmentControlPreset()
        }

        labelImage.layer.cornerRadius = 15.0
        labelImage.clipsToBounds = true
        addImageView.layer.cornerRadius = 15.0
        addImageView.clipsToBounds = true
        
        picker?.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        navigationItem.rightBarButtonItem?.isEnabled = false
        //** Load existing data to edit **//
        if wineData?.name != nil {
            navigationItem.title = "Edit Item"
            addImageButton.isHidden = true
            nameText.isUserInteractionEnabled = false
            nameText.backgroundColor = UIColor.clear
            navigationItem.rightBarButtonItem?.isEnabled = true
            navigationItem.leftBarButtonItem = nil
            loadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.labelImage.image = myImage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func segmentControlPreset() {
        switch wineData?.wineType{
        case "Rose Wine"?:
            wineSegment.selectedSegmentIndex = 2
        case "White Wine"?:
            wineSegment.selectedSegmentIndex = 1
        default:
            wineSegment.selectedSegmentIndex = 0
        }
    }
    
    func backgroundColorByType() {
        if wineData?.wineType == "Rose Wine"{
            addImageView.backgroundColor = UIColor(red: 254/255.0, green: 214/255.0, blue: 255/255.0, alpha: 0.7)
        } else if wineData?.wineType == "White Wine" {
            addImageView.backgroundColor = UIColor(red: 255/255.0, green: 249/255.0, blue: 206/255.0, alpha: 0.7)
        } else {
            addImageView.backgroundColor = UIColor(red: 189/255.0, green: 43/255.0, blue: 109/255.0, alpha: 0.5)
        }
    }
    
    func loadData() {
        print("@@@@@@@@@@", wineData?.name, "@@@@@@@@@@")
        guard let currentData = wineData else {
            fatalError()
        }
        nameText.text = currentData.name
        codeText.text = currentData.code
        grapeTypeText.text = currentData.wineType
        volumeText.text = String(currentData.vendorPrice)
        priceText.text = String(currentData.price)
        zipcodeText.text = currentData.zipcode
        regionText.text = currentData.region
        vintageText.text = String(currentData.vintage)
        vineyardText.text = currentData.vineyard
        summaryText.text = currentData.summary
        quantityText.text = String(currentData.quantity)
        reviewText.text = String(currentData.review)
        reviewRatingText.text = String(currentData.reviewRating)
        
        let url = URL(string: currentData.thumbnail)
        let savedImage = try? Data(contentsOf: url!)
        labelImage.image = UIImage(data: savedImage!)
        myImage = UIImage(data: savedImage!)!
        WID = currentData.code
        
        //Ends loading indicator
        progressIndicator(self.view, startAnimate: false)
    }
    
    func getData() {
        let name = nameText.text; if name == "" {
            textFieldAlert("name is missing")
            return
        }
        let code = codeText.text; if code == "" {
            textFieldAlert("Code is missing")
            return
        }
        let wineType = grapeTypeText.text; if wineType == "" {
            textFieldAlert("Wine Type is missing")
            return
        }
        let vendorPrice = volumeText.text; if vendorPrice == "" || Double(vendorPrice!) == nil{
            textFieldAlert("Vendor Price is missing")
            return
        }
        let price = priceText.text; if price == "" || Double(price!) == nil{
            textFieldAlert("Price is missing")
            return
        }
        let zipcode = zipcodeText.text; if zipcode == "" {
            textFieldAlert("Zipcode is missing")
            return
        }
        let region = regionText.text; if region == "" {
            textFieldAlert("Region is missing")
            return
        }
        let vintage = vintageText.text; if vintage == "" || Double(vintage!) == nil{
            textFieldAlert("Vintage is missing")
            return
        }
        let vineyard = vineyardText.text; if vineyard == "" {
            textFieldAlert("Vineyard is missing")
            return
        }
        let summary = summaryText.text; if summary == "" {
            textFieldAlert("Summary is missing")
            return
        }
        let quantity = quantityText.text; if quantity == "" || Double(quantity!) == nil{
            textFieldAlert("Quantity is missing")
            return
        }
        guard labelImage.image != nil else {
            textFieldAlert("Label Image is missing")
            return
        }
        let review = reviewText.text; if review == ""{
            textFieldAlert("Review is missing")
            return
        }
        let reviewRating = reviewRatingText.text; if reviewRating == "" {
            textFieldAlert("Review Rating is missing")
            return
        }
        
        DispatchQueue.main.async {
            print("Data upload start")
            if self.downloadURL == ""{
                self.downloadURL = (self.wineData?.labelImage)!
                self.thumbnailURL = (self.wineData?.thumbnail)!
            }
            //////FIREBASE/////////
            let wineItem = WineInfo(uuid: self.imageName, name: name!, code: code!, wineType: wineType!, vendorPrice: Double(vendorPrice!)!, price: Double(price!)!, zipcode: zipcode!, region: region!, vintage: Int(vintage!)!, vineyard: vineyard!, summary: summary!, quantity: Int(quantity!)!, labelImage: self.downloadURL, thumbnail: self.thumbnailURL, color: self.color, rating: (self.wineData?.rating)!, vendorID: User.sharedInstance.email, review: review!, reviewRating: Double(reviewRating!)!)

            let wineItemRef = self.ref.child("Vendor").child("\(wineItem.code)_\(User.sharedInstance.uid)")
            
            wineItemRef.setValue(wineItem.toAnyObject())

            ///////END////////
            self.resetTextFields()
            self.wineScrollView.setContentOffset(CGPoint(x: 0, y:0), animated: true)
        }
    }
    
    func textFieldAlert(_ segment: String){
        if segment == "Wine not found"{
            let addAlert = UIAlertController(title: "Not Completed", message: "\(segment)", preferredStyle: .actionSheet)
            addAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(addAlert, animated: true, completion: nil)
        } else {
            let addAlert = UIAlertController(title: "Not Completed", message: "\(segment)", preferredStyle: .alert)
            addAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(addAlert, animated: true, completion: nil)
        }
    }
    
    func resetTextFields() {
        nameText.text?.removeAll()
        codeText.text?.removeAll()
        grapeTypeText.text?.removeAll()
        volumeText.text?.removeAll()
        priceText.text?.removeAll()
        zipcodeText.text?.removeAll()
        regionText.text?.removeAll()
        vintageText.text?.removeAll()
        vineyardText.text?.removeAll()
        quantityText.text?.removeAll()
        summaryText.text?.removeAll()
        myImage = #imageLiteral(resourceName: "noImage")
        labelImage.image = myImage
        reviewText.text?.removeAll()
        reviewRatingText.text?.removeAll()
    }
    
    //MARK: Photo (Camera & Gallery)
    func openGallary(){
        picker!.allowsEditing = true
        picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(picker!, animated: true, completion: nil)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker!.allowsEditing = true
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            picker!.cameraCaptureMode = .photo
            present(picker!, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func uploadImage() {
        //Start loading indicator
        progressIndicator(self.view, startAnimate: true)
        imageName = NSUUID().uuidString // Assigned unique ID for image
        
        // Root reference
        let storageRef = Storage.storage().reference()
        
        // Create a reference to 'images/UUID.jpg'
        let wineRef = storageRef.child("\(imageName).jpg")
        
        // Data in memory
        let metadata = StorageMetadata()
        if let data = UIImageJPEGRepresentation(resizeImage(image: myImage!, newWidth: 1280), 0.3){
            metadata.contentType = "image/jpeg"
            wineRef.putData(data, metadata: metadata, completion: { (metadata, error) in
                self.downloadURL = (metadata?.downloadURL()?.absoluteString)!
                if self.codeText.text != self.WID{
                    DispatchQueue.main.async {
//                        if self.referenceVariable == true{
//                            print("f u")
//                        } else {
                            self.shortenURL()
//                        }
                    }
                } else if self.codeText.text == self.WID {
                    DispatchQueue.main.async {
                        print("Assigning Image to imageview")
                        self.labelImage.image = self.myImage
                        self.labelImage.setNeedsDisplay()
                        self.viewWillAppear(true)
                    }
                }
            })
        }
        // Thumbnail
        let wineThumbnailRef = storageRef.child("thumbnail/\(imageName)_small.jpg")
        if let data = UIImageJPEGRepresentation(resizeImage(image: myImage!, newWidth: 300), 0.3){
            metadata.contentType = "image/jpeg"
            wineThumbnailRef.putData(data, metadata: metadata, completion: { (metadata, error) in
                self.thumbnailURL = (metadata?.downloadURL()?.absoluteString)!
            })
        }
        print("Image uploaded")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let photo = info[UIImagePickerControllerOriginalImage] as? UIImage
        myImage = photo!
        uploadImage()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Image Resize
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    // Get reference image from TinEye
    func getReferenceImage(_ wineID: String) {
        print("Reference Image fetching start")
        let credential = "designsprintschool.com:1x49Fr8XXTZa"
        let tinEyeImageURL = "https://\(credential)@wineengine.tineye.com/designsprintschool.com/collection/?filepath=\(WID)"
        let url = URL(string: tinEyeImageURL)
        let savedImage = try? Data(contentsOf: url!)
        myImage = UIImage(data: savedImage!)!
        DispatchQueue.main.async {
            print("Fetching Image uploading start")
            self.uploadImage()
        }
    }
    
    // Check label image to see if it is in our database.
    func checkLabel(){
        let currentImage = shortURL
        let credential = "designsprintschool.com:1x49Fr8XXTZa"
        let urlString = "https://\(credential)@wineengine.tineye.com/designsprintschool.com/rest/search/?url=\(currentImage)"
        let requestUrl = URL(string:urlString)
        let request = URLRequest(url:requestUrl!)

        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else{
                print("HTTP Response error")
                return
            }
            if httpResponse.statusCode != 200 {
                print("Data request failed")
                return
            }
            
            // Process the Response...
            if error == nil,let usableData = data {
                print("JSON Received...File Size: \(usableData) \n")
                //ready for JSONSerialization
                if let stringJSON = String(data: usableData, encoding: String.Encoding.utf8) {
                    // Convert jsonString to jsonObject
                    if let data = stringJSON.data(using: String.Encoding.utf8) {
                        do {
                            let object = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                            if let dictionary = object{
                                if let result = dictionary["result"] as? [[String:AnyObject]]{
                                    for file in result {
                                        if let value = file["filepath"]{
                                            self.WID = (value as! String)
                                            print("@@@@@@@@@@",self.WID, "@@@@@@@@@@")
                                            self.getWineInfo()
                                            self.getReferenceImage(self.WID)
                                            self.referenceVariable = true
                                        }
                                    }
                                    if self.WID == "NA" {
                                        self.progressIndicator(self.view, startAnimate: false)
                                        self.textFieldAlert("Wine not found")
                                    }
                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            } else {
                print("Networking Error: \(String(describing: error))")
            }
        }
        task.resume()
    }
    
    // Pullout wineInfo if label image exists
    func searchWineInfo() {
        var selectedItem: WineInfo?
        
        //Load list of wines from Firebase
        let wineRef = ref.child("Vendor").queryOrdered(byChild: "name").queryEqual(toValue: WID)
        wineRef.observe(.value, with: { snapshot in
            print(snapshot.childrenCount)
            for item in snapshot.children {
                let wineItem = WineInfo(snapshot: item as! DataSnapshot)
                selectedItem = wineItem
                print("++++++++++++++\(selectedItem?.name)+++++++++++++++")
                self.wineData = selectedItem
                self.loadData()
            }
        })
    }
    
    //Shorten URL using tinyURL API
    func shortenURL() {
        let originalURL = downloadURL
        let apikey = ""
        let urlString = "http://tiny-url.info/api/v1/create?url=\(originalURL)&provider=bit_ly&format=json&apikey=\(apikey)"
        let requestUrl = URL(string:urlString)
        let request = URLRequest(url:requestUrl!)

        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            if error == nil,let usableData = data {
                print("JSON Received...File Size: \(usableData) \n")
                //ready for JSONSerialization
                do {
                    let object = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments)
                    if let dictionary = object as? [String:AnyObject]{
                        self.shortURL = dictionary["shorturl"] as! String
                        print("@@@@@@@@@@", self.shortURL, "@@@@@@@@@@")
                        DispatchQueue.main.async {
                            self.checkLabel()
                        }
                    }
                } catch {
                    print("Serialization error")
                }
            } else {
                print("Networking Error: \(String(describing: error) )")
            }
        }
        task.resume()
    }
    
    func getWineInfo(){
        //Wine variables
        var name = String()
        var vintage = String()
        var code = String()
        var wineType = String()
        var avgPrice = String()
        var rank = Double()
        var winery = String()
        var region = String()
        var summary = String()
        
        let apikey = ""
        let urlString = "http://api.snooth.com/wine/?id=\(WID)&akey=\(apikey)"

        let requestUrl = URL(string:urlString)
        let request = URLRequest(url:requestUrl!)
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            
            if error == nil,let usableData = data {
                print("JSON Received...File Size: \(usableData) \n")
                do {
                    // Serialize....
                    let object = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments)
            
                    if let dictionary = object as? [String: AnyObject]{
                        if let wine = dictionary["wines"] as? [[String: AnyObject]]{
                            for item in wine {
                                name = item["name"] as! String
                                vintage = item["vintage"] as! String
                                if Int(vintage) == nil {
                                    vintage = "0"
                                }
                                code = item["code"] as! String
                                avgPrice = item["price"] as! String
                                if item["snoothrank"] as! Double == nil {
                                    rank = 0
                                } else {
                                    rank = item["snoothrank"] as! Double
                                }

                                wineType = item["type"] as! String
                                if item["winery"] == nil{
                                    winery = "n/a"
                                } else {
                                    winery = item["winery"] as! String
                                }
                                region = item["region"] as! String
                                summary = item["wm_notes"] as! String
                                print("name",item["name"])
                                print("vintage", item["vintage"])
                                print("code", item["code"])
                                print("avgPrice", item["price"])
                                print("snoothrank", item["snoothrank"])
                                print("wineType", item["type"])
                                print("winery", item["winery"])
                                print("region", item["region"])
                                print("summary", item["wm_notes"])
                                print("rank", item["snoothrank"])
                            }
                            // Update winedata object
                            self.wineData = WineInfo(uuid: self.imageName, name: name, code: code, wineType: wineType, vendorPrice: Double("0")!, price: Double(avgPrice)!, zipcode: "", region: region, vintage: Int(vintage)!, vineyard: winery, summary: summary, quantity: Int("0")!, labelImage: self.downloadURL, thumbnail: self.thumbnailURL, color: self.color, rating: String(rank), vendorID: User.sharedInstance.email, review: "n/a", reviewRating: 0 )
                        }
                    }
                    DispatchQueue.main.async {
                        self.loadData()
                    }
                    DispatchQueue.global(qos: .background).async {
                        self.getReviews()
                    }
                } catch {
                    print("Error deserializing JSON")
                }
            }
        }
        task.resume()
    }
    
    func getReviews(){
        //Review variables
        var reviewer = String()
        var reviewBody = String()
        var rating = String()
        
        let apikey = ""
        let urlString = "http://api.snooth.com/wine/?id=\(WID)&akey=\(apikey)"
        let requestUrl = URL(string:urlString)
        let request = URLRequest(url:requestUrl!)
        let task = URLSession.shared.dataTask(with: request){
            (data, response, error) in
            
            if error == nil,let usableData = data {
                print("JSON Received...File Size: \(usableData) \n")
                do {
                    // Serialize....
                    let object = try JSONSerialization.jsonObject(with: usableData, options: .allowFragments)
                    
                    if let dictionary = object as? [String: AnyObject]{
                        if let wine = dictionary["wines"] as? [[String: AnyObject]]{
                            for item in wine {
                                if let reviews = item["reviews"] as? [[String:AnyObject]]{
                                    //                                    print("review", reviews)
                                    print(reviews.count)
                                    for review in reviews{
                                        if let  reviewerName = review["name"] {
                                            reviewer = reviewerName as! String
                                        } else {
                                            reviewer = "Anonymous"
                                        }
                                        guard let body = review["body"] else {
                                            return
                                        }
                                        reviewBody = review["body"] as! String
                                        let reviewer1 = reviewer.replacingOccurrences(of: ".", with: "-")
                                        let reviewerID = reviewer1.replacingOccurrences(of: "#", with: "-")
                                        reviewBody = review["body"] as! String
                                        rating = review["rating"] as! String
                                        let currentRating = reviewer1.replacingOccurrences(of: ".", with: "-")
//                                        print(review["name"])
//                                        print(review["body"])
//                                        print(review["rating"])
                                        let reviewData = Review(wineID: self.WID, reviewerID: reviewerID, rating: currentRating, review: reviewBody)
                                        self.reviewList.append(reviewData)
                                    }
                                }
                            }
                        }
                    }
                    // Upload reviews to Firebase
                    if !self.reviewList.isEmpty{
                        for i in 0..<self.reviewList.count{
                            print(self.reviewList[i].wineID, self.reviewList[i].reviewerID)
                            let reviewRef = self.ref.child("Reviews").child("\(self.reviewList[i].wineID)_\(self.reviewList[i].reviewerID)")
                            reviewRef.setValue(self.reviewList[i].toAnyObject())
                        }
                    }
                    self.reviewList = [Review]()
                    // Upload done
                } catch {
                    print("Error deserializing JSON")
                }
            }
        }
        task.resume()
    }
    
    //Custom Activity Indicator
    func progressIndicator(_ viewContainer: UIView, startAnimate:Bool? = true) -> UIActivityIndicatorView {
        let mainContainer: UIView = UIView(frame: viewContainer.frame)
        mainContainer.center = viewContainer.center
        mainContainer.backgroundColor = UIColor.white
        mainContainer.alpha = 0.5
        mainContainer.tag = 789456123
        mainContainer.isUserInteractionEnabled = false
        
        let viewBackgroundLoading: UIView = UIView(frame: CGRect(x:0,y: 0,width: 80,height: 80))
        viewBackgroundLoading.center = viewContainer.center
        viewBackgroundLoading.backgroundColor = UIColor.black
        viewBackgroundLoading.alpha = 0.5
        viewBackgroundLoading.clipsToBounds = true
        viewBackgroundLoading.layer.cornerRadius = 15
        
        let activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x:0.0,y: 0.0,width: 40.0, height: 40.0)
        activityIndicatorView.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        activityIndicatorView.center = CGPoint(x: viewBackgroundLoading.frame.size.width / 2, y: viewBackgroundLoading.frame.size.height / 2)
        if startAnimate!{
            viewBackgroundLoading.addSubview(activityIndicatorView)
            mainContainer.addSubview(viewBackgroundLoading)
            viewContainer.addSubview(mainContainer)
            activityIndicatorView.startAnimating()
        }else{
            for subview in viewContainer.subviews{
                if subview.tag == 789456123{
                    subview.removeFromSuperview()
                }
            }
        }
        return activityIndicatorView
    }
}
