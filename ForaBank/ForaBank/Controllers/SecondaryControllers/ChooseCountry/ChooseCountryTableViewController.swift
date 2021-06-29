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
    private var countries = [Country]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var searchedCountry = [Country]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var searching = false
    
    var modalPresent: Bool? = false
    var didChooseCountryTapped: ((Country) -> Void)?
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let nib = UINib(nibName: "СountryCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: СountryCell.reuseId)
        
        loadCountries()
    }

    //MARK: - API
    private func loadCountries() {
        if let countries = Country.countries {
            self.configureVC(with: countries)
        } else {
            
            guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let filePath = documentsDirectoryUrl.appendingPathComponent("CountriesList.json")
            
            // Read data from .json file and transform data into an array
            do {
                let data = try Data(contentsOf: filePath, options: [])
                
                let list = try JSONDecoder().decode(GetCountriesDataClass.self, from: data)
                
                guard let countries = list.countriesList else { return }
                Country.countries = countries
                self.configureVC(with: countries)
                
            } catch {
                print(error)
            }
        }
    }
    
    private func configureVC(with countries: [CountriesList]) {
        for country in countries {
            if !(country.paymentSystemIDList?.isEmpty ?? true) {
                let name = country.name?.capitalizingFirstLetter()
                let countryViewModel = Country(name: name, code: country.code, imageSVGString: country.svgImage)
                
                self.countries.append(countryViewModel)
            }
        }
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
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        addCloseButton()
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return countries.count
        if searching {
            return searchedCountry.count
        } else {
            return countries.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: СountryCell.reuseId, for: indexPath) as! СountryCell
        if searching {
            let model = searchedCountry[indexPath.row]
            cell.set(viewModel: model)
        } else {
            let model = countries[indexPath.row]
            cell.set(viewModel: model)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCountry: Country
        if searching {
            selectedCountry = searchedCountry[indexPath.row]
            print(selectedCountry)
        } else {
            selectedCountry = countries[indexPath.row]
            print(selectedCountry)
        }

        self.searchController.searchBar.searchTextField.endEditing(true)
        
        if modalPresent! {
//            let country = countries[indexPath.row]
            didChooseCountryTapped?(selectedCountry)
            self.dismiss(animated: true, completion: nil)
        } else {
            let vc = ContactInputViewController()
            vc.country = selectedCountry
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    
}

//MARK: - UISearchResultsUpdating
extension ChooseCountryTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
//        guard let text = searchController.searchBar.text else { return }


    }
}

//MARK: - UISearchBarDelegate
extension ChooseCountryTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedCountry = countries.filter { $0.name?.lowercased().prefix(searchText.count) ?? "" == searchText.lowercased() }
        searching = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
}


