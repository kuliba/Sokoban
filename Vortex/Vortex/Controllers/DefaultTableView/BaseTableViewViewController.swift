//
//  BaseTableViewViewController.swift
//  Vortex
//
//  Created by Дмитрий on 03.08.2021.
//

import UIKit



protocol MyProtocol: AnyObject {
    func sendData(kpp: String, name: String)
}

class BaseTableViewViewController: UITableViewController {
    
    //MARK: - Vars
    let headerReuseIdentifier = "CustomHeaderView"
    private let searchController = UISearchController(searchResultsController: nil)
//    private var timer: Timer?
    var banks = [SuggestCompanyDatum]()
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
    var delegate: MyProtocol?

    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.estimatedRowHeight = 68.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        let nib = UINib(nibName: "BaseTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: BaseTableViewCell.reuseId)
        tableView.register(ChooseCountryHeaderView.self, forHeaderFooterViewReuseIdentifier: headerReuseIdentifier)
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
        searchController.searchBar.isHidden = true
        navigationItem.searchController = nil
        definesPresentationContext = true
        inititlizeBarButtons()
    }
    
    func inititlizeBarButtons() {
        
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = .boldSystemFont(ofSize: 16)
        label.text = "Выберите КПП"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        
        let cancelButton = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(onTouchCancelButton))
        
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
                //            vc.configure(with: model.country, byPhone: false)
                vc.vortexSwitchView.bankByPhoneSwitch.isOn = false
                vc.vortexSwitchView.bankByPhoneSwitch.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                vc.vortexSwitchView.bankByPhoneSwitch.thumbTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                vc.nameField.text = model.firstName!
                vc.surnameField.text = model.surName!
                vc.secondNameField.text = model.middleName!
                vc.phoneField.text = model.phoneNumber!
            }
        } else {
            if model.phoneNumber != nil {
                vc.configure(with: model.country, byPhone: true)
                vc.selectedBank = model.bank
                let mask = StringMask(mask: "+000-0000-00-00")
                let maskPhone = mask.mask(string: model.phoneNumber)
                vc.phoneField.text = maskPhone ?? ""
            } else if model.firstName != nil, model.middleName != nil, model.surName != nil {
                vc.configure(with: model.country, byPhone: false)
                vc.nameField.text = model.firstName!
                vc.surnameField.text = model.surName!
                vc.secondNameField.text = model.middleName!
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func onTouchCancelButton() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return countries.count
            return banks.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 100
        return lastPaymentsList.count > 0 ? 100 : 0
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 116
//    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier) as! ChooseCountryHeaderView
        headerView.lastPaymentsList = lastPaymentsList
        headerView.didChooseCountryHeaderTapped = { (model) in
            self.openCountryPaymentVC(model: model)
        }
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BaseTableViewCell.reuseId, for: indexPath) as! BaseTableViewCell
        cell.nameCompany.text = banks[indexPath.row].value?.description
        cell.kppLabel.text = banks[indexPath.row].data?.kpp
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.sendData(kpp: banks[indexPath.row].data?.kpp ?? "", name: banks[indexPath.row].value ?? "")
        self.navigationController?.popViewController(animated: true)
    }

    
}

//MARK: - UISearchResultsUpdating
extension BaseTableViewViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
//        guard let text = searchController.searchBar.text else { return }


    }
}

//MARK: - UISearchBarDelegate
extension BaseTableViewViewController: UISearchBarDelegate {
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


