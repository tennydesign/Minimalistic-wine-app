//
//  CustomerListTableViewController.swift
//  Project_W
//
//  Created by jun lee on 11/7/17.
//  Copyright © 2017 jun lee. All rights reserved.
//

import UIKit
import Firebase

class CustomerListTableViewController: UITableViewController {
    @IBAction func signOutButton(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Goodbye!")
        } catch let signOutError {
            print("Error signing out: %@", signOutError)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    let ref = Database.database().reference()
    var reviews = [CustomerReview]()
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib.init(nibName: "CustomerListTableViewCell", bundle: nil), forCellReuseIdentifier: "customerCell")
        
        //FIREBASE//
        let reviewRef = ref.child("CustomerReview").queryOrdered(byChild: "vendorID").queryEqual(toValue: User.sharedInstance.email)
        reviewRef.observe(.value, with: { snapshot in
            print(User.sharedInstance.uid)
            print(snapshot.childrenCount)
            var newItems: [CustomerReview] = []
            for item in snapshot.children {
                let reviewItem = CustomerReview(snapshot: item as! DataSnapshot)
                newItems.append(reviewItem)
            }
            self.reviews = newItems
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reviews.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerCell", for: indexPath) as! CustomerListTableViewCell

        cell.customerIDLabel.text = reviews[indexPath.row].customerID
        cell.customerReviewLabel.text = reviews[indexPath.row].review
        return cell
    }
}
