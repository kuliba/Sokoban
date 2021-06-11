//
//  ChooseCountryTableViewController.swift
//  ForaBank
//
//  Created by Mikhail on 05.06.2021.
//

import UIKit

class ChooseCountryTableViewController: UITableViewController {

    //MARK: - Vars
    private let searchController = UISearchController(searchResultsController: nil)
//    private var timer: Timer?
    private var countries = [Сountry]() {
        didSet { tableView.reloadData() }
    }
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let nib = UINib(nibName: "СountryCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: СountryCell.reuseId)

        if let localData = self.readLocalFile(forName: "country") {
            self.countries = self.parse(jsonData: localData)
        }
        
    }

    //MARK: - API
    private func loadCountries() {
        
//        NetworkManager.addRequest(.csrf, [:], [:]) { model, error in
//
//        }
        
    }
    
    //MARK: - SetupUI
    private func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.alwaysBounceVertical = true
        tableView.keyboardDismissMode = .interactive
        navigationItem.title = "Выберете страну"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchResultsUpdater = self
        searchController.automaticallyShowsCancelButton = false
        definesPresentationContext = true
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return countries.count
        }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: СountryCell.reuseId, for: indexPath) as! СountryCell
        
        let model = countries[indexPath.row]
        cell.set(viewModel: model)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ContactInputViewController()
        vc.country = countries[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
}

//MARK: - UISearchResultsUpdating
extension ChooseCountryTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }


    }
}

//MARK: - UISearchBarDelegate
extension ChooseCountryTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        countries = []
    }
}


