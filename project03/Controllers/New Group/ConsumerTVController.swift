//
//  ConsumerTVController.swift
//  Project_W
//
//  Created by Abhi Singh on 11/6/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class ConsumerTVController: UITableViewController {

    @IBAction func signoutButton(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Goodbye!")
        } catch let signOutError {
            print ("Error signing out: %@", signOutError)
        }
        dismiss(animated: true, completion: nil)
    }
    var wines: [WineInfo] = []
    var user: User!
   var filteredVinos = [WineInfo]()
    //var userZip: ConsumerInfo!
    let ref: DatabaseReference = Database.database().reference(withPath: "Vendor")
    let otherRef: DatabaseReference = Database.database().reference(withPath: "UserInfo")
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        let userId = Auth.auth().currentUser!.uid
        print("@@@@@@!!!!!!: \(userId)")
        
        var consumerZip = "00000"
        
        // using otherRef (ref w/path: UserInfo) to access user's zipcode entry from login (consumerZip)
        otherRef.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                // changing value of consumerZip to user's zipcode : value
                consumerZip = value["zipCode"] as? String ?? ""
                print("!!!!!!@@@@@@@!!!!: \(consumerZip)")
            }
            
            // using ref (w/path: Vendor) to query all vendor uploaded wines based on (toValue) "consumerZip"
            let zipCodeQuery = self.ref.queryOrdered(byChild: "zipcode").queryEqual(toValue: consumerZip)
            zipCodeQuery.observe(.value, with: { snapshot in
                // "zcWines" is an empty array of wines (type "WineInfo")
                var zcWines: [WineInfo] = []
                // iterating each wine in snapshot & appending to "zcWines" empty array
                for wine in snapshot.children {
                    let wineItem = WineInfo(snapshot: wine as! DataSnapshot)
                    zcWines.append(wineItem)
                }
                print("!!!!!!!!!!!!!!!!!!!!!!!!! \(zcWines)")
                // empty "wines" array now set to "zcWines" (filtered zipcode wines) array
                self.wines = zcWines
                self.tableView.reloadData()
            })
        }
    }
    
    
    // MARK: Filters
    
    @IBAction func redFilterButtonPressed(_ sender: UIBarButtonItem) {
        // emptying filteredVinos array, otherwise everytime button is clicked - new items are continuously appended
        filteredVinos = []
        // iterating each wine from "wines" ("wines" is zip-code filtered already)
        for aWine in wines {
            // checking each "aWine's" color type to match red
            if aWine.color == "red" {
                // appending red wine to empty "filteredVinos" array
                filteredVinos.append(aWine)
                //print(filteredVinos)
                // reloading the tableView with all the filtered red wines that're now in "filteredVinos" array
                self.tableView.reloadData()
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        //
        if filteredVinos.isEmpty {
            return wines.count
        } else {
            return filteredVinos.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wineCell", for: indexPath) as! ConsumerTVCell
        
        if filteredVinos.isEmpty {
            let wineItems = wines[indexPath.row]
            
            cell.wineImage.downloadImageFrom(link: wineItems.labelImage) // lazy loading images
            cell.wineName?.text = wineItems.name
            cell.winePrice?.text = String(wineItems.price)
            cell.wineRank?.text = wineItems.rating
            cell.wineSummary?.text = wineItems.summary
            
            return cell
        } else {
            
            let filteredWines = filteredVinos[indexPath.row]
            
            cell.wineImage.downloadImageFrom(link: filteredWines.labelImage)
            cell.wineName?.text = filteredWines.name
            cell.winePrice?.text = String(filteredWines.price)
            cell.wineRank?.text = filteredWines.rating
            cell.wineSummary?.text = filteredWines.summary
            
            return cell
        }
    }
}


// necessary extension for lazy loading images -> tableView
extension UIImageView {
    func downloadImageFrom(link: String)  {
        URLSession.shared.dataTask( with: NSURL(string:link)! as URL, completionHandler: {
            (data, response, error) -> Void in
            if error != nil {
                print("error", error!, Date())
            }
            DispatchQueue.main.async {
                print(#line, "<-Reached")
                self.image = nil
                self.contentMode =  .scaleToFill
                if let data = data {
                    print(#line, #function)
                    self.image = UIImage(data: data)
                }
            }
        }).resume()
    }
}
