//
//  ProductAboutViewController.swift
//  ForaBank
//
//  Created by Бойко Владимир on 06/09/2019.
//  Copyright © 2019 BraveRobin. All rights reserved.
//

import UIKit
import Foundation


class LoanPaymentScheduleController: UITableViewController {

    var items: [LaonSchedules]?

//    func set(card: Card?) {
//        self.card = card
//        if startDateLabel != nil {
//            updateTable()
//        }
//    }

    override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
          NetworkManager.shared().getLoansPayment { (success, items) in
              if success {
                  self.items = items ?? []
              }
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
        return items?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        //let item = items?[indexPath.item]

  

        return cell
    }
}
