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
//        title = "Платежи"
        view.backgroundColor = .white
        setupData()
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        reloadData(with: nil)
        loadLastPhonePayments()
        loadLastPayments()
    }
    
    func setupData() {
        payments = MockItems.returnPayments()
        transfers = MockItems.returnTransfers()
        pay = MockItems.returnPay()
    }
    
    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Название категории, ИНН"
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(UIImage(named: "scanCard")?.withTintColor(.black), for: .bookmark, state: .normal)
        searchController.searchBar.backgroundColor = .white
        
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.backgroundColor = .white
        view.addSubview(collectionView)
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        
        collectionView.register(PaymentsCell.self, forCellWithReuseIdentifier: PaymentsCell.reuseId)
        collectionView.register(TransferCell.self, forCellWithReuseIdentifier: TransferCell.reuseId)
        collectionView.register(PayCell.self, forCellWithReuseIdentifier: PayCell.reuseId)
        
        collectionView.isScrollEnabled = false
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
                completion(nil, model.errorMessage)
            }
        }
    }
}
