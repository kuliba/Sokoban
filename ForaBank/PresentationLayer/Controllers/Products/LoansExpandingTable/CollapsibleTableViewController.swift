//
//  CollapsibleTableViewController.swift
//  ios-swift-collapsible-table-section
//
//  Created by Yong Su on 5/30/16.
//  Copyright © 2016 Yong Su. All rights reserved.
//

import UIKit

//
// MARK: - View Controller
//
class CollapsibleTableViewController: UITableViewController {
    
    
    var sectionLoans = [LaonSchedules](){
          didSet {
                 tableView.reloadData()
        }
    }
    


      override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
          NetworkManager.shared().getLoansPayment { (success, sectionLoans) in
              if success {
                  self.sectionLoans = sectionLoans ?? []
              }
          }
      }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset.top = 100
        tableView.contentOffset.y = 100
        // Auto resizing the height of the cell
        tableView.contentInset.top = 26
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension
        
        self.title = "Apple Products"
    }
    
}

//
// MARK: - View Controller DataSource and Delegate
//
extension CollapsibleTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionLoans.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionLoans[section].collapsed ? 0 : 1
    }
    
    // Cell
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell: CollapsibleTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CollapsibleTableViewCell ??
             CollapsibleTableViewCell(style: .default, reuseIdentifier: "cell")
         
        let item: LaonSchedules = sectionLoans[indexPath.section]
         
        cell.nameLabel.text = sectionLoans[indexPath.section].actionType
        cell.detailLabel.text = String((item.paymentAmount)!)
        cell.creditPayment.text = String((item.paymentDate)!)
         
         return cell
     }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
        
        header.titleLabel.text = sectionLoans[section].paymentDate
        header.arrowLabel.text = ">"
        header.setCollapsed(sectionLoans[section].collapsed)
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }

}

//
// MARK: - Section Header Delegate
//
extension CollapsibleTableViewController: CollapsibleTableViewHeaderDelegate {
    
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int) {
        let collapsed = !sectionLoans[section].collapsed
        
        // Toggle collapse
        sectionLoans[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
    
}
