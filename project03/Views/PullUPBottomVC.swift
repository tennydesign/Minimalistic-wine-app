//
//  bottomVC.swift
//  project03
//
//  Created by Tennyson Pinheiro on 11/2/17.
//  Copyright © 2017 Tennyson Pinheiro. All rights reserved.
//

import UIKit
import Firebase

class PullUPBottomVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    @IBOutlet weak var imageSearch: UIImageView!
    var myImage: UIImage? = #imageLiteral(resourceName: "burger")
    @IBOutlet weak var priceSliderLabel: UILabel!
    @IBOutlet weak var viewRed: UIView!
    @IBOutlet weak var viewRose: UIView!
    @IBOutlet weak var viewWhite: UIView!
    @IBOutlet weak var thumbView: UIView!
    @IBOutlet weak var bottomMenuView: UIView!
    @IBOutlet weak var filtersMenu: UIView!
    @IBOutlet weak var priceSlider: UISlider!
    
    var filteringBy: String?
    var backWithImage: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        thumbView.layer.cornerRadius = 10
        thumbView.clipsToBounds = true
        self.view.backgroundColor = UIColor.clear
        priceSliderLabel.text = "$20"

        picker?.delegate = self
        viewRose.backgroundColor = offGreyColor
        viewWhite.backgroundColor = offGreyColor
        viewRed.backgroundColor = offGreyColor
    

    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        priceSliderLabel.text = "$\(Int(sender.value))"
        Catalog.sharedInstance.catalogPresentation = .Price
        let when = DispatchTime.now() + 4  // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            Catalog.sharedInstance.refreshCatalog()
        }
        
    }
    
    @IBAction func signOutUser(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Goodbye!")
        } catch let signOutError {
            print ("Error signing out: %@", signOutError)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func filterbyRose(_ sender: UIButton) {

        if filteringBy == "rose" {
            //disable filters
            Catalog.sharedInstance.catalogPresentation = .Normal
            Catalog.sharedInstance.refreshCatalog()
            viewRose.backgroundColor = offGreyColor
            viewWhite.backgroundColor = offGreyColor
            viewRed.backgroundColor = offGreyColor
            
            filteringBy = ""
            
        } else {
            filteringBy = "rose"
            Catalog.sharedInstance.catalogPresentation = .Rose
            Catalog.sharedInstance.refreshCatalog()
            viewRose.backgroundColor = roseWineColor
            viewRed.backgroundColor = offGreyColor
            viewWhite.backgroundColor = offGreyColor
        }

    }
    @IBAction func filterbyRed(_ sender: UIButton) {

        
        // test if before the click the filter were already activated
        if filteringBy == "red" {
            //disable filters
            Catalog.sharedInstance.catalogPresentation = .Normal
            Catalog.sharedInstance.refreshCatalog()
            viewRose.backgroundColor = offGreyColor
            viewWhite.backgroundColor = offGreyColor
            viewRed.backgroundColor = offGreyColor
            
            filteringBy = ""
            
        } else {
            filteringBy = "red"
            Catalog.sharedInstance.catalogPresentation = .Red
            Catalog.sharedInstance.refreshCatalog()
            viewRed.backgroundColor = redWineColor
            viewRose.backgroundColor = offGreyColor
            viewWhite.backgroundColor = offGreyColor
        }

    }
    
    
    @IBAction func filterbyWhite(_ sender: UIButton) {

        if filteringBy == "white" {
            //disable filters
            Catalog.sharedInstance.catalogPresentation = .Normal
            Catalog.sharedInstance.refreshCatalog()
            viewRose.backgroundColor = offGreyColor
            viewWhite.backgroundColor = offGreyColor
            viewRed.backgroundColor = offGreyColor
            
            filteringBy = ""
            
        } else {
            filteringBy = "white"
            Catalog.sharedInstance.catalogPresentation = .White
            Catalog.sharedInstance.refreshCatalog()
            viewWhite.backgroundColor = whiteWineColor
            viewRed.backgroundColor = offGreyColor
            viewRose.backgroundColor = offGreyColor
        }

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var photoClick: UIButton!
    
    @IBAction func photoClickedByUser(_ sender: UIButton) {
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
    
    
    //PHOTO -
    var picker: UIImagePickerController? = UIImagePickerController()
    var ref = Database.database().reference()
    var storageRef = Storage.storage().reference()
    var imageName: String = ""
    var WID = "NA"
    var shortURL: String = ""
    var downloadURL = String()
    var thumbnailURL = String()
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
        //progressIndicator(self.view, startAnimate: true)
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
                self.imageSearch.image = self.myImage
                self.imageSearch.setNeedsDisplay()
                DispatchQueue.main.async {
                    if self.backWithImage == true {
                        self.backWithImage = false
                    } else {
                        self.shortenURL()
                    }
                }
                
                if self.backWithImage == true {
                    Catalog.sharedInstance.catalogPresentation = .Normal
                    Catalog.sharedInstance.refreshCatalog()
                }
                

              /*  if self.codeText.text != self.WID{
                    DispatchQueue.main.async {
                        self.shortenURL()
                    }
                } else if self.codeText.text == self.WID {
                    DispatchQueue.main.async {
                        print("Assigning Image to imageview")
                        self.imageSearch.image = self.myImage
                        self.imageSearch.setNeedsDisplay()
                        //self.viewWillAppear(true)
                    }
                }*/
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
                                            
                                            Catalog.sharedInstance.idFromImage = self.WID
                                            print("------\(Catalog.sharedInstance.idFromImage)")

                                            
                                            
                                            print("@@@@@@@@@@",self.WID, "@@@@@@@@@@")
                                            self.searchWineInfo()
                                            self.getReferenceImage(self.WID)
                                            self.backWithImage = true
                                        }
                                    }
                                    if self.WID == "NA" {
                                        
                                        //self.progressIndicator(self.view, startAnimate: false)
                                       // self.textFieldAlert("Wine not found")
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
                //self.wineData = selectedItem
                //self.loadData()
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
    
}
