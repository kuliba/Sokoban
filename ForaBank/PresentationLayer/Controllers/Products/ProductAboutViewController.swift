//
//  ProductAboutViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 06/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import UIKit
import Alamofire

public typealias HTTPHeaders = [String: String]

class ProductAboutViewController: UITableViewController {
  
    private var datedTransactions = [DatedTransactions]()
    struct Location {
        let title: String
        let value: String
        let description: String
        let latitude: Double
        let longitude: Double

        static let locations = [
            Location(title: "something", value: "123", description: "Old.", latitude: 10.11111, longitude: 1.11111),
            Location(title: "something", value: "123", description: "Old.", latitude: 10.11111, longitude: 1.11111),
            Location(title: "something", value: "123", description: "Old.", latitude: 10.11111, longitude: 1.11111)
        ]
    }


    var locationsAll = Location.locations
    var cards: String = ""
    var items: [IAboutItem]?

//    let flattenCollection = [locationsAll, items].joined() // type: FlattenBidirectionalCollection<[Array<Int>]>
//    let flattenArray = Array(flattenCollection)

    

//    func set(card: Card?) {
//        self.card = card
//        if startDateLabel != nil {
//            updateTable()
//        }
//    }


    var airports  = ["YYZ": "Toronto Pearson", "DUB": "Dublin"]
    var airports2 = ["YYZ2": "Toronto Pearson2", "DUB2": "Dublin2", "DUB3": "Dublin123"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.contentInset.top = 35
        tableView.contentInset.bottom = 10
        tableView.backgroundColor = .white
 
        

                
        
        // Uncomment the following line to pre10
        //         serve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollUserInfo = ["tableView": tableView]
        NotificationCenter.default.post(name: NSNotification.Name("TableViewScrolled"), object: nil, userInfo: scrollUserInfo as [AnyHashable: Any])
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        let item = items![indexPath.item]
        cell.backgroundColor = UIColor.white
        cell.tintColor = UIColor.white
        cell.textLabel?.text = item.title ?? ""
        cell.textLabel?.font = UIFont(name: "Roboto-Light", size: 16.0)

        cell.detailTextLabel?.text = item.value ?? ""
        cell.detailTextLabel?.font = UIFont(name: "Roboto", size: 18.0)
        cell.detailTextLabel?.textColor = UIColor(named: "black")
        cell.textLabel?.textColor = UIColor.black
        cell.detailTextLabel?.textColor = UIColor.black


        return cell
    }
}






