//
//  ProductViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 31.08.2021.
//

import UIKit
import SkeletonView
import RealmSwift
import SwiftUI
import Combine

protocol ProductViewControllerDelegate: AnyObject {
    func goPaymentsViewController()
}

protocol ChildViewControllerDelegate{
    func childViewControllerResponse(productList: [GetProductListDatum])
}

protocol CtoBDelegate : AnyObject{
    func sendMyDataBack(product: UserAllCardsModel?, products: [UserAllCardsModel])
}

class ProductViewController: UIViewController, UICollectionViewDelegate, UIScrollViewDelegate, UITextFieldDelegate {
    
    private let model = Model.shared
    private var bindings = Set<AnyCancellable>()
    
    lazy var realm = try? Realm()
    var token: NotificationToken?
    var allProductList: Results<UserAllCardsModel>? = nil
    
    private var heightConstraint: NSLayoutConstraint?
    
    var halfScreen: Bool?
    
    weak var delegatePaymentVc: ProductViewControllerDelegate?
    
//    var swiftUIView = ProductProfileAccountDetailView(viewModel: .init(with: .init(), status: .notActivated, isCredit: false, productName: nil, longInt: nil))
//    var detailView = SelfSizingHostingController(rootView: ProductProfileAccountDetailView(viewModel: .init(with: .init(), status: .notActivated, isCredit: false, productName: nil, longInt: nil)))
    
    var emptySpending = UIView()
    
    var totalExpenses = 0.0 {
        didSet{
            if totalExpenses != 0.0 {
                
                amounPeriodLabel.text = "- \(totalExpenses.currencyFormatter(symbol: product?.currency ?? "") )"
                statusBarView.isHidden = false
            } else {
                statusBarView.isHidden = true
            }
        }
    }
    var sumPayPrc: Double?
    var sorted: [Dictionary<String?, [GetCardStatementDatum]>.Element] = []
    var sortedAccount: [Dictionary<String?, [GetAccountStatementDatum]>.Element] = []
    var sortedDeposit: [Dictionary<String?, [GetDepositStatementDatum]>.Element] = []
    
    let headerView = UIStackView()
    var secondStackView = UIStackView()
    let statusBarView = UIView()
    let statusBarLabel = UILabel()
    let amounPeriodLabel = UILabel()
    var groupByCategorySorted: Dictionary<Int, Any> = [:]
    var groupByCategory: Dictionary<Int, [GetCardStatementDatum]> = [:]
    var groupByCategoryAccount: Dictionary<Int, [GetAccountStatementDatum]> = [:]
    var groupByCategoryDeposit: Dictionary<Int, [GetDepositStatementDatum]> = [:]
    
    var card = LargeCardCell()
    
    var tableView = UITableView() {
        didSet {
            
        }
    }
    
    var firstTimeLoad = false
    var scrollView = UIScrollView()
    var collectionView = UICollectionView(frame: .init(), collectionViewLayout: .init())
    var products = [UserAllCardsModel]() {
        didSet{
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    var productsCount = 0
    
    var product: UserAllCardsModel? {
        didSet{
            
            setupProduct()
            card.reloadInputViews()
            amounPeriodLabel.text = ""
            card.card = product
            setupNavigationColor()
            emptySpending.isHidden = true
            loadHistoryForCard()
        }
    }
    
    let filterButton = UIButton()
    
    let tableViewLabel = UILabel(text: "История операций", font: UIFont.boldSystemFont(ofSize: 20), color: UIColor(hexString: "#1C1C1C"))
    
    var backgroundView = UIView()
    
    let button = UIButton()
    let button2 = UIButton()
    let button3 = UIButton()
    let button4 = UIButton()
    
    
    let blockView = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
    
    var historyArray = [GetCardStatementDatum](){
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var historyArrayAccount = [GetAccountStatementDatum](){
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var historyArrayDeposit = [GetDepositStatementDatum](){
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    lazy var stackView: UIStackView = {
        
        let stackV = UIStackView(arrangedSubviews: [])
        stackV.translatesAutoresizingMaskIntoConstraints = false
        stackV.axis = .horizontal
        stackV.spacing = 20
        stackV.distribution = .fillEqually
        return stackV
    }()
    
    lazy var stackView2: UIStackView = {
        
        let stackV = UIStackView(arrangedSubviews: [])
        stackV.translatesAutoresizingMaskIntoConstraints = false
        stackV.axis = .horizontal
        stackV.spacing = 20
        stackV.distribution = .fillEqually
        return stackV
    }()
    
    
    var activateSlider: MTSlideToOpenView = {
        let slide = MTSlideToOpenView(frame: CGRect(x: 26, y: 300, width: 317, height: 56))
        slide.sliderViewTopDistance = 0
        slide.thumbnailViewTopDistance = 4
        slide.thumbnailViewStartingDistance = 4
        slide.sliderCornerRadius = 25
        slide.thumnailImageView.backgroundColor = .white
        slide.draggedView.backgroundColor = .clear
        slide.thumnailImageView.image = #imageLiteral(resourceName: "sliderButton").imageFlippedForRightToLeftLayoutDirection()
        slide.showSliderText = true
        slide.textLabelLeadingDistance = 40
        
        return slide
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.isSkeletonable = true
        tableView.showSkeleton(usingColor: .lightGray, transition: .crossDissolve(0.25))
        productsCount = products.filter({$0.productType != product?.productType}).count
        tableView.backgroundColor = .white
        scrollView.delegate = self
        tableView.isSkeletonable = true
        secondStackView.spacing = 20
        secondStackView.distribution = .fill
        secondStackView.axis = .vertical
        
        view.addSubview(scrollView)
        scrollView.addSubview(backgroundView)
        scrollView.addSubview(card)
        scrollView.addSubview(stackView)
        scrollView.addSubview(stackView2)
        scrollView.addSubview(secondStackView)
        scrollView.addSubview(headerView)
        
        secondStackView.anchor(top: stackView2.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 24, paddingLeft: 20, paddingRight: 20)
        
        headerView.anchor(height: 80)
        headerView.anchor(top: secondStackView.bottomAnchor ,left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        
        let title = UILabel(text: "Нет операций")
        guard let icon = UIImage(named: "ic24Search") else { return }
        let imageView = UIImageView(image: icon)
        let circleView = UIView()
        circleView.addSubview(imageView)
        imageView.center(inView: circleView)
        imageView.setImageColor(color: .gray)
        
        scrollView.addSubview(emptySpending)
        emptySpending.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20, height: 500)
        emptySpending.addSubview(circleView)
        emptySpending.addSubview(title)
        circleView.center(inView: emptySpending)
        title.centerX(inView: emptySpending)
        title.textColor = .gray
        emptySpending.anchor(paddingTop: 40, width: 336, height: 112)
        circleView.anchor(paddingTop: 20, width: 64, height: 64)
        title.anchor(top: circleView.bottomAnchor, paddingTop: 20)
        
        circleView.backgroundColor = UIColor(hexString: "F6F6F7")
        circleView.layer.masksToBounds = true
        circleView.layer.cornerRadius = 64/2
        emptySpending.isHidden = true
        
        scrollView.isScrollEnabled = true
        scrollView.contentSize.width = UIScreen.main.bounds.width
        
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        card.backgroundImageView.backgroundColor = UIColor(red: 0.667, green: 0.667, blue: 0.667, alpha: 1)
        card.backgroundImageView.layer.cornerRadius = 12
        
        backgroundView.anchor(left: view.leftAnchor, bottom: card.centerYAnchor, right: view.rightAnchor, height: UIScreen.main.bounds.height)
        
        //CollectionView set
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 50, height: 50)
        flowLayout.minimumLineSpacing = 5
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.register(UINib(nibName: "CardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CardCollectionViewCell")
        collectionView.register(UINib(nibName: "MoreButtonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MoreButtonCollectionViewCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isMultipleTouchEnabled = false
        collectionView.allowsMultipleSelection = false
        
        scrollView.addSubview(collectionView)
        
        var filteredProducts = products.filter({$0.productType == product?.productType})
        
        if product?.productType == ProductType.loan.rawValue {
            
            filteredProducts = products.filter({$0.productType == product?.productType})
            filteredProducts += products.filter({$0.number == product?.settlementAccount})
        }
        
        products = Array(filteredProducts[0 ..< filteredProducts.prefix(3).count])
        
        let width: CGFloat
        
        if productsCount > 0 {
            
            width = CGFloat(products.count + 1)
        } else {
            
            width = CGFloat(products.count)
        }
        
        collectionView.anchor(top: scrollView.topAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width:  width * 60, height: 65)
        
        collectionView.centerX(inView: view)
        collectionView.contentMode = .center
        
        //Card set
        card.anchor(top: collectionView.bottomAnchor, paddingTop: 0,  paddingBottom: 30,  width: 268, height: 160)
        card.backgroundColor = .clear
        card.centerX(inView: view)
        card.card = product
        card.backgroundImageView.image = product?.XLDesign?.convertSVGStringToImage()
        card.backgroundImageView.sizeToFit()
        
        view.addSubview(activateSlider)
        activateSlider.isEnabled = true
        activateSlider.delegate = self
        activateSlider.center(inView: card)
        activateSlider.anchor(width: 167, height: 48)
        
        
        card.addSubview(blockView)
        self.blockView.anchor(width: 64, height: 64)
        self.blockView.center(inView: self.card)
        self.blockView.backgroundColor = UIColor(patternImage: UIImage(named: "blockIcon") ?? UIImage())
        self.blockView.isHidden = true
        
        headerView.addSubview(tableViewLabel)
        headerView.addSubview(filterButton)
        headerView.addSubview(statusBarView)
        statusBarView.addSubview(statusBarLabel)
        statusBarView.addSubview(amounPeriodLabel)
        
        statusBarView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, height: 44)
        statusBarView.backgroundColor = UIColor(hexString: "BEC1DE")
        statusBarLabel.font = UIFont(name: "", size: 16)
        statusBarLabel.anchor(left: statusBarView.leftAnchor, paddingLeft: 10)
        statusBarLabel.centerY(inView: statusBarView)
        
        amounPeriodLabel.font = UIFont(name: "", size: 16)
        amounPeriodLabel.anchor(right: statusBarView.rightAnchor, paddingRight: 10)
        amounPeriodLabel.centerY(inView: statusBarView)
        
        tableViewLabel.anchor(left: headerView.leftAnchor)
        filterButton.anchor(right: headerView.rightAnchor)
        filterButton.setImage(UIImage(imageLiteralResourceName: "more-horizontalProfile"), for: .normal)
        filterButton.setDimensions(height: 32, width: 32)
        filterButton.alpha = 0.3
        
        tableViewLabel.centerY(inView: filterButton)
        tableViewLabel.anchor(top: headerView.topAnchor, left: headerView.leftAnchor, right: headerView.rightAnchor)
        
        //TableView set
        tableView.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryTableViewCell")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "HeaderIdentifier")
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.showsVerticalScrollIndicator = false
        
        scrollView.addSubview(tableView)
        tableView.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: scrollView.bottomAnchor, right: view.rightAnchor, paddingLeft: 20, paddingRight: 20, height: UIScreen.main.bounds.height - 200)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        scrollView.contentSize.height = UIScreen.main.bounds.height + tableView.frame.height + 300
        
        setupButtons()
        setupNavigationColor()
        setupProduct()
//        loadHistoryForCard()
        bind()
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Products.UpdateCustomName.Response:
                    switch payload {
                    case let .complete(productId, name):
                        DispatchQueue.main.async {
                            
                            self.card.cardNameLabel.text = name
                        
                            guard let realm = try? Realm() else {
                                return
                            }
                      
                            // update product name on this view
                            if let currentProduct = self.product,
                                currentProduct.isInvalidated == false,
                                let number = self.product?.accountNumber {
                                
                                self.navigationItem.setTitle(title: name, subtitle: "· \(String(number.suffix(4)))", color: "#ffffff")
                            }

                            // update product name in realm
                            guard let products = self.realm?.objects(UserAllCardsModel.self),
                                  let product = products.first(where: { $0.id == productId }) else {
                                
                                return
                            }
      
                            try? realm.write({
                                
                                product.customName = name
                            })
                        }
                    
                    case .failed(let message):
                        showAlert(with: "Ошибка", and: message)
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets {
        let totalWidth = cellWidth * numberOfItems
        let totalSpacingWidth = spaceBetweenCell * (numberOfItems - 1)
        let leftInset = (collectionView.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
    fileprivate func setupProduct() {
        
        setNavButton()
        
        checkStatus()
        
        if let fontDesignColor = product?.fontDesignColor {
            
            addCloseColorButton(with: UIColor(hexString: fontDesignColor))
        }
        
        secondStackView.isHidden = true
        
        statusBarView.isHidden = false
        statusBarView.layer.cornerRadius = 8
        statusBarView.skeletonCornerRadius = 8
        statusBarLabel.text = ""
        
        self.scrollView = UIScrollView()
        
        statusBarView.isSkeletonable = true
        statusBarView.showAnimatedGradientSkeleton()
        
        tableView.isSkeletonable = true
        tableView.showSkeleton(usingColor: .lightGray, transition: .crossDissolve(0.25))
        tableView.tableHeaderView?.isSkeletonable = true
        tableView.tableHeaderView?.showAnimatedGradientSkeleton()
        
        if productsCount == 0 && products.count <= 1 {
            
            collectionView.anchor(height: 0)
            collectionView.isHidden = true
            
        } else {
            
            collectionView.anchor(height: 65)
            collectionView.isHidden = false
        }
        
        button.removeTarget(self, action: #selector(showAlert(sender:)), for: .touchUpInside)
        button.removeTarget(self, action: #selector(depositAllowCreditAlert(sender:)), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showAlert(sender:)), name: Notification.Name("openPaymentsView"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.presentBottomSheet(sender: )), name: Notification.Name("openBottomSheet"), object: nil)

        switch product?.productType {
        case ProductType.card.rawValue:
            
            card.interestRate.isHidden = true
            button3.setTitle("Реквизиты\nи выписки", for: .normal)
            button3.titleLabel?.lineBreakMode = .byWordWrapping
            button3.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button3.titleLabel?.textAlignment = .center
            let btnImage3 = UIImage(named: "file-text")?.withRenderingMode(.alwaysTemplate)
            button3.setImage(btnImage3 , for: .normal)
            
            button4.alpha = 1
            button4.isUserInteractionEnabled = true
            
            tableView.isHidden = false
            headerView.isHidden = false
            
            /*
            if product?.productType == ProductType.loan.rawValue || product?.loanBaseParam?.number != "", let loanBase = product?.loanBaseParam {
                
                swiftUIView = DetailAccountViewComponent(viewModel: .init(with: loanBase , status: StatusPC(rawValue: product?.statusPC ?? "0") ?? .notActivated, isCredit: false, productName: nil, longInt: nil))
                detailView = SelfSizingHostingController(rootView: swiftUIView)
                
                heightConstraint = detailView.view.heightAnchor.constraint(equalToConstant: 0)
                
                secondStackView.addArrangedSubview(detailView.view)
                scrollView.contentSize.height += 1500
                detailView.view.anchor(top: secondStackView.topAnchor, paddingTop: 20)
                detailView.view.isHidden = false
                secondStackView.isHidden = false
                
            }
             */
            
            button.addTarget(self, action: #selector(showAlert(sender:)), for: .touchUpInside)
            
            if product?.statusPC == "17", product?.status == "Действует" || product?.status == "Выдано клиенту" {
                
                activateSlider.isHidden = false
                activateSlider.isEnabled = true
                activateSlider.delegate = self

            } else {

                activateSlider.isHidden = true
            }
            
            
        case ProductType.account.rawValue:
            
            card.interestRate.isHidden = true
            button.addTarget(self, action: #selector(showAlert(sender:)), for: .touchUpInside)
            button3.setTitle("Реквизиты\nи выписки", for: .normal)
            button3.titleLabel?.lineBreakMode = .byWordWrapping
            button3.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button3.titleLabel?.textAlignment = .center
            let btnImage3 = UIImage(named: "file-text")?.withRenderingMode(.alwaysTemplate)
            button3.setImage(btnImage3 , for: .normal)
            
            button4.alpha = 0.4
            button4.isUserInteractionEnabled = false
            
            tableView.isHidden = false
            headerView.isHidden = false
            activateSlider.isHidden = true
            
        case ProductType.deposit.rawValue:
            
            guard let number = self.product?.accountNumber else { return }
            
            self.navigationItem.setTitle(title: (self.product?.customName ?? self.product?.mainField)!, subtitle: "· \(String(number.suffix(4)))", color: "#ffffff")
            
            button2.alpha = 0.4
            button2.isUserInteractionEnabled = false
            
            button4.setTitle("Управление", for: .normal)
            button4.setImage(UIImage(named: "server"), for: .normal)
            button4.alpha = 1
            button4.isUserInteractionEnabled = true
            activateSlider.isHidden = true
            
            card.backgroundView?.backgroundColor = UIColor(hexString: "#999999")
            card.interestRate.isHidden = false
            
            if let interestRate = product?.interestRate {
                
                card.interestRate.text = "\(interestRate)%"
            }
            
            card.maskCardLabel.text = "\(number.suffix(4))"
            card.backgroundImageView.fillSuperview()
            card.backgroundImageView.contentMode = .scaleToFill
            
            button3.setTitle("Детали", for: .normal)
            button3.setImage(UIImage(named: "infoBlack"), for: .normal)
            
            button.alpha = 1
            button.isUserInteractionEnabled = true
            
            if let allowCredit = product?.allowCredit, allowCredit {
                
                button.addTarget(self, action: #selector(showAlert(sender:)), for: .touchUpInside)
            } else {
                
                button.addTarget(self, action: #selector(depositAllowCreditAlert(sender:)), for: .touchUpInside)
            }
            
            tableView.isHidden = false
            headerView.isHidden = false
            depositInfo()
        case ProductType.loan.rawValue:
            
            button.addTarget(self, action: #selector(showAlert(sender:)), for: .touchUpInside)

            if let productId = product?.id {
                
                personsCredit(id: productId)
            }
            
//            secondStackView.removeArrangedSubview(detailView.view)
            
            guard let number = self.product?.settlementAccount else { return }
            
            if let additionalField = product?.additionalField, let currentInterestRate = product?.currentInterestRate {
                
                self.navigationItem.setTitle(title: additionalField, subtitle: "· \(String(number.suffix(4))) · \(currentInterestRate)%", color: "#ffffff")
            } else {
                
                self.navigationItem.setTitle(title: product?.mainField ?? "", subtitle: "· \(String(number.suffix(4))) · \(product?.currentInterestRate ?? 0.0)%    ", color: "#ffffff")
            }
            
            addCloseColorButton(with: UIColor(hexString: "ffffff"))
            
            card.backgroundView?.backgroundColor = UIColor(hexString: "#999999")
            card.interestRate.isHidden = false
            activateSlider.isHidden = true
            
            button2.alpha = 0.4
            button2.isUserInteractionEnabled = false
            button2.setTitle("Управление", for: .normal)
            button2.setImage(UIImage(named: "server"), for: .normal)
            
            button4.alpha = 1
            button4.isUserInteractionEnabled = true
            button4.setTitle("Погасить\nдосрочно", for: .normal)
            button4.tintColor = .black
            button4.titleLabel?.textAlignment = .center
            button4.setImage(UIImage(named: "ic24Clock"), for: .normal)
            button4.setWidth(164.0)
            button4.titleLabel?.numberOfLines = 2
            button4.titleLabel?.lineBreakMode = .byWordWrapping
            button4.addTarget(self, action: #selector(showAlert(sender:)), for: .touchUpInside)
            
            
            headerView.isHidden = true
            tableView.isHidden = true
        default:
            card.backgroundView?.backgroundColor = UIColor(hexString: "#999999")
            headerView.isHidden = true
            tableView.isHidden = true
        }
    }
    
    func personsCredit(id: Int) {
        
        let params = ["id": id] as [String : AnyObject]
        
        NetworkManager<PersonsCreditsDecodableModel>.addRequest(.getPersonsCredit, [:], params) { model, error in
            
            if error != nil {

            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                DispatchQueue.main.async {
                    
                    guard let data = model.data?.original else {
                        return
                    }
                    
                    /*
                    self.detailView.view = nil
                    
                    let swiftUIView = DetailAccountViewComponent(viewModel: .init(with: .init(with: .init(loanID: data.loanId ?? 0, clientID: data.clientId, number: data.number ?? "", currencyID: data.currencyId, currencyNumber: data.currencyNumber, currencyCode: data.currencyCode, minimumPayment: data.amountPayment, gracePeriodPayment: nil, overduePayment: data.overduePayment, availableExceedLimit: nil, ownFunds: nil, debtAmount: nil, totalAvailableAmount: data.amountRepaid, totalDebtAmount: data.amountCredit)), status: .active, isCredit: true, productName: self.product?.productName, longInt: data.datePayment))
                    
                    self.detailView = SelfSizingHostingController(rootView: swiftUIView)
                    
                    self.heightConstraint = self.detailView.view.heightAnchor.constraint(equalToConstant: 0)
                    
                    self.secondStackView.addArrangedSubview(self.detailView.view)
                    self.scrollView.contentSize.height += 1300
                    self.detailView.view.anchor(top: self.secondStackView.topAnchor, paddingTop: 20)
                    self.detailView.view.isHidden = false
                    self.secondStackView.isHidden = false
                     
                     */
                    
                }
            } else {
                
                self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
            }
        }
    }
    
    fileprivate func setNavButton() {
        
        if product?.productType != ProductType.loan.rawValue, product?.productType != ProductType.deposit.rawValue {
            let item = UIBarButtonItem(image: UIImage(named: "pencil-3"), style: .done, target: self, action: #selector(customName))
            if let foregraundColor = product?.fontDesignColor {
                
                item.tintColor = UIColor(hexString: foregraundColor)
            }
            
            self.navigationItem.setRightBarButton(item, animated: false)
        } else {
            
            self.navigationItem.setRightBarButton(nil, animated: false)
        }
    }
    
    fileprivate func setupNavigationColor() {
        
        if let backgroundColor = product?.background[0].color {
            
            backgroundView.backgroundColor = UIColor(hexString: backgroundColor).darker()
            navigationController?.view.backgroundColor =  UIColor(hexString: backgroundColor).darker()
            navigationController?.navigationBar.backgroundColor = UIColor(hexString: backgroundColor).darker()
            activateSlider.sliderBackgroundColor = UIColor(hexString: backgroundColor).darker()
            navigationController?.navigationBar.barTintColor = UIColor(hexString: backgroundColor).darker()
        }
        
        if let productColor = product?.fontDesignColor {
            
            addCloseColorButton(with: UIColor(hexString: productColor))
            activateSlider.textColor = UIColor(hexString: productColor)
        }
    }
    
    fileprivate func setupButtons() {
        //Add buttons
        button.setDimensions(height: 48, width: 164)
        button.setTitleColor(.black, for: UIControl.State.normal)
        button.layer.cornerRadius = 10
        button.setTitle("Пополнить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        let btnImage = UIImage(named: "math-plus")
        button.tintColor = .black
        button.setImage(btnImage , for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 10)
        
        button.backgroundColor = UIColor(hexString: "F6F6F7")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.sizeToFit()
        button.addTarget(self, action: #selector(showAlert(sender:)), for: .touchUpInside)
        
        button2.setDimensions(height: 48, width: 164)
        button2.setTitleColor(.black, for: UIControl.State.normal)
        button2.layer.cornerRadius = 10
        button2.setTitle("Перевести", for: .normal)
        button2.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        let btnImage2 = UIImage(named: "arrow-up-right")
        button2.tintColor = .black
        button2.setImage(btnImage2 , for: .normal)
        button2.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button2.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 10)
        button2.backgroundColor = UIColor(hexString: "F6F6F7")
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.addTarget(self, action: #selector(presentPaymentVC), for: .touchUpInside)
        button3.setDimensions(height: 48, width: 164)
        button3.setTitleColor(.black, for: UIControl.State.normal)
        button3.layer.cornerRadius = 10
        button3.setTitle("Реквизиты\nи выписки", for: .normal)
        button3.titleLabel?.lineBreakMode = .byWordWrapping
        button3.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button3.titleLabel?.textAlignment = .center
        let btnImage3 = UIImage(named: "file-text")?.withRenderingMode(.alwaysTemplate)
        button3.tintColor = .black
        button3.setImage(btnImage3 , for: .normal)
        button3.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button3.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 10)
        button3.backgroundColor = UIColor(hexString: "F6F6F7")
        button3.translatesAutoresizingMaskIntoConstraints = false
        button3.addAction(for: .touchUpInside) {
            self.halfScreen = true
            self.presentRequisitsVc(product: self.product!, false)
        }
        
        button4.setDimensions(height: 48, width: 164)
        button4.setTitleColor(.black, for: UIControl.State.normal)
        button4.layer.cornerRadius = 10
        button4.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button4.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 10)
        button4.backgroundColor = UIColor(hexString: "F6F6F7")
        button4.translatesAutoresizingMaskIntoConstraints = false
        button4.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button4.addTarget(self, action: #selector(blockProduct), for: .touchUpInside)
        
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8.0
        
        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(button2)
        stackView.anchor(top: card.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20, height: 48)
        
        stackView2.alignment = .fill
        stackView2.distribution = .fillEqually
        stackView2.spacing = 8.0
        
        stackView2.addArrangedSubview(button3)
        stackView2.addArrangedSubview(button4)
        stackView2.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20, height: 48)
    }
    
    func addCloseColorButton(with color: UIColor) {
        let button = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                     landscapeImagePhone: nil,
                                     style: .done,
                                     target: self,
                                     action: #selector(onCloseScreen))
        button.tintColor = color
        navigationItem.leftBarButtonItem = button
    }
    
    @objc func onCloseScreen() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 15 // Change limit based on your requirement.
    }
    
    
    @objc func customName(){
        let alertController = UIAlertController(title: "Название карты", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.delegate = self
            textField.placeholder = "Введите название карты"
            
        }
        
        let saveAction = UIAlertAction(title: "Сохранить", style: UIAlertAction.Style.default, handler: { alert -> Void in
            
            guard let nameTextField = alertController.textFields?.first, let name = nameTextField.text, name.count > 0, let productId = self.product?.id, let productType = self.product?.productTypeEnum else {
                return
            }
            
            self.model.action.send(ModelAction.Products.UpdateCustomName.Request(productId: productId, productType: productType, name: name))
        })
        
        let cancelAction = UIAlertAction(title: "Отмена", style: UIAlertAction.Style.default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func presentPaymentVC() {
        
        if product?.productType == ProductType.deposit.rawValue {
            
            let model = ConfirmViewControllerModel(type: .card2card, status: .succses)
            var popView = CustomPopUpWithRateView()
            let currentDate = Date()
            let endDate = product?.endDate ?? 0
            let dateEnd = Date.dateUTC(with: endDate)
            
            if let card = product, card.depositProductID == 10000003792, dateEnd > currentDate, sumPayPrc != 0 {
                
                guard let currency = product?.currency, let sumPayPrc = sumPayPrc else {
                    return
                }
                popView = CustomPopUpWithRateView(cardFrom: card, maxSum: sumPayPrc)
                
                popView.bottomView.amountTextField.isEnabled = true
                popView.depositClose = false
                    
                popView.sumMax = sumPayPrc
                popView.bottomView.maxSum = sumPayPrc

            } else if let card = product {
                
                popView = CustomPopUpWithRateView(cardFrom: card, maxSum: nil)
                popView.depositClose = true
                popView.bottomView.amountTextField.isEnabled = false
                popView.bottomView.amountTextField.text = product?.balance.currencyFormatter()
            }
            
            popView.viewModel = model

            popView.modalPresentationStyle = .custom
            popView.transitioningDelegate = self
            self.present(popView, animated: true, completion: nil)
            
        } else {
            
            let vc = PaymentsViewController()
            vc.searchContact.isHidden = true
            vc.addCloseButton()
            present(vc, animated: true, completion: nil)
        }
    }
    
    func depositInfo() {
        
        sumPayPrc = nil
        let bodyForInfo = ["id": product?.id] as [String : AnyObject]
        
        
        NetworkManager<DepositInfoGetDepositInfoDecodebleModel>.addRequest(.getDepositInfo, [:], bodyForInfo) { model, error in
            self.dismissActivity()
            if error != nil {

            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                DispatchQueue.main.async { [self] in
                    self.sumPayPrc = model.data?.sumPayPrc
                    
                    let currentDate = Date()
                    let endDate = product?.endDate ?? 0
                    
                    let dateEnd = Date.dateUTC(with: endDate)
                        
                    if dateEnd <= currentDate || (product?.depositProductID == 10000003792 && sumPayPrc != 0) {
                       
                        button2.alpha = 1
                        button2.isUserInteractionEnabled = true
                        button2.target(forAction: #selector(presentPaymentVC), withSender: .none)
                    } else {

                        button2.alpha = 0.4
                        button2.isUserInteractionEnabled = false
                    }
                }
            } else {
                self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                
            }
        }
    }
    
    @objc func presentBottomSheet(sender: AnyObject) {
        
        /*
        let bottomSheet = BottomSheetHostingViewController(with: ProductProfileLoanDelayInfoView.ViewModel())
        present(bottomSheet, animated: true)
         */
    }
    
    func presentRequisitsVc(product: UserAllCardsModel,_ openControlButtons: Bool?) {
        let viewController = AccountDetailsViewController()
        viewController.product = product
        viewController.openControlButtons = openControlButtons ?? false
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        self.present(viewController, animated: true, completion: nil)
    }
    
    @objc func showAlert(sender: AnyObject) {
        let viewController = PayViewController(card: card.card, getUImage: { self.model.images.value[$0]?.uiImage })
        halfScreen = false
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = self
        self.present(navController, animated: true, completion: nil)
    }

    @objc func depositAllowCreditAlert(sender: AnyObject) {
        let alertController = UIAlertController(title: "Невозможно пополнить", message: "Вклад не предусматривает возможности пополнения.\n Подробнее в информации о вкладе в деталях", preferredStyle: UIAlertController.Style.alert)
        let saveAction = UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: nil)
        alertController.addAction(saveAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func blockProduct(){
        
        if button4.titleLabel?.text == "Блокировать"{
            guard let idCard = self.product?.cardID else { return }
            guard let number = self.product?.number else { return }
            let alertController = UIAlertController(title: "Заблокировать карту?", message: "Карту можно будет разблокировать в приложении или в колл-центре", preferredStyle: UIAlertController.Style.alert)
            let saveAction = UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: { alert -> Void in
                let body = [ "cardId": idCard, "cardNumber": number ] as [String : AnyObject]
                
                NetworkManager<BlockCardDecodableModel>.addRequest(.blockCard, [:], body) { model, error in
                    if error != nil {
                        self.showAlert(with: "Ошибка", and: error ?? "")
                    }
                    guard let model = model else { return }
                    if model.statusCode == 0 {
                        DispatchQueue.main.async {
                            self.button4.setTitle("Разблокирова.", for: .normal)
                            self.button4.setImage(UIImage(named: "unlock"), for: .normal)
                            self.blockView.isHidden = false
                            self.button.isUserInteractionEnabled = false
                            self.button2.isUserInteractionEnabled = false
                            self.button.alpha = 0.4
                            self.button2.alpha = 0.4
                            
                            if self.product?.productType == "CARD"{
                                self.navigationItem.setTitle(title: (self.product?.customName ?? self.product?.mainField)!, subtitle: "· \(String(number.suffix(4))) · Заблокирована", color: self.product?.fontDesignColor)
                            } else {
                                self.navigationItem.setTitle(title: (self.product?.customName ?? self.product?.mainField)!, subtitle: "· \(String(number.suffix(4))) · Заблокирован", color: self.product?.fontDesignColor)
                            }
                            
                            AddAllUserCardtList.add() {}
                            
                        }
                        guard model.data != nil else { return }
                        self.showAlert(with: "Карта заблокирована", and: "")
                    } else {
                        self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                    }
                }
            })
            
            let cancelAction = UIAlertAction(title: "Отмена", style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)
            self.present(alertController, animated: true, completion: nil)
            
        } else if button4.titleLabel?.text == "Управление" {
            
            presentRequisitsVc(product: product!, true)
            
        } else {
            guard let idCard = self.product?.cardID else { return }
            guard let number = self.product?.number else { return }
            
            let alertController = UIAlertController(title: "Разблокировать карту?", message: "", preferredStyle: UIAlertController.Style.alert)
            
            let saveAction = UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: { alert -> Void in
                
                let body = [ "cardId": idCard, "cardNumber": number ] as [String : AnyObject]
                
                NetworkManager<UnBlockCardDecodableModel>.addRequest(.unblockCard, [:], body) { model, error in
                    if error != nil {
                        self.showAlert(with: "Ошибка", and: error ?? "")
                    }
                    guard let model = model else { return }
                    if model.statusCode == 0 {
                        
                        self.navigationItem.setTitle(title: (self.product?.customName ?? self.product?.mainField)!, subtitle: "· \(String(number.suffix(4)))", color: self.product?.fontDesignColor)
                        
                        self.showAlert(with: "Карта разблокирована", and: "")
                        
                        DispatchQueue.main.async {
                            
                            self.button4.setTitle("Блокировать", for: .normal)
                            self.button4.setImage(UIImage(named: "lock"), for: .normal)
                            self.blockView.isHidden = true
                            self.button.isUserInteractionEnabled = true
                            self.button2.isUserInteractionEnabled = true
                            self.button.isEnabled = true
                            self.button2.isEnabled = true
                            self.button.alpha = 1
                            self.button2.alpha = 1
                            
                            AddAllUserCardtList.add() {}
                            
                        }
                    } else {
                        self.showAlert(with: "Ошибка", and: error ?? "")
                    }
                }
            })
            
            let cancelAction = UIAlertAction(title: "Отмена", style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
//    func observerRealm() {
//        self.token = self.allProductList?.observe { [weak self] ( changes: RealmCollectionChange) in
//            guard (self?.collectionView) != nil else {return}
//            switch changes {
//            case .initial:
//                self?.collectionView.reloadData()
//            case .update(_, let deletions, let insertions, let modifications):
//                self?.collectionView.performBatchUpdates({
//                    self?.collectionView.reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
//                    self?.collectionView.insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
//                    self?.collectionView.deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
//                })
//            case .error(let error):
//                fatalError("\(error)")
//            }
//        }
//    }
    
    deinit {
        self.token?.invalidate()
    }
    
    func loadHistoryForCard(){
        
        historyArray.removeAll()
        historyArrayAccount.removeAll()
        historyArrayDeposit.removeAll()
        sorted.removeAll()
        sortedDeposit.removeAll()
        sortedAccount.removeAll()
        groupByCategory.removeAll()
        groupByCategoryAccount.removeAll()
        groupByCategoryDeposit.removeAll()
        
        if product?.productType == "ACCOUNT"{
            
            accountHistory()
        } else if product?.productType == "DEPOSIT"{
            
            loadDeposit()
        } else if product?.productType == "CARD"{
            
            cardHistory()
        }
    }
    
    func checkStatus() {
        
        if let status = product?.status {
            
            if status == "Заблокирована банком" || status == "Блокирована по решению Клиента" || status == "BLOCKED_DEBET" || status == "BLOCKED_CREDIT" || status == "BLOCKED" || product?.statusPC == "3" || product?.statusPC == "5" || product?.statusPC == "6"  || product?.statusPC == "7"  || product?.statusPC == "20"  || product?.statusPC == "21" {
                
                
                card.addSubview(blockView)
                button.isEnabled = false
                button.alpha = 0.4
                button2.isEnabled = false
                button2.alpha = 0.4
                button4.setTitle("Разблокирова.", for: .normal)
                button4.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                let btnImage4 = UIImage(named: "unlock")
                button4.tintColor = .black
                button4.setImage(btnImage4 , for: .normal)
                blockView.isHidden = false
                activateSlider.isHidden = true
                
                guard let number = self.product?.number else { return }
                
                if self.product?.productType == "CARD" {
                    
                    self.navigationItem.setTitle(title: (self.product?.customName ?? self.product?.mainField)!, subtitle: "· \(String(number.suffix(4))) · Заблокирована", color: self.product?.fontDesignColor)
                } else {
                    self.navigationItem.setTitle(title: (self.product?.customName ?? self.product?.mainField)!, subtitle: "· \(String(number.suffix(4))) · Заблокирован", color: self.product?.fontDesignColor)
                }
                
            } else if product?.statusPC == "17", product?.status == "Действует" || product?.status == "Выдано клиенту"{
                
                button.isEnabled = false
                button.alpha = 0.4
                button2.isEnabled = false
                button2.alpha = 0.4
                button4.isEnabled = false
                button4.alpha = 0.4
                activateSlider.isHidden = false
                blockView.isHidden = true
                
                guard let number = self.product?.number else { return }
                
                self.navigationItem.setTitle(title: (self.product?.customName ?? self.product?.mainField)!, subtitle: "· \(String(number.suffix(4))) · Карта не активирована", color: self.product?.fontDesignColor)
            } else {
                guard let number = self.product?.number else { return }
                
                self.navigationItem.setTitle(title: (self.product?.customName ?? self.product?.mainField)!, subtitle: "· \(String(number.suffix(4)))", color: self.product?.fontDesignColor)
                
                blockView.isHidden = true
                button.isEnabled = true
                button.alpha = 1
                button2.isEnabled = true
                button2.alpha = 1
                button4.setTitle("Блокировать", for: .normal)
                button4.setImage(UIImage(named: "lock"), for: .normal)
                blockView.isHidden = true
                button.isUserInteractionEnabled = true
                button2.isUserInteractionEnabled = true
                button.isEnabled = true
                button2.isEnabled = true
                button.alpha = 1
                button2.alpha = 1
            }
        }
    }
}

extension ProductViewController: MTSlideToOpenDelegate {
    
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        
        activateSlider.thumnailImageView.image = #imageLiteral(resourceName: "successSliderButton").imageFlippedForRightToLeftLayoutDirection()
        
        let alertController = UIAlertController(title: "Активировать карту?", message: "После активации карта будет готова к использованию", preferredStyle: .alert)
        
        let doneAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            guard let idCard = self.product?.cardID else { return }
            guard let number = self.product?.number else { return }
            
            let body = [ "cardId": idCard, "cardNumber": number ] as [String : AnyObject]
            
            NetworkManager<UnBlockCardDecodableModel>.addRequest(.unblockCard, [:], body) { model, error in
                
                if error != nil {
                    
                    self.showAlert(with: "Ошибка", and: error ?? "")
                }
                
                guard let model = model else { return }
                
                if model.statusCode == 0 {
                    
                    self.showAlert(with: "Карта активирована", and: "")
                    
                    DispatchQueue.main.async {
                        
                        self.button4.setTitle("Блокировать", for: .normal)
                        self.button4.setImage(UIImage(named: "lock"), for: .normal)
                        self.button4.alpha = 1
                        self.button4.isEnabled = true
                        self.blockView.isHidden = true
                        self.button.isUserInteractionEnabled = true
                        self.button2.isUserInteractionEnabled = true
                        self.button.isEnabled = true
                        self.button2.isEnabled = true
                        self.button.alpha = 1
                        self.button2.alpha = 1
                        self.activateSlider.isHidden = true
                        self.navigationItem.setTitle(title: (self.product?.customName ?? self.product?.mainField)!, subtitle: "· \(String(number.suffix(4)))", color: self.product?.fontDesignColor)
                        self.getCardList { data, errorMessage in
                            guard data != nil else {return}
                        }
                    }
                } else {
                    
                    self.showAlert(with: "Ошибка", and: error ?? "")
                }
            }
            sender.resetStateWithAnimation(false)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .default) { (action) in
            sender.resetStateWithAnimation(false)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ProductViewController: CtoBDelegate {
    
    func sendMyDataBack(product: UserAllCardsModel?, products: [UserAllCardsModel]) {
        
        self.product = product
        
        var filteredProducts = products.filter({$0.productType == product?.productType})
        
        if product?.productType == ProductType.loan.rawValue {
            
            filteredProducts = products.filter({$0.productType == product?.productType})
            filteredProducts += products.filter({$0.number == product?.settlementAccount})
        }
        
        self.products = Array(filteredProducts[0 ..< filteredProducts.prefix(3).count])
        productsCount = products.filter({$0.productType != product?.productType}).count
        
        let width: CGFloat
        
        if productsCount > 0 {
            
            width = CGFloat(products.count + 1)
        } else {
            
            width = CGFloat(products.count)
        }
        
        collectionView.reloadInputViews()
        self.collectionView.anchor(width:  width * 60)
    }
}

extension ProductViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        if halfScreen == true {
            presenter.height = 640
        } else {
            presenter.height = 310
        }
        if presented is AccountDetailsViewController {
            if product?.productType == "DEPOSIT", self.halfScreen == true{
                presenter.height = 560
                self.halfScreen = false
            } else {
                presenter.height = 220
            }
        }
        
        if presented is CustomPopUpWithRateView {
            
            presenter.height = 490
        }
        return presenter
    }
}

class SelfSizingHostingController<Content>: UIHostingController<Content> where Content: View {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.invalidateIntrinsicContentSize()
    }
    
}
