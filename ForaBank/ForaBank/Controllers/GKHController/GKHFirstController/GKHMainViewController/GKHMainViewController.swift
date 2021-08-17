//
//  GKHMViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 15.08.2021.
//

import UIKit
import RealmSwift

class GKHMainViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var searching = false
    let searchController = UISearchController(searchResultsController: nil)
    
    var organization = [GKHOperatorsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var searchedOrganization = [GKHOperatorsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var operatorsList: Results<GKHOperatorsModel>? = nil
    lazy var realm = try? Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "GHKCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: GHKCell.reuseId)
        setupNavBar()
        operatorsList = realm?.objects(GKHOperatorsModel.self)
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.register(
                    GKHMainViewHeader.nib,
                    forHeaderFooterViewReuseIdentifier:
                        GKHMainViewHeader.reuseIdentifier
                )
        self.tableView.register(
                    GKHMainViewFooterView.nib,
                    forHeaderFooterViewReuseIdentifier:
                        GKHMainViewFooterView.reuseIdentifier
                )
        
    }
    
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      guard let footerView = self.tableView.tableFooterView else {
        return
      }
      let width = self.tableView.bounds.size.width
      let size = footerView.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height))
      if footerView.frame.size.height != size.height {
        footerView.frame.size.height = size.height
        self.tableView.tableFooterView = footerView
      }
    }

}

