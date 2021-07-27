//
//  GKHCityViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 26.07.2021.
//

import UIKit

class GKHCityViewController: UITableViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    var organization = [GetAnywayOperatorsListDatum]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var searchedOrganization = [GetAnywayOperatorsListDatum]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "GHKCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: GHKCell.reuseId)
        self.navigationItem.title = "Выберите город"
        setupUI()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        tableView.reloadData()
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedOrganization.count
        } else {
            return organization.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GHKCell.reuseId, for: indexPath) as! GHKCell
        if searching {
            let model = searchedOrganization[indexPath.row]
            cell.organizationName.text = model.region
        } else {
            let model = organization[indexPath.row]
            cell.organizationName.text = model.region
        }
        return cell
    }
    
    private func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.alwaysBounceVertical = true
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        searchController.searchBar.delegate = self
        definesPresentationContext = true
//        self.closeButton()
        let navImage: UIImage = UIImage()
        let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
        self.navigationItem.backBarButtonItem = customViewItem
    }
    
    func closeButton() {
        self.dismiss(animated: true, completion: nil)
        }

    
    @objc func titleDidTaped() {
        /// Выбор города
        print(#function)
    }

}


extension GKHCityViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedOrganization = organization.filter { $0.region?.prefix(searchText.count) ?? "" == searchText }
        searching = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
}
