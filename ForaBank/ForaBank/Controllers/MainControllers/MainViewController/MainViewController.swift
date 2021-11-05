//
//  MainViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 11.08.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, ChildViewControllerDelegate, FirstControllerDelegate{
    
    func sendData(data: [GetProductListDatum]) {
        
        DispatchQueue.main.async {
         
            self.getCardList { data, errorMessage in
            
            guard let listProducts = data else {return}
            self.products.removeAll()
            self.productList.removeAll()
            for i in listProducts.prefix(3) {
                self.products.append(PaymentsModel(productList: i))
            }
            if listProducts.prefix(3).count < 3{
                self.products.append(PaymentsModel(id: 32, name: "Хочу карту", iconName: "openCard", controllerName: ""))
            } else if listProducts.prefix(3).count == 3{
                self.products.append(PaymentsModel(id: 33, name: "Cм.все", iconName: "openCard", controllerName: ""))
            }
            //                self.transfers = self.payments
            self.productList = data ?? []
            

        }
        }
        
//        DispatchQueue.main.async {
//            self.products.removeAll()
//            self.productList.removeAll()
//        for i in data.prefix(3) {
//            self.products.append(PaymentsModel(productList: i))
//        }
//
//            if data.prefix(3).count < 3{
//                self.products.append(PaymentsModel(id: 32, name: "Хочу карту", iconName: "openCard", controllerName: ""))
//            } else if data.prefix(3).count == 3{
//                self.products.append(PaymentsModel(id: 32, name: "Cм.все", iconName: "openCard", controllerName: ""))
//            }
//
//            self.productList = data
//
//        self.reloadData(with: nil)
//
//        }
       }
    
    func childViewControllerResponse(productList: [GetProductListDatum]) {
        showAlert(with: "ОБновляет", and:  "")
    }
    
    
    var card: UserAllCardsModel?
    var sectionIndexCounter = 0
    
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
    var products = [PaymentsModel](){
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
    var currentsExchange = [PaymentsModel](){
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
    
    
    var dataEuro: GetExchangeCurrencyDataClass? = nil {
        didSet{
        }
    }
    var dataUSD: GetExchangeCurrencyDataClass? = nil {
        didSet{
            
        }
    }
    
    lazy var searchContact: NavigationBarUIView = UIView.fromNib()
    
    
    enum Section: Int, CaseIterable {
        case  products, pay, offer, currentsExchange, openProduct, branches, investment, services
        func description() -> String {
            switch self {
            case .products:
                return "Мои продукты"
            case .pay:
                return "Быстрые операции"
            case .offer:
                return "123"
            case .currentsExchange:
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
    lazy var realm = try? Realm()

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        if self.isMovingFromParent {
//            showAlert(with: "isMovingFromParent", and: "123")
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true

        view.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)
        
        self.view.addSubview(searchContact)
        searchContact.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 48)
        
        searchContact.secondButton.image = UIImage(named: "Avatar")?.withRenderingMode(.alwaysTemplate)
        searchContact.secondButton.tintColor = .black
        searchContact.secondButton.isUserInteractionEnabled = true
        searchContact.secondButton.alpha = 1
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openSetting))
        searchContact.secondButton.addGestureRecognizer(gesture)
        
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        getCurrency()
        setupData()
        reloadData(with: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @objc func openSetting() {
        let vc: SettingTableViewController = SettingTableViewController.loadFromStoryboard()
        vc.addCloseButton()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true, completion: nil)
    }
    
    private func setupSearchBar() {
        self.view.addSubview(searchContact)
        searchContact.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, height: 48)
    }
    
    func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?,_ error: String?)->()) {
        
        let param = ["isCard": "true", "isAccount": "true", "isDeposit": "false", "isLoan": "false"]
        
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

    
    override func viewDidAppear(_ animated: Bool) {

        print("viewDidAppear")

            self.getCardList { data, errorMessage in
                self.productList.removeAll()
                self.products.removeAll()
                DispatchQueue.main.async {
                guard let listProducts = data else {return}

                for i in listProducts.prefix(3) {
                    self.products.append(PaymentsModel(productList: i))
                }

                    if listProducts.prefix(3).count < 3{
                        self.products.append(PaymentsModel(id: 32, name: "Хочу карту", iconName: "openCard", controllerName: ""))
                    } else if listProducts.prefix(3).count == 3{
                        self.products.append(PaymentsModel(id: 33, name: "Cм.все", iconName: "openCard", controllerName: ""))
                    }

                self.productList = data ?? []

                self.reloadData(with: nil)

            }
        }
    }
    

    
    override func viewDidLayoutSubviews() {
        print("view load back")
    }
    
    
    
    
    func setupData() {
        //            openProduct = MockItems.returnOpenProduct()
        offer = MockItems.returnBanner()
        currentsExchange = MockItems.returnCurrency()
        pay = MockItems.returnFastPay()
        openProduct = MockItems.returnOpenProduct()
        //            pay = MockItems.returnPayments()
        //            payments = MockItems.returnPayments()
        getCardList { data, errorMessage in
            
            guard let listProducts = data else {return}
            
            for i in listProducts.prefix(3) {
                self.products.append(PaymentsModel(productList: i))
            }
            if listProducts.prefix(3).count < 3{
                self.products.append(PaymentsModel(id: 32, name: "Хочу карту", iconName: "openCard", controllerName: ""))
            } else if listProducts.prefix(3).count == 3{
                self.products.append(PaymentsModel(id: 33, name: "Cм.все", iconName: "openCard", controllerName: ""))
            }
            //                self.transfers = self.payments
            self.productList = data ?? []
            

        }
        
        
    }
        
//        private func setupSearchBar() {
////            self.view.addSubview(searchContact)
////            searchContact.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 48)
////            searchContact.secondButton.image = UIImage(named: "Avatar")
//            navigationController?.navigationBar.isHidden = true
//
//
//
//        }
        
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionLayout())
//        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.anchor(top: searchContact.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        collectionView.register(PaymentsMainCell.self, forCellWithReuseIdentifier: PaymentsMainCell.reuseId)
        collectionView.register(AllCardCell.self, forCellWithReuseIdentifier: AllCardCell.reuseId)
        collectionView.register(OfferCard.self, forCellWithReuseIdentifier: OfferCard.reuseId)
        
        
        
        let nib = UINib(nibName: "CurrencyExchangeCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "CurrencyExchangeCollectionViewCell")
        collectionView.register(TransferCell.self, forCellWithReuseIdentifier: TransferCell.reuseId)
        collectionView.register(OfferCollectionViewCell.self, forCellWithReuseIdentifier: OfferCollectionViewCell.reuseId)
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.reuseId)
        collectionView.register(NewProductCell.self, forCellWithReuseIdentifier: NewProductCell.reuseId)
        
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        collectionView.isScrollEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = dataSource
    }
    
    func reloadData(with searchText: String?) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PaymentsModel>()
        
        snapshot.appendSections([.products, .pay, .offer, .currentsExchange, .openProduct, .branches, .investment, . services])
        snapshot.appendItems(products, toSection: .products)
        snapshot.appendItems(pay, toSection: .pay)
        snapshot.appendItems(offer, toSection: .offer)
        snapshot.appendItems(currentsExchange, toSection: .currentsExchange)
        snapshot.appendItems(openProduct, toSection: .openProduct)
        snapshot.appendItems(branches, toSection: .branches)
        snapshot.appendItems(investment, toSection: .investment)
        snapshot.appendItems(services, toSection: .services)
        
        
        
        dataSource?.apply(snapshot, animatingDifferences: true)
        collectionView.reloadData()
        
    }
    
    func getCurrency() {
        
        let body = [ "currencyCodeAlpha" : "USD"
        ] as [String : AnyObject]
        
        NetworkManager<GetExchangeCurrencyRatesDecodableModel>.addRequest(.getExchangeCurrencyRates, [:], body) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: LatestPayment: ", model)
            if model.statusCode == 0 {
                guard let lastPaymentsList  = model.data else { return }
                self.dataUSD = lastPaymentsList
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")

            }
        }
        
        let bodyEURO = [ "currencyCodeAlpha" : "EUR"
        ] as [String : AnyObject]
        
        NetworkManager<GetExchangeCurrencyRatesDecodableModel>.addRequest(.getExchangeCurrencyRates, [:], bodyEURO) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: LatestPayment: ", model)
            if model.statusCode == 0 {
                guard let lastPaymentsList  = model.data else { return }
                self.dataEuro = lastPaymentsList
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")

            }
        }
    }
    
}
