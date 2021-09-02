//
//  MainViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 11.08.2021.
//

import UIKit

class MainViewController: UIViewController {
        
        var payments = [PaymentsModel]() {
            didSet {
                DispatchQueue.main.async {
                    self.reloadData(with: nil)
                }
            }
        }
    var productList = [GetProductListDatum](){
        didSet{
            DispatchQueue.main.async {
                self.reloadData(with: nil)
            }
        }
    }
        var transfers = [PaymentsModel](){
            didSet{
                DispatchQueue.main.async {
                    self.reloadData(with: nil)
                }
            }
        }
        var pay = [PaymentsModel](){
            didSet{
                DispatchQueue.main.async {
                    self.reloadData(with: nil)
                }
            }
        }
        var offer = [PaymentsModel](){
            didSet{
                DispatchQueue.main.async {
                    self.reloadData(with: nil)
                }
            }
        }
        var openProduct = [PaymentsModel](){
            didSet{
                DispatchQueue.main.async {
                    self.reloadData(with: nil)
                }
            }
        }
        var branches = [PaymentsModel]()
        var investment = [PaymentsModel]()
        var services = [PaymentsModel]()
    
        let searchContact: NavigationBarUIView = UIView.fromNib()

    
        enum Section: Int, CaseIterable {
            case transfers, payments, pay, offer, openProduct, branches, investment, services
            func description() -> String {
                switch self {
                case .transfers:
                    return "Мои продукты"
                case .payments:
                    return "Предложения"
                case .offer:
                    return "Быстрые операции"
                case .pay:
                    return "Обмен валют"
                case .openProduct:
                    return "Открыть продукт"
                case .branches:
                    return "Отделения и банкоматы"
                case .investment:
                    return "Инвестиции и пенсии"
                case .services:
                    return "Услуги и сервисы"
                }
            }
        }
        
        var collectionView: UICollectionView!
        var dataSource: UICollectionViewDiffableDataSource<Section, PaymentsModel>?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            navigationController?.navigationBar.isHidden = true
            view.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
          
            setupSearchBar()
            setupCollectionView()
            createDataSource()
            getCurrency()
            setupData()
            reloadData(with: nil)
            collectionView.dataSource = dataSource
        }
    
        func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?,_ error: String?)->()) {
        
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
        
        func setupData() {
            openProduct = MockItems.returnOpenProduct()
            offer = MockItems.returnFastPay()
            pay = MockItems.returnPayments()
            payments = MockItems.returnPayments()
            getCardList { data, errorMessage in
                guard let list = data else {return}
                for i in list {
                    self.transfers.append(PaymentsModel(productList: i))
                }
                if list.count < 3{
//                    self.transfers.append(PaymentsModel(id: 32, name: "Хочу карты", iconName: "openCard", controllerName: ""))
                }
//                self.transfers = self.payments
                self.productList = data ?? []
            }

       
        }
        
        private func setupSearchBar() {
            self.view.addSubview(searchContact)
            searchContact.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, height: 48)
        }
        
        private func setupCollectionView() {
            collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionLayout())
            collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            collectionView.backgroundColor = .white
            view.addSubview(collectionView)
            collectionView.anchor(top: searchContact.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, height: UIScreen.main.bounds.height)
            
            collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
            
            collectionView.register(TransferCell.self, forCellWithReuseIdentifier: TransferCell.reuseId)
            collectionView.register(OfferCollectionViewCell.self, forCellWithReuseIdentifier: OfferCollectionViewCell.reuseId)
            collectionView.register(CurrencyExchangeCollectionViewCell.self, forCellWithReuseIdentifier: CurrencyExchangeCollectionViewCell.reuseId)
            collectionView.register(PaymentsCell.self, forCellWithReuseIdentifier: PaymentsCell.reuseId)
            collectionView.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.reuseId)
            collectionView.register(PayCell.self, forCellWithReuseIdentifier: PayCell.reuseId)
            
            collectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 20, right: 0)
            collectionView.isScrollEnabled = true
            collectionView.delegate = self
            
        }
        
        func reloadData(with searchText: String?) {
            var snapshot = NSDiffableDataSourceSnapshot<Section, PaymentsModel>()
            
            snapshot.appendSections([.transfers, .pay, .payments, .offer, .openProduct, .branches, .investment, .services])
            snapshot.appendItems(transfers, toSection: .payments)
            snapshot.appendItems(transfers, toSection: .transfers)
            snapshot.appendItems(pay, toSection: .pay)
            snapshot.appendItems(offer, toSection: .offer)
            snapshot.appendItems(openProduct, toSection: .openProduct)
            snapshot.appendItems(branches, toSection: .branches)
            snapshot.appendItems(investment, toSection: .investment)
            snapshot.appendItems(services, toSection: .services)

            dataSource?.apply(snapshot, animatingDifferences: true)
            collectionView.reloadData()
            
        }
        
    func getCurrency() {
        NetworkManager<GetExchangeCurrencyRatesDecodableModel>.addRequest(.getExchangeCurrencyRates, [:], [:]) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: LatestPayment: ", model)
            if model.statusCode == 0 {
                guard let lastPaymentsList  = model.data else { return }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                DispatchQueue.main.async {
                if model.errorMessage == "Пользователь не авторизован"{
                    AppLocker.present(with: .validate)
                }
                }
            }
        }
    }
    
    }



