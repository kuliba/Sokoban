//
//  MainViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 11.08.2021.
//

import UIKit
import RealmSwift
import Combine
import SwiftUI

protocol MainViewControllerDelegate: AnyObject {
    func goSettingViewController()
    func goProductViewController(productIndex: Int, product: UserAllCardsModel, products: [UserAllCardsModel])
    func goPaymentsViewController()
}

class MainViewController: UIViewController {
    
    weak var delegate: MainViewControllerDelegate?
    var alertController: UIAlertController?
    
    var token: NotificationToken?

    var productsViewModels = [PaymentsModel]()
    var paymentsViewModels = [PaymentsModel]() {
        didSet {
            DispatchQueue.main.async {
            }
        }
    }
    var promoViewModels = [PaymentsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.reloadData(with: nil)
            }
        }
    }
    var exchangeRatesViewModels = [PaymentsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.reloadData(with: nil)
            }
        }
    }
    var openProductViewModels = [PaymentsModel]() {
        didSet {
            DispatchQueue.main.async {
                self.reloadData(with: nil)
            }
        }
    }
    
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
        case products, pay, offer, currentsExchange, openProduct
        
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
            }
        }
    }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, PaymentsModel>?
    lazy var realm = try? Realm()
    
    weak var templatesListViewDelegate: TemplatesListViewHostingViewControllerDelegate?
    
    var isUpdating: CurrentValueSubject<Bool, Never> = .init(false)
    var refreshView: UIView?
    var sectionsExpanded: CurrentValueSubject<[Section: Bool], Never> = .init([:])
    let productTypeSelector = ProductTypeSelectorViewModel()
    private let model: Model = .shared
    private var bindings = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "F8F8F8")
        view.backgroundColor = .white
        
        setupSectionsExpanded()
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        getCurrency()
        setupData()
        
        if let products = self.realm?.objects(UserAllCardsModel.self) {
            
            productTypeSelector.update(with: products)
            updateProductsViewModels(with: products)
            
        } else {
            
            reloadData(with: nil)
        }

        bind()
        startUpdate()
        model.action.send(ModelAction.Deposits.List.Request())
        model.action.send(ModelAction.Settings.GetClientInfo.Requested())
    }
    
    func updateProductsViewModels(with products: Results<UserAllCardsModel>) {
        
        if products.count > 0 {

            var productsViewModels = [PaymentsModel]()
            
            for product in products {
                
                productsViewModels.append(PaymentsModel(productListFromRealm: product))
            }
            productsViewModels.append(PaymentsModel(id: 32, name: "Хочу карту", iconName: "openCard", controllerName: ""))
            
            self.productsViewModels = productsViewModels
            
            
        } else {
            
            self.productsViewModels = []
            
        }
        
        reloadData(with: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UITabBarItem.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.black], for: .selected)
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if GlobalModule.qrOperator != nil && GlobalModule.qrData != nil {
            let controller = InternetTVMainController.storyboardInstance()!
            let nc = UINavigationController(rootViewController: controller)
            nc.modalPresentationStyle = .fullScreen
            present(nc, animated: false)
        }
    }
    
    func startUpdate() {
        
        isUpdating.value = true
        
        AddAllUserCardtList.add() { [weak self] in
            
            guard let self = self, let products = self.realm?.objects(UserAllCardsModel.self) else {
                return
            }
            
            self.productTypeSelector.update(with: products)
            self.updateProductsViewModels(with: products)
            self.isUpdating.value = false
        }
    }
    
    @objc func openSetting() {
        delegate?.goSettingViewController()
    }
    
    func setupSectionsExpanded() {
        
        let settings = model.settingsMainSections
        var expanded = [Section: Bool]()
        
        for section in Section.allCases {
            
            if let mainSectionType = section.mainSectionType {
                
                expanded[section] = settings.sectionsExpanded[mainSectionType]
                
            } else {
                
                expanded[section] = true
            }
        }
        
        sectionsExpanded.value = expanded
    }
    
    func toggleExpanded(for section: Section) {
        
        guard var expandedSectionValue = sectionsExpanded.value[section] else {
            return
        }
        expandedSectionValue.toggle()
        sectionsExpanded.value[section] = expandedSectionValue
        
        // updating settings
        guard let mainSectionType = section.mainSectionType else {
            return
        }
        var settings = model.settingsMainSections
        settings.update(isExpanded: expandedSectionValue, sectionType: mainSectionType)
        model.settingsUpdate(settings)
    }
    
    private func setupSearchBar() {
        view.addSubview(searchBar)
        
        searchBar.searchIcon.image = UIImage(named: "ProfileImage")
        searchBar.textField.text = ""
        searchBar.textField.placeholder = ""
        searchBar.textField.isEnabled = false
        searchBar.foraAvatarImageView.isHidden = false
        searchBar.searchIconWidth.constant = 40
        searchBar.searchIconHeight.constant = 40
        
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
    
    func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink {[unowned self] action in

                switch action {
                case let payload as ModelAction.Deposits.List.Response:
                    switch payload.result {
                    case .success(let deposits):
                        guard let maxRate = deposits.map({ $0.generalСondition.maxRate }).max(),
                        let openDepositIndex = openProductViewModels.firstIndex(where: { $0.id == 98 }) else {
                            return
                        }
 
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .percent
                        formatter.maximumFractionDigits = 1
                        
                        guard let maxRateString = formatter.string(from: NSNumber(value: maxRate / 100)) else {
                            return
                        }
                        
                        var openProductMutable = openProductViewModels
                        var depositProduct = openProductMutable[openDepositIndex]
                        depositProduct.description = "\(maxRateString) годовых"
                        openProductMutable[openDepositIndex] = depositProduct
                        openProductViewModels = openProductMutable
                        
                    case .failure(let error):
                        print("loading deposits list error: \(error)")
                    }
                    
                case let payload as ModelAction.Settings.GetClientInfo.Complete:
                    searchBar.textField.text = payload.user.firstName
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    
        isUpdating
            .receive(on: DispatchQueue.main)
            .sink {[unowned self] isUpdating in
                
                setupRefreshView(isEnabled: isUpdating)
                
                for cell in collectionView.visibleCells {
                
                    guard let productCell = cell as? ProductCell else {
                        continue
                    }
                    
                    productCell.isUpdating = isUpdating
                }
                
            }.store(in: &bindings)
        
        sectionsExpanded
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink {[unowned self] _ in
                
                let layout = createCompositionLayout()
                collectionView.setCollectionViewLayout(layout, animated: true) {[weak self] complete in
                    
                    if complete == true {

                        self?.collectionView.reloadData()
                    }
                }
                
            }.store(in: &bindings)
        
        productTypeSelector.selected
            .receive(on: DispatchQueue.main)
            .sink {[unowned self] selectedProduct in
                
                guard let selectedProduct = selectedProduct,
                    let firstItemIndex = productTypeSelector.firstIndexes[selectedProduct] else {
                    return
                }
                
                let itemIndexPath = IndexPath(item: firstItemIndex, section: 0)
                collectionView.scrollToItem(at: itemIndexPath, at: .left, animated: true)
                
            }.store(in: &bindings)
    }
    
    deinit {
        self.token?.invalidate()
    }
    
    func setupData() {
        
        print(model.catalogBanners.value)
        let baners = model.catalogBanners.value
        var items: [PaymentsModel] = []
        baners.forEach { baner in
            let host = ServerAgent.Environment.test
            let urlString = host.baseURL + "/" + baner.imageLink
            print(host.baseURL + "/" + baner.imageLink)
            let cell = PaymentsModel(id: Int.random(in: 1..<9999), name: baner.productName, iconName: urlString, controllerName: baner.orderLink.absoluteString)
            items.append(cell)
        }
        promoViewModels = items
        exchangeRatesViewModels = MockItems.returnCurrency()
        paymentsViewModels = MockItems.returnFastPay()
        openProductViewModels = MockItems.returnOpenProduct()
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
        
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 80, right: 0)
        collectionView.isScrollEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    func setupRefreshView(isEnabled: Bool) {
        
        if isEnabled == true {
            
            guard refreshView == nil else {
                return
            }
            
            let refreshView = createRefreshView()
            refreshView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(refreshView)
            NSLayoutConstraint.activate([
                refreshView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                refreshView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                refreshView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: -4),
                refreshView.heightAnchor.constraint(equalToConstant: 4)
            ])

            self.refreshView = refreshView
            
            refreshView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                
                refreshView.alpha = 1.0
            }
            
        } else {
            
            UIView.animate(withDuration: 0.3) {
                
                self.refreshView?.alpha = 0
            
            } completion: { _ in
                
                self.refreshView?.removeFromSuperview()
                self.refreshView = nil
            }
        }
    }
    
    func createRefreshView() -> UIView {
        
        UIHostingController(rootView: RefreshView()).view
    }
    
    func reloadData(with searchText: String?) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PaymentsModel>()
        snapshot.appendSections([.products, .pay, .offer, .currentsExchange, .openProduct])
        snapshot.appendItems(productsViewModels, toSection: .products)
        snapshot.appendItems(paymentsViewModels, toSection: .pay)
        snapshot.appendItems(promoViewModels, toSection: .offer)
        snapshot.appendItems(exchangeRatesViewModels, toSection: .currentsExchange)
        snapshot.appendItems(openProductViewModels, toSection: .openProduct)
        dataSource?.apply(snapshot, animatingDifferences: true)
        collectionView.reloadData()
    }
    
    func getCurrency() {
        
        let body = ["currencyCodeAlpha": "USD"
        ] as [String: AnyObject]
        
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
        
        let bodyEURO = ["currencyCodeAlpha": "EUR"
        ] as [String: AnyObject]
        
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

extension MainViewController {
    
    class ProductTypeSelectorViewModel {
        
        var productTypes = [ProductType]()
        var firstIndexes = [ProductType: Int]()
        var selected: CurrentValueSubject<ProductType?, Never> = .init(nil)
        var optionSelector: OptionSelectorView.ViewModel? = nil
        
        private var bindings = Set<AnyCancellable>()
        
        func update(with products: Results<UserAllCardsModel>) {
            
            var productsArray = [UserAllCardsModel]()
            for product in products {
                
                productsArray.append(product)
            }
            
            update(with: productsArray)
        }
        
        private func update(with products: [UserAllCardsModel]) {
            
            if products.isEmpty == false {
                
                productTypes = productTypes(from: products)
                firstIndexes = firstIndexes(for: products, and: productTypes)
                
                bindings = Set<AnyCancellable>()
                if let optionSelector = optionSelector(with: productTypes, selected: selected.value) {
                    
                    self.optionSelector = optionSelector
                    bind(optionSelector: optionSelector)
                    
                } else {
                    
                    optionSelector = nil
                }
                
            } else {
                
                productTypes = [ProductType]()
                firstIndexes = [ProductType: Int]()
                selected = .init(nil)
                optionSelector = nil
            }
        }
        
        func bind(optionSelector: OptionSelectorView.ViewModel) {
            
            optionSelector.$selected
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] selectedId in
                    
                    selected.value = ProductType(rawValue: selectedId)
                    
                }.store(in: &bindings)
        }
        
        private func productTypes(from products: [UserAllCardsModel]) -> [ProductType] {
        
            let productTypeStrings = products.compactMap{ $0.productType }
            let productTypes = productTypeStrings.compactMap{ ProductType(rawValue: $0) }
            var productTypesUnique = Set<ProductType>()
            for productType in productTypes {
                
                productTypesUnique.insert(productType)
            }
            
            return Array(productTypesUnique).sorted(by: { $0.order < $1.order })
        }
        
        private func firstIndexes(for products: [UserAllCardsModel], and productTypes: [ProductType]) -> [ProductType: Int] {
            
            var firstIndexes = [ProductType: Int]()
            for productType in productTypes {
                
                firstIndexes[productType] = products.firstIndex(where: { $0.productType == productType.rawValue })
            }
            
            return firstIndexes
        }
        
        private func optionSelector(with productTypes: [ProductType], selected: ProductType?) -> OptionSelectorView.ViewModel? {
            
            guard productTypes.count > 1 else {
                return nil
            }
            
            let options = productTypes.map{ Option(id: $0.rawValue, name: $0.pluralName) }
            
            if let selected = selected, productTypes.map({ $0.rawValue }).contains(selected.rawValue) {
                
                return .init(options: options, selected: selected.rawValue, style: .products)
                
            } else {
                
                return .init(options: options, selected: options[0].id, style: .products)
            }
        }
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

extension MainViewController.Section {
    
    init(with mainSectionType: MainSectionType) {
        
        switch mainSectionType {
        case .products: self = .products
        case .fastOperations: self = .pay
        case .promo: self = .offer
        case .currencyExchange: self = .currentsExchange
        case .openProduct: self = .openProduct
        }
    }
    
    var mainSectionType: MainSectionType? {
        
        switch self {
        case .products: return .products
        case .pay: return .fastOperations
        case .offer: return .promo
        case .currentsExchange: return .currencyExchange
        case .openProduct: return .openProduct
        default: return nil
        }
    }
}
