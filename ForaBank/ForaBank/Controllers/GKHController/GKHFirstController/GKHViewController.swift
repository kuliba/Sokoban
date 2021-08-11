//
//  GKHViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 25.07.2021.
//

import UIKit

class GKHViewController: UITableViewController {
    
    //MARK: - Vars
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var organization = [GetAnywayOperatorsListDatum]() {
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
    var lastPaymentsList = [GetAnywayOperatorsListDatum]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    let headerReuseIdentifier = "CustomHeaderView"
    var searching = false
    var modelDataArray = [AnywayPayment]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        self.view.backgroundColor = .white
        
        setupUI()
        
        let nib = UINib(nibName: "GHKCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: GHKCell.reuseId)
        tableView.register(ChooseCountryHeaderView.self, forHeaderFooterViewReuseIdentifier: headerReuseIdentifier)
        loadCountries()
        loadLastPayments()
//        if !modalPresent {
//            loadLastPayments()
//        }
    }
    
    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))

        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "chevron.down")
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)

        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        let text = NSAttributedString(string: title + " ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16)])
        completeText.append(text)
        completeText.append(attachmentString)
        
        titleLabel.attributedText = completeText
        titleLabel.sizeToFit()

//        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
//        subtitleLabel.backgroundColor = .clear
//        subtitleLabel.textColor = .gray
//        subtitleLabel.font = .systemFont(ofSize: 12)
//        subtitleLabel.text = subtitle
//        subtitleLabel.sizeToFit()
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: titleLabel.frame.size.width, height: 15))
        titleView.addSubview(titleLabel)
//        titleView.addSubview(subtitleLabel)
        
//        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
//
//        if widthDiff < 0 {
//            let newX = widthDiff / 2
//            subtitleLabel.frame.origin.x = abs(newX)
//        } else {
//            let newX = widthDiff / 2
//            titleLabel.frame.origin.x = newX
//        }
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.titleDidTaped))
        titleView.addGestureRecognizer(gesture)
        return titleView
    }
    
    @objc func titleDidTaped() {
        /// Выбор города
        print(#function)
        let vc = GKHCityViewController()
        vc.organization = self.organization
        let nav = UINavigationController(rootViewController: vc)
  //      nav.navigationController?.modalPresentationStyle = .currentContext
        present(nav, animated: true, completion: nil)
        
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupNavBar() {
       
        self.navigationItem.titleView = setTitle(title: "Все", subtitle: "")
        
   //     let navImage: UIImage = system.svgImage?.convertSVGStringToImage() ?? UIImage()
        
  //      let customViewItem = UIBarButtonItem(customView: UIImageView(image: navImage))
  //      self.navigationItem.rightBarButtonItem = customViewItem
        
    }
    
//    //MARK: - API
    private func loadLastPayments() {
        NetworkManager<GetAnywayOperatorsListDecodableModel>.addRequest(.getAnywayOperatorsList, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let model = model else { return }
                guard let lastPaymentsList = model.data else { return }
                self.lastPaymentsList = lastPaymentsList
                lastPaymentsList.forEach { d in
                    if d.name == "Коммунальные услуги и ЖКХ" {
                        d.operators?.forEach({ logotypeList in
                            self.organization.append(logotypeList)
                            
                        })
                    }
                }
            }
        }
    }
    
    
    private func loadCountries() {
//        if let countries = Dict.shared.countries {
//            self.configureVC(with: countries)
//        } else {
//
//            guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//            let filePath = documentsDirectoryUrl.appendingPathComponent("CountriesList.json")
//
//            // Read data from .json file and transform data into an array
//            do {
//                let data = try Data(contentsOf: filePath, options: [])
//
//                let list = try JSONDecoder().decode(GetCountriesDataClass.self, from: data)
//
//                guard let countries = list.countriesList else { return }
//                self.configureVC(with: countries)
//
//            } catch {
//                print(error)
//            }
//        }
    }
    
//    private func configureVC(with countries: [CountriesList]) {
//        for country in countries {
//            if !(country.paymentSystemCodeList?.isEmpty ?? true) {
//                self.organization.append(country)
//            }
//        }
//    }
    //MARK: - SetupUI
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
        addCloseButton()
    }

    private func openCountryPaymentVC(model: ChooseCountryHeaderViewModel) {
        let vc = ContactInputViewController()
        vc.country = model.country
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
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedOrganization.count
        } else {
            return organization.count
        }
    }
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
////        return 100
//        return lastPaymentsList.count > 0 ? 100 : 0
//    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier) as! ChooseCountryHeaderView
//        headerView.lastPaymentsList = lastPaymentsList
//        headerView.didChooseCountryHeaderTapped = { (model) in
//            self.openCountryPaymentVC(model: model)
//        }
//        return headerView
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GHKCell.reuseId, for: indexPath) as! GHKCell
        if searching {
            let model = searchedOrganization[indexPath.row]
            cell.set(viewModel: model)
        } else {
            let model = organization[indexPath.row]
            cell.set(viewModel: model)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCountry: GetAnywayOperatorsListDatum
        if searching {
            selectedCountry = searchedOrganization[indexPath.row]
        } else {
            selectedCountry = organization[indexPath.row]
        }
        self.searchController.searchBar.searchTextField.endEditing(true)
        let puref = selectedCountry.code ?? ""
        var cardNumber = ""
        getCardList() { card, _  in
            
            cardNumber = card?.first?.number ?? ""
            
            let anywayBeginBode = [
                "accountID": "",
                "cardID":"",
                "cardNumber": cardNumber,
                "provider":"",
                "puref": puref,
            
            ] as [String: AnyObject]
            
            NetworkManager<AnywayPaymentBeginDecodebleModel>.addRequest(.anywayPaymentBegin, [:], anywayBeginBode) { model, error in
                if error != nil {
                    print("DEBUG: error", error!)
                } else {
                    NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], [:]) { model, error in
                        if error != nil {
                            print("DEBUG: error", error!)
                        } else {
                            guard let model = model else { return }
                            guard let modelData = model.data else { return }
                            self.modelDataArray.append(modelData)
                            self.modelDataArray.forEach { a in
                                a.listInputs?.forEach({ c in
                                    
                                })
                            }
                            
                            
                            
                            print("AnywayPayment", modelData)

                        }
                    }

                }
            }
            
        }
//            let vc = GKHCityViewController()
//            vc.organization = self.organization
//            self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?, _ error: String?)->()) {
        let param = ["isCard": "true", "isAccount": "false", "isDeposit": "false", "isLoan": "false"]
        
        NetworkManager<GetProductListDecodableModel>.addRequest(.getProductListByFilter, param, [:]) { model, error in
            if error != nil {
                completion(nil, error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                guard let cardList = model.data else { return }
                completion(cardList, nil)
            } else {
                guard let error = model.errorMessage else { return }
                completion(nil, error)
            }
        }
}

}

//MARK: - UISearchBarDelegate
extension GKHViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedOrganization = organization.filter { $0.name?.lowercased().prefix(searchText.count) ?? "" == searchText.lowercased() }
        searching = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
}

