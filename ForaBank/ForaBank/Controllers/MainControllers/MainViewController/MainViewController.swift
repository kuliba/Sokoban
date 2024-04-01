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
    func goProductViewController(product: UserAllCardsModel, products: [UserAllCardsModel])
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
    
    @objc func addUserName() {
        DispatchQueue.main.async {
            let uName = UserDefaults.standard.object(forKey: "userName") as? String
            if uName != nil {
                self.searchBar.textField.text = uName
            }
        }
    }
    
    @objc func addUserPhoto() {
        let userPhoto = self.loadImageFromDocumentDirectory(fileName: "userPhoto")
        
        if userPhoto != nil {
            self.searchBar.searchIcon.image = userPhoto//?.fixOrientation()
        } else {
            self.searchBar.searchIcon.image = UIImage(named: "ProfileImage")
        }
    }
    
    lazy var searchBar: NavigationBarUIView = UIView.fromNib()
    
    enum Section: Int, CaseIterable {
        case products, pay, offer, currentsExchange, openProduct, atm
        
        func description() -> String {
            switch self {
            case .products:
                return "Мои продукты"
                
            case .pay:
                return "Быстрые операции"
                
            case .offer:
                return ""
                
            case .currentsExchange:
                return "Обмен валют"
                
            case .openProduct:
                return "Открыть продукт"
                
            case .atm:
                return "Отделения и банкоматы"
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
    let model: Model = .shared
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
        addUserName()
        addUserPhoto()
        NotificationCenter.default.addObserver(self, selector: #selector(addUserPhoto), name: Notification.Name("userPhotoNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addUserName), name: Notification.Name("userNameNotification"), object: nil)
        
        if let products = self.realm?.objects(UserAllCardsModel.self) {
            
            productTypeSelector.update(with: products)
            updateProductsViewModels(with: products)
            
        } else {
            
            reloadData(with: nil)
        }
        
        bind()
        startObserveRealm()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            
            self.startUpdate()
        }
    }
    
    func updateProductsViewModels(with products: Results<UserAllCardsModel>) {
        
        if products.count > 0 {
            
            var productsViewModels = [PaymentsModel]()
            
            for product in products {
                
                productsViewModels.append(PaymentsModel(productListFromRealm: product))
            }
            
            if products.count <= 1  {
                
                productsViewModels.append(PaymentsModel(name: "Хочу карту", iconName: "openCard", controllerName: ""))
            }
            
            self.productsViewModels = productsViewModels
            
            
        } else {
            
            self.productsViewModels = []
            
        }
        
        reloadData(with: nil)
        
        if GlobalModule.c2bURL != nil {
            let controller = C2BDetailsViewController.storyboardInstance()!
            controller.getUImage = { self.model.images.value[$0]?.uiImage }
            let nc = UINavigationController(rootViewController: controller)
            nc.modalPresentationStyle = .fullScreen
            present(nc, animated: false)
        }
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
            return
        }
        
        if GlobalModule.c2bURL != nil {
            let controller = C2BDetailsViewController.storyboardInstance()!
            controller.getUImage = { self.model.images.value[$0]?.uiImage }
            let nc = UINavigationController(rootViewController: controller)
            nc.modalPresentationStyle = .fullScreen
            present(nc, animated: false)
            return
        }
    }
    
    @objc
    func startUpdate() {
        
        guard isUpdating.value == false else {
            return
        }
        
        isUpdating.value = true
        
        AddAllUserCardtList.add() { [weak self] in
            
            guard let self = self, let products = self.realm?.objects(UserAllCardsModel.self) else {
                self?.isUpdating.value = false
                return
            }
            
            for i in products {
                
                if i.endDate_nf == true, UserDefaults.standard.bool(forKey: "\(i.depositID)") == false {
                    
                    
                    UserDefaults.standard.set(true, forKey: "\(i.depositID)")
                    showAlertWithCancel(with: "Срок действия вклада истек", and: "Переведите деньги со вклада на свою карту/счет в любое время") {
                        
                        self.delegate?.goProductViewController(product: i, products: products.uniqued())
                    }
                }
                
                func showAlertWithCancel(with title: String, and message: String, completion: @escaping () -> Void = { }) {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                            completion()
                        }
                        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
                        alertController.addAction(cancel)
                        alertController.addAction(okAction)
                        alertController.view.tintColor = .black
                        alertController.view.center = self.view.center
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            
            self.productTypeSelector.update(with: products)
            self.updateProductsViewModels(with: products)
            self.isUpdating.value = false
        }
        getCurrency()
        
        model.action.send(ModelAction.Deposits.List.Request())
    }
    
    @objc func openSetting() {
        delegate?.goSettingViewController()
    }
    
    func setupSectionsExpanded() {
        
        let settings = model.settingsMainSections
        var expanded = [Section: Bool]()
        
        for section in Section.allCases {
            
            if let isCollapsed = settings.collapsed[section.mainSectionType] {
                
                expanded[section] = !isCollapsed
                
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
        var settings = model.settingsMainSections
        settings.update(sectionType: section.mainSectionType, isCollapsed: !expandedSectionValue)
        model.settingsMainSectionsUpdate(settings)
    }
    
    private func setupSearchBar() {
        view.addSubview(searchBar)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openSetting))
        searchBar.searchIcon.addGestureRecognizer(gesture)
        
        searchBar.textField.text = ""
        searchBar.textField.placeholder = ""
        searchBar.textField.isEnabled = false
        searchBar.foraAvatarImageView.isHidden = false
        searchBar.searchIconWidth.constant = 40
        searchBar.searchIconHeight.constant = 40
        self.searchBar.searchIcon.layer.cornerRadius = 20
        self.searchBar.searchIcon.clipsToBounds = true
        
        searchBar.trailingLeftButton.setImage(UIImage(named: "searchBarIcon"), for: .normal)
        searchBar.trailingLeftButton.isEnabled = false
        
        searchBar.trailingRightButton.setImage(UIImage(named: "belliconsvg"), for: .normal)
        searchBar.trailingRightButton.tintColor = .black
        
        searchBar.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 0, paddingLeft: 0,
            paddingRight: 0, height: 48)
        
        searchBar.trailingLeftAction = {
            // TODO: - Func Search Button Tapped
        }
        
        searchBar.trailingRightAction = {
            let pushModel = MessagesHistoryViewModel(model: self.model, closeAction: {})
            
            let pushHistory = MessagesHistoryView(viewModel: pushModel)
            let nc = UIHostingController(rootView: pushHistory)
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
                    switch payload {
                    case .success(let deposits):
                        guard let maxRate = deposits.map({ $0.generalСondition.maxRate }).max(),
                              
                              let openDepositIndex = openProductViewModels.firstIndex(where: { $0.name == "Вклад" }) else {
                            return
                        }
                        
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .percent
                        formatter.maximumFractionDigits = 2
                        
                        guard let maxRateString = formatter.string(from: NSNumber(value: maxRate / 100)) else {
                            return
                        }
                        
                        var openProductMutable = openProductViewModels
                        var depositProduct = openProductMutable[openDepositIndex]
                        depositProduct.description = "\(maxRateString) годовых"
                        openProductMutable[openDepositIndex] = depositProduct
                        openProductViewModels = openProductMutable
                        
                    case .failure(_): break
                    }
                  
                    /*
                case let payload as ModelAction.Settings.GetClientInfo.Complete:
                    let userName = UserDefaults.standard.object(forKey: "userName") as? String
                    if userName != nil {
                        searchBar.textField.text = userName
                    } else {
                        searchBar.textField.text = payload.user.firstName
                    }*/
                    
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
                
                self.model.action.send(ModelAction.Dictionary.UpdateCache.Request.init(type: .bannerCatalogList, serial: nil))
                
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
        
        productTypeSelector.$selected
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
    
    func startObserveRealm() {
        
        guard let realm = try? Realm() else {
            return
        }
        
        self.token = realm.objects(UserAllCardsModel.self).observe { [weak self] _ in
            
            guard let self = self else { return }
            
            let products = realm.objects(UserAllCardsModel.self)
            
            self.productTypeSelector.update(with: products)
            self.updateProductsViewModels(with: products)
        }
    }
    
    deinit {
        
        self.token?.invalidate()
        NotificationCenter.default.removeObserver(self, name: .startProductsUpdate, object: nil)
    }
    
    func setupData() {
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
        collectionView.register(AtmCollectionViewCell.self, forCellWithReuseIdentifier: AtmCollectionViewCell.identifier)
        
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
        
//        UIHostingController(rootView: RefreshingIndicatorView()).view
        UIView()
    }
    
    func reloadData(with searchText: String?) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PaymentsModel>()
        snapshot.appendSections([.products, .pay, .offer, .currentsExchange, .openProduct, .atm])
        snapshot.appendItems(productsViewModels, toSection: .products)
        snapshot.appendItems(paymentsViewModels, toSection: .pay)
        snapshot.appendItems(promoViewModels, toSection: .offer)
        snapshot.appendItems(exchangeRatesViewModels, toSection: .currentsExchange)
        snapshot.appendItems(openProductViewModels, toSection: .openProduct)
        snapshot.appendItems([PaymentsModel(name: "Выберите ближайшую точку на карте", iconName: "imgMainMap", controllerName: "PlacesView")], toSection: .atm)
        dataSource?.apply(snapshot, animatingDifferences: true)
        collectionView.reloadData()
    }
    
    func getCurrency() {
        
        let body = ["currencyCodeAlpha": "USD"
        ] as [String: AnyObject]
        
        NetworkManager<GetExchangeCurrencyRatesDecodableModel>.addRequest(.getExchangeCurrencyRates, [:], body) { model, error in
            if error != nil {
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
                
            }
        }
        
        let bodyEURO = ["currencyCodeAlpha": "EUR"
        ] as [String: AnyObject]
        
        NetworkManager<GetExchangeCurrencyRatesDecodableModel>.addRequest(.getExchangeCurrencyRates, [:], bodyEURO) { model, error in
            if error != nil {
                
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
                
            }
        }
    }
}

extension MainViewController {
    
    class ProductTypeSelectorViewModel {
        
        var productTypes = [ProductType]()
        var firstIndexes = [ProductType: Int]()
        @Published var selected: ProductType? = nil
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
                
                if let optionSelector = optionSelector(with: productTypes, selected: selected) {
                    
                    self.optionSelector = optionSelector
                    bind(optionSelector: optionSelector)
                    
                } else {
                    
                    optionSelector = nil
                }
                
            } else {
                
                productTypes = [ProductType]()
                firstIndexes = [ProductType: Int]()
                selected = nil
                optionSelector = nil
            }
        }
        
        func bind(optionSelector: OptionSelectorView.ViewModel) {
            
            optionSelector.$selected
                .receive(on: DispatchQueue.main)
                .sink {[unowned self] selectedId in
                    
                    selected = ProductType(rawValue: selectedId)
                    
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
    
    func loadImageFromDocumentDirectory(fileName: String) -> UIImage? {
        
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {}
        return nil
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
        case .atm: self = .atm
        case .currencyMetall: self = .currentsExchange
        }
    }
    
    var mainSectionType: MainSectionType {
        
        switch self {
        case .products: return .products
        case .pay: return .fastOperations
        case .offer: return .promo
        case .currentsExchange: return .currencyExchange
        case .openProduct: return .openProduct
        case .atm: return .atm
        }
    }
}

