//
//  ChooseCountryTableViewController.swift
//  Vortex
//
//  Created by Mikhail on 05.06.2021.
//

import UIKit

class ChooseCountryTableViewController: UITableViewController {

    //MARK: - Vars
    let headerReuseIdentifier = "CustomHeaderView"
    private let searchController = UISearchController(searchResultsController: nil)
    private let model = Model.shared
    var viewModel: OperatorsViewModel?
    private var countries = [CountriesList]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            var titles = [String]()
            for country in countries {
                titles.append(country.name?.first?.lowercased() ?? "")
            }
            let mySet = Set(titles)
            let myArray = Array(mySet).sorted()
            countriesTitles = myArray
        }
    }
    private var countriesTitles = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var searchedCountry = [CountriesList]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var lastPaymentsList = [GetPaymentCountriesDatum]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var searching = false
    
    var modalPresent: Bool = false
    var didChooseCountryTapped: ((CountriesList) -> Void)?
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let nib = UINib(nibName: "СountryCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: СountryCell.reuseId)
        tableView.register(ChooseCountryHeaderView.self, forHeaderFooterViewReuseIdentifier: headerReuseIdentifier)
        loadCountries()
        if !modalPresent {
            loadLastPayments()
        }
    }

    //MARK: - API
    private func loadLastPayments() {
        NetworkManager<GetPaymentCountriesDecodableModel>.addRequest(.getPaymentCountries, [:], [:]) { model, error in
            if error != nil {
            } else {
                guard let model = model else { return }
                guard let lastPaymentsList = model.data else { return }
                self.lastPaymentsList = lastPaymentsList
            }
        }
    }
    
    
    private func loadCountries() {
        let countries = model.countriesList.value.map { $0.getCountriesList() }
        configureVC(with: countries)
    }
    
    private func configureVC(with countries: [CountriesList]) {
        for country in countries {
            if !(country.paymentSystemCodeList?.isEmpty ?? true) {
                self.countries.append(country)
            }
        }
    }
    //MARK: - SetupUI
    private func setupUI() {
        tableView.tableFooterView = UIView()
        tableView.alwaysBounceVertical = true
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        tableView.sectionIndexColor = #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2705882353, alpha: 1)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        inititlizeBarButtons()
    }
    
    func inititlizeBarButtons() {
        
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = .boldSystemFont(ofSize: 16)
        label.text = modalPresent ? "Выберите страну" : "В какую страну?"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        
        let cancelButton = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(onTouchBackButton))
        
        self.navigationItem.rightBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .highlighted)
    }

    private func openCountryPaymentVC(model: ChooseCountryHeaderViewModel) {
        let vc = ContactInputViewController()
        vc.country = model.country
        if model.country?.code == "TR" {
            
            if model.firstName != nil, model.middleName != nil, model.surName != nil, model.phoneNumber != nil {
                
                vc.typeOfPay = .contact
                vc.foraSwitchView.bankByPhoneSwitch.isOn = false
                vc.foraSwitchView.bankByPhoneSwitch.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                vc.foraSwitchView.bankByPhoneSwitch.thumbTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                vc.nameField.text = model.firstName!
                vc.surnameField.text = model.surName!
                vc.secondNameField.text = model.middleName!
                vc.phoneField.text = model.phoneNumber!
            }
        } else {
            
            if model.phoneNumber != nil {
                
                vc.typeOfPay = .mig
                vc.configure(with: model.country, byPhone: true)
                vc.selectedBank = model.bank
                vc.phoneField.text = "+\(model.phoneNumber ?? "")"
                
            } else if model.firstName != nil, model.middleName != nil, model.surName != nil {
                
                vc.typeOfPay = .contact
                vc.configure(with: model.country, byPhone: false)
                vc.foraSwitchView.bankByPhoneSwitch.isOn = false
                vc.foraSwitchView.bankByPhoneSwitch.layer.borderColor =  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                vc.foraSwitchView.bankByPhoneSwitch.thumbTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                vc.nameField.text = model.firstName!
                vc.surnameField.text = model.surName!
                vc.secondNameField.text = model.middleName!
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func onTouchBackButton() {
        if viewModel != nil {
            viewModel?.closeAction()
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Table view data source
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return countriesTitles
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return countries.count
        if searching {
            return searchedCountry.count
        } else {
            return countries.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 100
        return lastPaymentsList.count > 0 ? 100 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier) as! ChooseCountryHeaderView
        headerView.lastPaymentsList = lastPaymentsList
        headerView.didChooseCountryHeaderTapped = { (model) in
            self.openCountryPaymentVC(model: model)
        }
        return headerView
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
        let selectedCountry: CountriesList
        if searching {
            selectedCountry = searchedCountry[indexPath.row]
        } else {
            selectedCountry = countries[indexPath.row]
        }

        self.searchController.searchBar.searchTextField.endEditing(true)
        
        if modalPresent {
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


