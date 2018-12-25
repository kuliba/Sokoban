//
//  DepositsCardsDetailsAboutViewController.swift
//  ForaBank
//
//  Created by Ilya Masalov (xmasalov@gmail.com) on 29/10/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import UIKit

class DepositsCardsDetailsAboutViewController: UITableViewController, TabCardDetailViewController {
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var avaliableBalanceLabel: UILabel!
    @IBOutlet weak var blockedMoneyLabel: UILabel!
    @IBOutlet weak var updatingDateLabel: UILabel!
    @IBOutlet weak var tariffLabel: UILabel!
    
    var card: Card? = nil

    func set(card: Card?) {
        self.card = card
        if startDateLabel != nil {
            updateTable()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        tableView.contentInset.top = 35
        tableView.contentInset.bottom = 10
        
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
    
    func updateTable() {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yyyy"
        if let startDate = card?.startDate {
            startDateLabel.text = f.string(from: startDate)
        }
        if let expirationDate = card?.expirationDate {
            expirationDateLabel.text = f.string(from: expirationDate)
        }
        let f2 = NumberFormatter()
        f2.numberStyle = .currency
        f2.locale = Locale(identifier: "ru_RU")
        f2.usesGroupingSeparator = true
        f2.currencyGroupingSeparator = " "
        if let availableBalance = card?.availableBalance {
            avaliableBalanceLabel.text = f2.string(from: NSNumber(value: availableBalance))
        }
        if let blockedMoney = card?.blockedMoney {
            blockedMoneyLabel.text = f2.string(from: NSNumber(value: blockedMoney))
        }
        f.dateStyle = .short
        f.locale = Locale(identifier: "ru_RU")
        f.doesRelativeDateFormatting = true
        let f3 = DateFormatter()
        f3.dateFormat = "HH:mm"
        if let updatingDate = card?.updatingDate {
            updatingDateLabel.text = "\(f.string(from: updatingDate)), \(f3.string(from: updatingDate))"
        }
        if let tariff = card?.tariff {
            tariffLabel.text = "\"\(tariff)\""
        }
    }
    // MARK: - Table view data source
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 0
    //    }
    //
    //    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        // #warning Incomplete implementation, return the number of rows
    //        return 0
    //    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
