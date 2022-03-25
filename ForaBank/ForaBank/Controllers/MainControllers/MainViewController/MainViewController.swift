//
//  MainViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 11.08.2021.
//

import UIKit
import RealmSwift

protocol MainViewControllerDelegate: AnyObject {
    func goSettingViewController()
    func goProductViewController(productIndex: Int, product: UserAllCardsModel, products: [UserAllCardsModel])
    func goPaymentsViewController()
}

class MainViewController: UIViewController {

    weak var delegate: MainViewControllerDelegate?
    var card: UserAllCardsModel?
    var alertController: UIAlertController?

    var token: NotificationToken?

    var allProductList: Results<UserAllCardsModel>? = nil

    let changeCardButtonCollection = AllCardView()

    var payments = [PaymentsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.reloadData(with: nil)
            }
        }
    }
    var selectable = true

    var productList = [UserAllCardsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.productsDeposits.removeAll()
                self.productsCardsAndAccounts.removeAll()
                guard let products = self.allProductList else {
                    return
                }
                for i in products {
                    switch i.productType {
                    case ProductType.deposit.rawValue:
                        self.productsDeposits.append(i)
                    default:
                        self.productsCardsAndAccounts.append(i)
                    }
                }
                if self.selectable {
                    self.productsFromRealm.removeAll()
                    for i in self.productsCardsAndAccounts {
                        self.productsFromRealm.append(PaymentsModel(productListFromRealm: i))
                    }
                    self.productsFromRealm.append(PaymentsModel(id: 32, name: "Хочу карту", iconName: "openCard", controllerName: ""))
                    self.reloadData(with: nil)
                }

            }
        }
    }

    var filterData = [GetProductListDatum]()

    var productsFromRealm = [PaymentsModel]()

    var products = [PaymentsModel]()

    var productsCardsAndAccounts = [UserAllCardsModel]()

    var productsDeposits = [UserAllCardsModel]()

    var isFiltered = false
    var pay = [PaymentsModel]() {
        didSet {
            DispatchQueue.main.async {
            }
        }
    }
    var offer = [PaymentsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.reloadData(with: nil)
            }
        }
    }
    var currentsExchange = [PaymentsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.reloadData(with: nil)
            }
        }
    }
    var openProduct = [PaymentsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.reloadData(with: nil)
            }
        }
    }
    var additionalButton = [PaymentsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.reloadData(with: nil)
            }
        }
    }

    var branches = [PaymentsModel]()
    var investment = [PaymentsModel]()
    var services = [PaymentsModel]()
    var dataEuro: GetExchangeCurrencyDataClass? = nil {
        didSet {
            DispatchQueue.main.async {
                self.reloadData(with: nil)
            }
        }
    }
    var dataUSD: GetExchangeCurrencyDataClass? = nil {
        didSet {
            DispatchQueue.main.async {
                self.reloadData(with: nil)
            }
        }
    }
    lazy var searchBar: NavigationBarUIView = UIView.fromNib()

    enum Section: Int, CaseIterable {
        case products, pay, offer, currentsExchange, openProduct, branches, investment, services

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

    weak var templatesListViewDelegate: TemplatesListViewHostingViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: "F8F8F8")
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "F8F8F8")
        view.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1)

        setupSearchBar()
        setupCollectionView()
        createDataSource()
        getCurrency()
        setupData()
        reloadData(with: nil)
        additionalButton = [PaymentsModel(id: 32, name: "Хочу карту", iconName: "openCard", controllerName: "")]

        allProductList = self.realm?.objects(UserAllCardsModel.self)
        productList = [UserAllCardsModel]()
        AddAllUserCardtList.add() { [weak self] in
            self?.allProductList = self?.realm?.objects(UserAllCardsModel.self)
            self?.productList = [UserAllCardsModel]()
        }

        //GlobalModule.c2bURL = "https://qr.nspk.ru/AS100057J1VQQADF9F491N4US79QFUCU?type=01&bank=100000000217&sum=100&cur=RUB&crc=7F51"
        //GlobalModule.c2bURL = "https://qr.nspk.ru/AS1A004C56EKES0D9CHO5313H57OL4VE?type=01&bank=100000000217&crc=A006"
        GlobalModule.c2bURL = "https://qr.nspk.ru/AS10001E28JJSL4U9O1QEVG0K99GERJ0?type=01&bank=100000000217&sum=10000&cur=RUB&crc=4E58"
        if GlobalModule.c2bURL != nil {
            let controller = C2BDetailsViewController.storyboardInstance()!
            let nc = UINavigationController(rootViewController: controller)
            nc.modalPresentationStyle = .fullScreen
            present(nc, animated: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UITabBarItem.appearance().setTitleTextAttributes(
                [.foregroundColor: UIColor.black], for: .selected)
        navigationController?.navigationBar.isHidden = true

        AddAllUserCardtList.add() { [weak self] in
            self?.allProductList = self?.realm?.objects(UserAllCardsModel.self)
            self?.productList = [UserAllCardsModel]()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if GlobalModule.qrOperator != nil && GlobalModule.qrData != nil {
            let controller = InternetTVMainController.storyboardInstance()!
            let nc = UINavigationController(rootViewController: controller)
            nc.modalPresentationStyle = .fullScreen
            present(nc, animated: false)
            return
        }

        if GlobalModule.c2bURL != nil {
            let controller = C2BDetailsViewController.storyboardInstance()!
            let nc = UINavigationController(rootViewController: controller)
            nc.modalPresentationStyle = .fullScreen
            present(nc, animated: false)
            return
        }
    }

    @objc func openSetting() {
        delegate?.goSettingViewController()
    }

    private func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.secondButton.image = UIImage(named: "Avatar")?.withRenderingMode(.alwaysTemplate)
        searchBar.bellIcon.tintColor = .black
        searchBar.secondButton.tintColor = .black
        searchBar.secondButton.isUserInteractionEnabled = true
        searchBar.secondButton.alpha = 1
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openSetting))
        searchBar.secondButton.addGestureRecognizer(gesture)
        searchBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: 0, height: 48)
        searchBar.bellTapped = {
            let pushHistory = PushHistoryViewController.storyboardInstance()!
            let nc = UINavigationController(rootViewController: pushHistory)
            nc.modalPresentationStyle = .fullScreen
            self.present(nc, animated: true)
        }
    }

    func observerRealm() {
        allProductList = realm?.objects(UserAllCardsModel.self)
        token = allProductList?.observe { [weak self] (changes: RealmCollectionChange) in
            guard (self?.collectionView) != nil else {
                return
            }
            switch changes {
            case .initial:
                self?.collectionView?.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self?.collectionView?.performBatchUpdates({
                    self?.collectionView?.reloadItems(at: modifications.map {
                        IndexPath(row: $0, section: 0)
                    })
                    self?.collectionView?.insertItems(at: insertions.map {
                        IndexPath(row: $0, section: 0)
                    })
                    self?.collectionView?.deleteItems(at: deletions.map {
                        IndexPath(row: $0, section: 0)
                    })
                })
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }

    deinit {
        token?.invalidate()
    }

    func setupData() {
        offer = MockItems.returnBanner()
        currentsExchange = MockItems.returnCurrency()
        pay = MockItems.returnFastPay()
        openProduct = MockItems.returnOpenProduct()
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionLayout())
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.anchor(top: searchBar.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        collectionView.register(PaymentsMainCell.self, forCellWithReuseIdentifier: PaymentsMainCell.reuseId)
        collectionView.register(AllCardCell.self, forCellWithReuseIdentifier: AllCardCell.reuseId)
        collectionView.register(OfferCard.self, forCellWithReuseIdentifier: OfferCard.reuseId)
        let nib = UINib(nibName: "CurrencyExchangeCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CurrencyExchangeCollectionViewCell")
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
        snapshot.appendSections([.products, .pay, .offer, .currentsExchange, .openProduct, .branches, .investment, .services])
        snapshot.appendItems(productsFromRealm, toSection: .products)
        snapshot.appendItems(pay, toSection: .pay)
        snapshot.appendItems(offer, toSection: .offer)
        snapshot.appendItems(currentsExchange, toSection: .currentsExchange)
        snapshot.appendItems(openProduct, toSection: .openProduct)
        dataSource?.apply(snapshot, animatingDifferences: true)
        collectionView.reloadData()
    }

    func getCurrency() {
        let body = ["currencyCodeAlpha": "USD"] as [String: AnyObject]
        NetworkManager<GetExchangeCurrencyRatesDecodableModel>.addRequest(.getExchangeCurrencyRates, [:], body) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else {
                return
            }
            if model.statusCode == 0 {
                guard let lastPaymentsList = model.data else {
                    return
                }
                self.dataUSD = lastPaymentsList
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
        let bodyEURO = ["currencyCodeAlpha": "EUR"] as [String: AnyObject]

        NetworkManager<GetExchangeCurrencyRatesDecodableModel>.addRequest(.getExchangeCurrencyRates, [:], bodyEURO) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else {
                return
            }
            if model.statusCode == 0 {
                guard let lastPaymentsList = model.data else {
                    return
                }
                self.dataEuro = lastPaymentsList
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
            }
        }
    }
}

extension MainViewController: FirstControllerDelegate {

    func sendData(data: [GetProductListDatum]) {
        //        DispatchQueue.main.async {
        //            self.getCardList { data, errorMessage in
        //                guard let listProducts = data else {return}
        //                self.products.removeAll()
        //                self.productList.removeAll()
        //                for i in listProducts.prefix(3) {
        //                    self.products.append(PaymentsModel(productList: i))
        //                }
        //                if listProducts.prefix(3).count < 3{
        //                    self.products.append(PaymentsModel(id: 32, name: "Хочу карту", iconName: "openCard", controllerName: ""))
        //                } else if listProducts.prefix(3).count == 3{
        //                    self.products.append(PaymentsModel(id: 33, name: "Cм.все", iconName: "openCard", controllerName: ""))
        //                }
        //                self.productList = data ?? []
        //            }
        //        }
    }

}

extension MainViewController: ChildViewControllerDelegate {
    func childViewControllerResponse(productList: [GetProductListDatum]) {
        showAlert(with: "ОБновляет", and: "")
    }
}

extension UICollectionViewDiffableDataSource {
    func replaceItems(_ items: [ItemIdentifierType], in section: SectionIdentifierType) {
        var currentSnapshot = snapshot()
        let itemsOfSection = currentSnapshot.itemIdentifiers(inSection: section)
        currentSnapshot.deleteItems(itemsOfSection)
        currentSnapshot.appendItems(items, toSection: section)
        currentSnapshot.reloadSections([section])
        apply(currentSnapshot, animatingDifferences: true)
    }
}
