//
//  PaymentsViewController.swift
//  ForaBank
//
//  Created by Mikhail on 02.06.2021.
//

import UIKit



class PaymentsViewController: UIViewController {
    

    
    var payments = [PaymentsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.reloadData(with: nil)
            }
        }
    }
    var transfers = [PaymentsModel]()
    var pay = [PaymentsModel]()
    
    let searchContact: NavigationBarUIView = UIView.fromNib()
    
    enum Section: Int, CaseIterable {
        case payments, transfers, pay
        func description() -> String {
            switch self {
            case .payments:
                return "Платежи"
            case .transfers:
                return "Перевести"
            case .pay:
                return "Оплатить"
            }
        }
    }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, PaymentsModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true

        view.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
        
        self.view.addSubview(searchContact)
        searchContact.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 48)
        searchContact.alpha = 0.5
        searchContact.bellIcon.isHidden = true
        setupData()
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        reloadData(with: nil)
        loadLastPhonePayments()
        loadLastPayments()
        loadLastMobilePayments()
        loadAllLastMobilePayments()
//        loadLastGKHPayments()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupData() {
        payments = MockItems.returnPayments()
        transfers = MockItems.returnTransfers()
        pay = MockItems.returnPay()
    }
    
    private func setupSearchBar() {
        
//        navigationController?.navigationBar.barTintColor = .white
//        navigationController?.navigationBar.backgroundColor = .white
//        navigationController?.navigationBar.shadowImage = UIImage()
//        let searchController = UISearchController(searchResultsController: nil)
//        navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = false
//        searchController.hidesNavigationBarDuringPresentation = true
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.automaticallyShowsCancelButton = false
//        searchController.searchBar.delegate = self
//        searchController.searchBar.placeholder = "Название категории, ИНН"
//        searchController.searchBar.showsBookmarkButton = true
//        searchController.searchBar.setImage(UIImage(named: "scanCard")?.withTintColor(.black), for: .bookmark, state: .normal)
//        searchController.searchBar.backgroundColor = .white
        
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
        view.addSubview(collectionView)
        collectionView.anchor(top: searchContact.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        
        collectionView.register(PaymentsCell.self, forCellWithReuseIdentifier: PaymentsCell.reuseId)
        collectionView.register(TransferCell.self, forCellWithReuseIdentifier: TransferCell.reuseId)
        collectionView.register(PayCell.self, forCellWithReuseIdentifier: PayCell.reuseId)
        collectionView!.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        collectionView.isScrollEnabled = true
        collectionView.delegate = self
        
    }
    
    func reloadData(with searchText: String?) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PaymentsModel>()
        
        snapshot.appendSections([.payments, .transfers, .pay])
        snapshot.appendItems(payments, toSection: .payments)
        snapshot.appendItems(transfers, toSection: .transfers)
        snapshot.appendItems(pay, toSection: .pay)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
        collectionView.reloadData()
        
    }
    

}

//MARK: - API
extension PaymentsViewController {
        
    func loadLastPayments() {
        NetworkManager<GetPaymentCountriesDecodableModel>.addRequest(.getPaymentCountries, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let model = model else { return }
                guard let lastPaymentsList = model.data else { return }
                if lastPaymentsList.count > 3 {
                    let payArr = lastPaymentsList.prefix(3)
                    payArr.forEach { lastPayment in
                        let mod = ChooseCountryHeaderViewModel(model: lastPayment)
                        let payment = PaymentsModel(lastCountryPayment: mod)
                        self.payments.append(payment)
                    }
                } else {
                    lastPaymentsList.forEach { lastPayment in
                        let mod = ChooseCountryHeaderViewModel(model: lastPayment)
                        let payment = PaymentsModel(lastCountryPayment: mod)
                        self.payments.append(payment)
                    }
                }
            }
        }
    }
    
    func loadLastPhonePayments() {
        NetworkManager<GetLatestPaymentsDecodableModel>.addRequest(.getLatestPayments, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: LatestPayment: ", model)
            if model.statusCode == 0 {
                guard let lastPaymentsList  = model.data else { return }
                
                if lastPaymentsList.count > 3 {
                    let payArr = lastPaymentsList.prefix(3)
                    payArr.forEach { lastPayment in
                        let payment = PaymentsModel(lastPhonePayment: lastPayment)
                        self.payments.append(payment)
                    }
                } else {
                    lastPaymentsList.forEach { lastPayment in
                        let payment = PaymentsModel(lastPhonePayment: lastPayment)
                        self.payments.append(payment)
                    }
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
//                DispatchQueue.main.async {
//                if model.errorMessage == "Пользователь не авторизован"{
//                    AppLocker.present(with: .validate)
//                }
//                }
            }
        }
    }
    
//    func loadLastGKHPayments() {
//        NetworkManager<GetLatestServicePaymentsDecodableModel>.addRequest(.getLatestServicePayments, [:], [:]) { model, error in
//            if error != nil {
//                print("DEBUG: Error: ", error ?? "")
//            }
//            guard let model = model else { return }
//            print("DEBUG: LatestPayment: ", model)
//            if model.statusCode == 0 {
//                guard let lastPaymentsList  = model.data else { return }
//
//                if lastPaymentsList.count > 3 {
//                    let payArr = lastPaymentsList.prefix(3)
//                    payArr.forEach { lastPayment in
//                        let payment = PaymentsModel(lastGKHPayment: lastPayment)
//                        self.payments.append(payment)
//                    }
//                } else {
//                    lastPaymentsList.forEach { lastPayment in
//                        let payment = PaymentsModel(lastGKHPayment: lastPayment)
//                        self.payments.append(payment)
//                    }
//                }
//            } else {
//                print("DEBUG: Error: ", model.errorMessage ?? "")
////                DispatchQueue.main.async {
////                if model.errorMessage == "Пользователь не авторизован"{
////                    AppLocker.present(with: .validate)
////                }
////                }
//            }
//        }
//    }
    
    func loadLastMobilePayments() {
        NetworkManager<GetLatestMobilePaymentsDecodableModel>.addRequest(.getLatestMobilePayments, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: LatestPayment: ", model)
            if model.statusCode == 0 {
                guard let lastPaymentsList  = model.data else { return }
                
                if lastPaymentsList.count > 3 {
                    let payArr = lastPaymentsList.prefix(3)
                    payArr.forEach { lastPayment in
                        let payment = PaymentsModel(lastMobilePayment: lastPayment)
                        self.payments.append(payment)
                    }
                } else {
                    lastPaymentsList.forEach { lastPayment in
                        let payment = PaymentsModel(lastMobilePayment: lastPayment)
                        self.payments.append(payment)
                    }
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
//                DispatchQueue.main.async {
//                if model.errorMessage == "Пользователь не авторизован"{
//                    AppLocker.present(with: .validate)
//                }
//                }
            }
        }
    }
    
    func loadAllLastMobilePayments() {
        
        let param = ["isPhonePayments": "true", "isCountriesPayments": "true", "isServicePayments": "true", "isMobilePayments": "true"]

        NetworkManager<GetAllLatestPaymentsDecodableModel>.addRequest(.getAllLatestPayments, param, [:]) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: LatestPayment: ", model)
            if model.statusCode == 0 {
                guard let lastPaymentsList  = model.data else { return }
                let payArr = lastPaymentsList.prefix(3)
                payArr.forEach { lastPayment in
                    let payment = PaymentsModel(lastGKHPayment: lastPayment)
                    self.payments.append(payment)
                    
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
//                DispatchQueue.main.async {
//                if model.errorMessage == "Пользователь не авторизован"{
//                    AppLocker.present(with: .validate)
//                }
//                }
            }
        }
    }
    
    
    func getFastPaymentContractList(_ completion: @escaping (_ model: [FastPaymentContractFindListDatum]? ,_ error: String?) -> Void) {
        NetworkManager<FastPaymentContractFindListDecodableModel>.addRequest(.fastPaymentContractFindList, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
                completion(nil, error)
            }
            guard let model = model else { return }
            print("DEBUG: fastPaymentContractFindList", model)
            if model.statusCode == 0 {
                completion(model.data,nil)
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
//                if model.errorMessage == "Пользователь не авторизован"{
//                    AppLocker.present(with: .validate)
//                }
                completion(nil, model.errorMessage)
            }
        }
    }
}
