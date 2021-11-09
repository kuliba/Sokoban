//
//  ProductViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 31.08.2021.
//

import UIKit
import SkeletonView

protocol ChildViewControllerDelegate{
    func childViewControllerResponse(productList: [GetProductListDatum])
}

protocol FirstControllerDelegate: AnyObject {
    func sendData(data: [GetProductListDatum])
}

class ProductViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, SkeletonTableViewDataSource, UIScrollViewDelegate, MTSlideToOpenDelegate, UITextFieldDelegate{
    weak var delegate: FirstControllerDelegate!

    var halfScreen: Bool?
    
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        activateSlider.thumnailImageView.image = #imageLiteral(resourceName: "successSliderButton").imageFlippedForRightToLeftLayoutDirection()
        let alertController = UIAlertController(title: "Активировать карту?", message: "После активации карта будет готова к использованию", preferredStyle: .alert)
           let doneAction = UIAlertAction(title: "OK", style: .default) { (action) in
               
               guard let idCard = self.product?.cardID else { return }
               guard let number = self.product?.number else { return }
               
               let body = [ "cardId": idCard,
                            "cardNumber": number
                            
                            ] as [String : AnyObject]
               
               NetworkManager<UnBlockCardDecodableModel>.addRequest(.unblockCard, [:], body) { model, error in
                   if error != nil {
                       print("DEBUG: Error: ", error ?? "")
                       self.showAlert(with: "Ошибка", and: error ?? "")
                   }
                   guard let model = model else { return }
                   print("DEBUG: LatestPayment: ", model)
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
                               
                               guard let listProducts = data else {return}
                               self.products = listProducts
                            }

                       }
                   } else {
                       self.showAlert(with: "Ошибка", and: error ?? "")
                       print("DEBUG: Error: ", model.errorMessage ?? "")
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
    
    
    var totalExpenses = 0.0 {
        didSet{
            if totalExpenses == 0.0{
                
            } else {
                amounPeriodLabel.text = "- \(totalExpenses.currencyFormatter(symbol: product?.currency ?? "") )"
                statusBarView.isHidden = false
            }
        }
    }
//    var sortData = Array(Dictionary<Int, [GetCardStatementDatum]>)
    var sorted: [Dictionary<Int?, [GetCardStatementDatum]>.Element] = []
    let headerView = UIStackView()
    let statusBarView = UIView()
    let statusBarLabel = UILabel()
    let amounPeriodLabel = UILabel()
    var groupByCategorySorted: Dictionary<Int, Any> = [:]
    var groupByCategory: Dictionary<Int, [GetCardStatementDatum]> = [:]{
        didSet{
//            let sortedKeys = groupByCategory.keys.sorted(by: { (firstKey, secondKey) -> Bool in
//                return groupByCategory[firstKey] < groupByCategory[secondKey]
//            })
            
        }
    }
    var card = LargeCardCell()
    var mockItem: [PaymentsModel] = []
    var firstTimeLoad = true
    var indexItem: Int?
    var scrollView = UIScrollView()
    var collectionView: UICollectionView?
    var products = [GetProductListDatum]()
    var product: GetProductListDatum? {
        didSet{
            card.card = product
            if product?.productType == "ACCOUNT"{
                button4.alpha = 0.4
                button4.isUserInteractionEnabled = false
            } else{
                button4.alpha = 1
                button4.isUserInteractionEnabled = true
            }
            if product?.status == "Заблокирована банком" || product?.status == "Блокирована по решению Клиента" || product?.status == "BLOCKED_DEBET" || product?.status == "BLOCKED_CREDIT" || product?.status == "BLOCKED", product?.statusPC == "3" || product?.statusPC == "5" || product?.statusPC == "6"  || product?.statusPC == "7"  || product?.statusPC == "20"  || product?.statusPC == "21" || product?.statusPC == nil {
                
                guard let number = self.product?.number else { return }

                self.navigationItem.setTitle(title: (self.product?.customName ?? self.product?.mainField)!, subtitle: "· \(String(number.suffix(4))) · Заблокирована", color: self.product?.fontDesignColor)
                
            } else if  product?.statusPC == "17", product?.status == "Действует" || product?.status == "Выдано клиенту"{
                guard let number = self.product?.number else { return }

                self.navigationItem.setTitle(title: (self.product?.customName ?? self.product?.mainField)!, subtitle: "· \(String(number.suffix(4))) · Карта не активирована", color: self.product?.fontDesignColor)
                
            } else {
                guard let number = self.product?.number else { return }

                self.navigationItem.setTitle(title: (self.product?.customName ?? self.product?.mainField)!, subtitle: "· \(String(number.suffix(4)))", color: self.product?.fontDesignColor)
            }
            activateSlider.textColor = UIColor(hexString: product?.fontDesignColor ?? "")
            activateSlider.sliderBackgroundColor = UIColor(hexString: product?.background[0] ?? "").darker()
            backgroundView.backgroundColor = UIColor(hexString: product?.background[0] ?? "").darker()
            navigationController?.view.backgroundColor =  UIColor(hexString: product?.background[0] ?? "").darker()
            navigationController?.navigationBar.backgroundColor = UIColor(hexString: product?.background[0] ?? "").darker()
            tableView?.reloadData()
            card.reloadInputViews()
            loadHistoryForCard()
            guard let number = product?.numberMasked else {
                return
            }
            navigationController?.navigationBar.barTintColor = UIColor(hexString: product?.background[0] ?? "").darker()
//            self.navigationItem.setTitle(title: (product?.customName ?? product?.mainField)!, subtitle: "· \(String(number.suffix(4)))", color: product?.fontDesignColor)
            collectionView?.reloadData()
        }
        
    }
    var tableView: UITableView?
    var backgroundView = UIView()
    var topStackView = UIStackView()
//    var buttonStackView = UIStackView(arrangedSubviews: [])
    let button = UIButton()
    let button2 = UIButton()
    let button3 = UIButton()
    let button4 = UIButton()
    

    let blockView = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
//        button4.moveImageLeftTextCenter(imagePadding: 10)
//        button4.contentVerticalAlignment = .center
    
    
    var historyArray = [GetCardStatementDatum](){
        didSet{
            DispatchQueue.main.async {
//                self.tableView?.stopSkeletonAnimation()
                self.tableView?.reloadData()
            }
        }
    }
    var historyArrayAccount = [GetAccountStatementDatum](){
        didSet{
            DispatchQueue.main.async {
//                self.tableView?.stopSkeletonAnimation()
//                self.view.hideSkeleton()
                self.tableView?.reloadData()
            }
        }
    }
    
    var tableViewHeight: CGFloat {
        tableView?.layoutIfNeeded()

        return tableView?.contentSize.height ?? 0
    }
    // Stackview setup
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
    
    var buttonItem = UIButton()
    
    lazy var activateSlider: MTSlideToOpenView = {
        let slide = MTSlideToOpenView(frame: CGRect(x: 26, y: 300, width: 317, height: 56))
        slide.sliderViewTopDistance = 0
        slide.thumbnailViewTopDistance = 4
        slide.thumbnailViewStartingDistance = 4
        slide.sliderCornerRadius = 25
        slide.thumnailImageView.backgroundColor = .white
        slide.draggedView.backgroundColor = .clear
        slide.delegate = self
        slide.thumnailImageView.image = #imageLiteral(resourceName: "sliderButton").imageFlippedForRightToLeftLayoutDirection()
        slide.showSliderText = true
        slide.textLabelLeadingDistance = 40
        
        return slide
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        statusBarView.isHidden = true
        
        scrollView.delegate = self
        //Set table height to cover entire view
            //if navigation bar is not translucent, reduce navigation bar height from view height
//            tableViewHeight.constant = self.view.frame.height-64
            self.tableView?.isScrollEnabled = false
            //no need to write following if checked in storyboard
            self.scrollView.bounces = false
            self.tableView?.bounces = true

        view.addSubview(scrollView)
        scrollView.addSubview(backgroundView)
        scrollView.addSubview(card)
        scrollView.addSubview(stackView)
        scrollView.addSubview(stackView2)
        
        scrollView.isScrollEnabled = true
//        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height:  2000)//or what ever size you want to set
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)

   
        _ = CardViewModel(card: self.product!)
//        guard let number = product?.numberMasked else {
//            return
//        }
        activateSlider.textColor = UIColor(hexString: product?.fontDesignColor ?? "")
        activateSlider.sliderBackgroundColor = UIColor(hexString: product?.background[0] ?? "").darker()
//        self.navigationItem.setTitle(title: (product?.customName ?? product?.mainField)!, subtitle: "· \(String(number.suffix(4)))", color: product?.fontDesignColor)
//        loadHistoryForCard()
        view.backgroundColor = .white
//        navigationController?.view.addoverlay(color: .black, alpha: 0.2)
        navigationController?.navigationBar.barTintColor = UIColor(hexString: product?.background[0] ?? "").darker()
        navigationController?.view.backgroundColor =  UIColor(hexString: product?.background[0] ?? "").darker()
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: product?.background[0] ?? "").darker()
//        UINavigationBar.appearance().tintColor =  UIColor(hexString: product?.fontDesignColor ?? "000000")
        addCloseColorButton(with: UIColor(hexString: product?.fontDesignColor ?? "000000"))

        
        backgroundView.backgroundColor = UIColor(hexString: product?.background[0] ?? "").darker()
        backgroundView.anchor(top: scrollView.topAnchor, left: view.leftAnchor, bottom: card.centerYAnchor, right: view.rightAnchor)
//        backgroundView.backgroundColor = UIColor(hex: "#\(product?.background[0] ?? "")")
//        view.backgroundColor = .red

        
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
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0  )
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
        button3.setTitle("Реквизиты", for: .normal)
        button3.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        let btnImage3 = UIImage(named: "file-text")
        button3.tintColor = .black
        button3.setImage(btnImage3 , for: .normal)
        button3.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button3.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 10)
        button3.backgroundColor = UIColor(hexString: "F6F6F7")
        button3.translatesAutoresizingMaskIntoConstraints = false
        
        button3.addAction(for: .touchUpInside) {
            self.presentRequisitsVc(product: self.product!)
        }
        
//        button3.addTarget(self, action: #selector(presentRequisitsVc(product: product!)), for: .touchUpInside)

        
        button4.setDimensions(height: 48, width: 164)
        button4.setTitleColor(.black, for: UIControl.State.normal)
        button4.layer.cornerRadius = 10
        button4.setTitle("Блокировать", for: .normal)
        button4.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        let btnImage4 = UIImage(named: "lock")
        button4.tintColor = .black
        button4.setImage(btnImage4 , for: .normal)
        button4.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        button4.imageEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 10)
        button4.backgroundColor = UIColor(hexString: "F6F6F7")
        button4.translatesAutoresizingMaskIntoConstraints = false
//        button4.moveImageLeftTextCenter(imagePadding: 10)
//        button4.contentVerticalAlignment = .center
        
        button4.addTarget(self, action: #selector(blockProduct), for: .touchUpInside)
        
        
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8.0

        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(button2)
//        stackView.addArrangedSubview(button3)
//        stackView.addArrangedSubview(button4)

        
        stackView.anchor(top: card.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20)
        
        
        stackView2.alignment = .fill
        stackView2.distribution = .fillEqually
        stackView2.spacing = 8.0

        stackView2.addArrangedSubview(button3)
        stackView2.addArrangedSubview(button4)
//        stackView.addArrangedSubview(button3)
//        stackView.addArrangedSubview(button4)

      
        
        stackView2.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20)
        
        //CollectionView set
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 50, height: 50)
        flowLayout.minimumLineSpacing = 5
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        flowLayout.estimatedItemSize = CGSize(width: 48, height: 48)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(UINib(nibName: "CardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CardCollectionViewCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .clear
        collectionView?.isMultipleTouchEnabled = false
        collectionView?.allowsMultipleSelection = false
        
        scrollView.addSubview(collectionView ?? UICollectionView())
        collectionView?.anchor(top: scrollView.topAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: CGFloat(products.count) * 80,  height: 65)
//        collectionView?.contentInsetAdjustmentBehavior = .always
        collectionView?.centerX(inView: view)
        collectionView?.contentMode = .center
        
        //CardView set
        card.anchor(top: collectionView?.bottomAnchor, paddingTop: 0,  paddingBottom: 30,  width: 268, height: 160)
        card.backgroundColor = .clear
        card.centerX(inView: view)
        card.card = product
        card.backgroundImageView.image = product?.XLDesign?.convertSVGStringToImage()
        card.addSubview(activateSlider)
        activateSlider.isHidden = true
        activateSlider.delegate = self
        activateSlider.center(inView: card)
        activateSlider.anchor(width: 167, height: 48)
        
        self.card.addSubview(self.blockView)
        self.blockView.anchor(width: 64, height: 64)
        self.blockView.center(inView: self.card)
        self.blockView.backgroundColor = UIColor(patternImage: UIImage(named: "blockIcon") ?? UIImage())
        blockView.isHidden = true

        
        // UIView
        let tableViewLabel = UILabel(text: "История операций", font: UIFont.boldSystemFont(ofSize: 20), color: UIColor(hexString: "#1C1C1C"))
  
        let filterButton = UIButton()
        scrollView.addSubview(headerView)
        headerView.addSubview(tableViewLabel)
        headerView.addSubview(filterButton)
        headerView.addSubview(statusBarView)
        statusBarView.addSubview(statusBarLabel)
        statusBarView.addSubview(amounPeriodLabel)
        statusBarView.anchor(left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, height: 44)
        statusBarView.backgroundColor = UIColor(hexString: "BEC1DE")
        statusBarView.layer.cornerRadius = 8
        statusBarView.isSkeletonable = true
        statusBarView.showAnimatedGradientSkeleton()
        statusBarLabel.text = "Траты"
        statusBarLabel.font = UIFont(name: "", size: 16)
        statusBarLabel.anchor(left: statusBarView.leftAnchor, paddingLeft: 10)
        statusBarLabel.centerY(inView: statusBarView)
        
        amounPeriodLabel.text = "- \(totalExpenses ) Р"
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
        headerView.anchor(top: stackView2.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20, height: 80)
        
        //TableView set
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        tableView?.dataSource = self
        tableView?.delegate = self
        scrollView.addSubview(tableView ?? UITableView())
//        tableView?.isScrollEnabled = false
        tableView?.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
        tableView?.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryTableViewCell")
        tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView?.showsVerticalScrollIndicator = false
        
    
        //Right navigation button
        let item = UIBarButtonItem(image: UIImage(named: "pencil-3"), style: .done, target: self, action: #selector(customName))
        item.tintColor = UIColor(hexString: product?.fontDesignColor ?? "FFFFFF")
        self.navigationItem.setRightBarButton(item, animated: false)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView?.isSkeletonable = true
        tableView?.showAnimatedGradientSkeleton()
        self.collectionView(self.collectionView ?? UICollectionView(), didSelectItemAt: IndexPath(row: 0, section: 0))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.barTintColor = .white
//        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false

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
    
    @objc func onCloseScreen(){
        delegate.sendData(data: products)
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
               let nameTextField = alertController.textFields![0] as UITextField
            guard let idCard = self.product?.cardID else { return }
            guard let name = nameTextField.text else { return }
            let body = [ "id" : idCard,
                         "name" : name
                         ] as [String : AnyObject]
            
            NetworkManager<SaveCardNameDecodableModel>.addRequest(.saveCardName, [:], body) { model, error in
                if error != nil {
                    print("DEBUG: Error: ", error ?? "")
                }
                guard let model = model else { return }
                print("DEBUG: LatestPayment: ", model)
                if model.statusCode == 0 {
                    
//                    guard let lastPaymentsList  = model.data else { return }
                    guard let number = self.product?.numberMasked else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.card.cardNameLabel.text = name
                        self.products[self.indexItem ?? 0].customName = name
                        self.navigationItem.setTitle(title: name, subtitle: "· \(String(number.suffix(4)))", color: self.product?.fontDesignColor)
                    }
//                    self.dataUSD = lastPaymentsList
                } else {
                    print("DEBUG: Error: ", model.errorMessage ?? "")
                    self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")

                }
            }
           })
        
        let cancelAction = UIAlertAction(title: "Отмена", style: UIAlertAction.Style.default, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
           
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @objc func presentPaymentVC(){
        let vc = PaymentsViewController()
        vc.searchContact.isHidden = true
        vc.addCloseButton()
        present(vc, animated: true, completion: nil)
    }
    
    func presentRequisitsVc(product: GetProductListDatum) {
        
        let viewController = AccountDetailsViewController()
//        halfScreen = false
        viewController.product = product
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = self
        self.present(navController, animated: true, completion: nil)

    }
    
    @objc func showAlert(sender: AnyObject) {
        
        let viewController = PayViewController()
        halfScreen = false
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = self
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func blockProduct(){
        
        guard let idCard = self.product?.cardID else { return }
        guard let number = self.product?.number else { return }
        
        if button4.titleLabel?.text == "Блокировать"{

            let alertController = UIAlertController(title: "Заблокировать карту?", message: "Карту можно будет разблокировать в приложении или в колл-центре", preferredStyle: UIAlertController.Style.alert)
            
            let saveAction = UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: { alert -> Void in
                

                let body = [ "cardId": idCard,
                             "cardNumber": number
                             
                             ] as [String : AnyObject]
                
                NetworkManager<BlockCardDecodableModel>.addRequest(.blockCard, [:], body) { model, error in
                    if error != nil {
                        print("DEBUG: Error: ", error ?? "")
                        self.showAlert(with: "Ошибка", and: error ?? "")

                    }
                    guard let model = model else { return }
                    print("DEBUG: LatestPayment: ", model)
                    if model.statusCode == 0 {

                        DispatchQueue.main.async {

                            self.button4.setTitle("Разблокирова.", for: .normal)
                            self.button4.setImage(UIImage(named: "unlock"), for: .normal)
                            self.blockView.isHidden = false
                            self.button.isUserInteractionEnabled = false
                            self.button2.isUserInteractionEnabled = false
                            self.button.alpha = 0.4
                            self.button2.alpha = 0.4
                            self.navigationItem.setTitle(title: (self.product?.customName ?? self.product?.mainField)!, subtitle: "· \(String(number.suffix(4))) · Заблокирована", color: self.product?.fontDesignColor)

                            self.getCardList { data, errorMessage in
                                DispatchQueue.main.async {
                                guard let listProducts = data else {return}
                                self.products = listProducts
                                for i in listProducts{
                                    if self.product?.cardID == i.cardID{
                                        self.product = i
                                        break
                                    }
                                }

                            }
                        }
                            
                        }
                        guard let lastPaymentsList  = model.data else { return }
                        self.showAlert(with: "Карта заблокирована", and: "")
                        guard let number = self.product?.numberMasked else {
                            return
                        }
    //                    self.navigationItem.setTitle(title: name, subtitle: "· \(String(number.suffix(4)))", color: self.product?.fontDesignColor)
    //                    self.dataUSD = lastPaymentsList
                    } else {
                        print("DEBUG: Error: ", model.errorMessage ?? "")
                        self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")

                    }
                }
               })
            
            let cancelAction = UIAlertAction(title: "Отмена", style: UIAlertAction.Style.default, handler: nil)
            
            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)
               
            self.present(alertController, animated: true, completion: nil)
        } else {
     
                
                let alertController = UIAlertController(title: "Разблокировать карту?", message: "", preferredStyle: UIAlertController.Style.alert)
                
                let saveAction = UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: { alert -> Void in
                    

                    let body = [ "cardId": idCard,
                                 "cardNumber": number
                                 
                                 ] as [String : AnyObject]
                    
                    NetworkManager<UnBlockCardDecodableModel>.addRequest(.unblockCard, [:], body) { model, error in
                        if error != nil {
                            print("DEBUG: Error: ", error ?? "")
                            self.showAlert(with: "Ошибка", and: error ?? "")
                        }
                        guard let model = model else { return }
                        print("DEBUG: LatestPayment: ", model)
                        if model.statusCode == 0 {
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
                                self.navigationItem.setTitle(title: (self.product?.customName ?? self.product?.mainField)!, subtitle: "· \(String(number.suffix(4)))", color: self.product?.fontDesignColor)
                                
                                self.getCardList { data, errorMessage in
                                    DispatchQueue.main.async {
                                    guard let listProducts = data else {return}
                                    self.products = listProducts
                                    for i in listProducts {
                                        if self.product?.cardID == i.cardID{
                                            self.product = i
                                            break
                                        }
                                    }

                                }
                            }

                            }
                        } else {
                            self.showAlert(with: "Ошибка", and: error ?? "")
                            print("DEBUG: Error: ", model.errorMessage ?? "")
                        }
                    }
                   })
                
                let cancelAction = UIAlertAction(title: "Отмена", style: UIAlertAction.Style.default, handler: nil)
                
                alertController.addAction(cancelAction)
                alertController.addAction(saveAction)
                   
                self.present(alertController, animated: true, completion: nil)
                    }
    }
    
    func loadHistoryForCard(){
        historyArray.removeAll()
        historyArrayAccount.removeAll()
        sorted.removeAll()
        groupByCategory.removeAll()
        tableView?.reloadInputViews()
        statusBarView.showAnimatedGradientSkeleton()
        tableView?.reloadData()
        self.tableView?.reloadRows(at: self.tableView?.indexPathsForVisibleRows ?? [IndexPath(row: 0, section: 0)], with: .automatic)

        if product?.productType == "ACCOUNT"{
            totalExpenses = 0.0
            let body = ["id": product?.id
                         ] as [String : AnyObject]
            
            NetworkManager<GetAccountStatementDecodableModel>.addRequest(.getAccountStatement, [:], body) { model, error in
                if error != nil {
                    print("DEBUG: Error: ", error ?? "")
                }
                guard let model = model else { return }
                print("DEBUG: LatestPayment: ", model)
                if model.statusCode == 0 {
                    DispatchQueue.main.async {
                        guard let lastPaymentsList  = model.data else { return }
                        self.historyArrayAccount = lastPaymentsList
                        self.historyArray.removeAll()
                        self.historyArrayAccount.sort(by: { (a, b) -> Bool in
                            if let timestamp1 = a.date, let timestamp2 = b.date {
                                return timestamp1 > timestamp2
                            } else {
                                //At least one of your timestamps is nil.  You have to decide how to sort here.
                                return true
                            }
                        })
                        for i in self.historyArrayAccount{
                            let timeInterval = TimeInterval(i.tranDate ?? 0)
                            // create NSDate from Double (NSTimeInterval)
                            let myNSDate = Date(timeIntervalSince1970: timeInterval/1000)
                            print(myNSDate)
                            
                            if let timeResult = (i.tranDate) {
                                let date = Date(timeIntervalSince1970: TimeInterval(timeResult))
                                let dateFormatter = DateFormatter()
                                dateFormatter.timeStyle = DateFormatter.Style.none //Set time style
                                dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
                                dateFormatter.timeZone = .current
                                let localDate = dateFormatter.string(from: date)
                                print(localDate)
                            }
                        }
                      
                        for (index, element) in self.groupByCategory.enumerated() {
                            print("Index:", index, "Language:", element)
                        }
                        
                        for i in lastPaymentsList{
                            if i.operationType == "DEBIT"{
                                self.totalExpenses += Double(i.amount ?? 0.0)
                            }
                        }
                        
//                        self.groupByCategory = Dictionary(grouping: self.historyArrayAccount) { $0.tranDate ?? 0 }
                        func sortDict(indexKey: String, countElement: Int){
                            
                            self.groupByCategory.index(forKey: countElement)
                            
                        }
                        
//                        self.sortData = self.groupByCategory.sorted(by:{$0.key < $1.key})
                        self.tableView?.hideSkeleton()

                        self.statusBarView.stopSkeletonAnimation()
                        self.statusBarView.hideSkeleton()
                    }
    //                    self.dataUSD = lastPaymentsList
                } else {
                    print("DEBUG: Error: ", model.errorMessage ?? "")

                }
            }
        } else {
        totalExpenses = 0.0
        let body = ["cardNumber": product?.number
                     ] as [String : AnyObject]
        
        NetworkManager<GetCardStatementDecodableModel>.addRequest(.getCardStatement, [:], body) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: LatestPayment: ", model)
            if model.statusCode == 0 {
                DispatchQueue.main.async {
                    guard let lastPaymentsList  = model.data else { return }
                    self.historyArray = lastPaymentsList
                    self.historyArrayAccount.removeAll()
                    self.historyArray.sort(by: { (a, b) -> Bool in
                        if let timestamp1 = a.date, let timestamp2 = b.date {
                            return timestamp1 > timestamp2
                        } else {
                            //At least one of your timestamps is nil.  You have to decide how to sort here.
                            return true
                        }
                    })
                    for i in self.historyArray{
                        
                        if let timeResult = (i.tranDate) {
                            print(timeResult)
                            let date = Date(timeIntervalSince1970: TimeInterval(timeResult/1000) )
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeStyle = DateFormatter.Style.none //Set time style
                            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
                            dateFormatter.timeZone = .current
                            dateFormatter.locale = Locale(identifier: "ru_RU")
                            let localDate = dateFormatter.string(from: date)
                            print(localDate)
                        }
                    }
                    
                    
                    self.groupByCategory = Dictionary(grouping: self.historyArray) { $0.tranDate ?? 0 }
                    var unsortedCodeKeys = Array(self.groupByCategory.keys)
                    let sortedCodeKeys = unsortedCodeKeys.sort(by: >)
                        print(sortedCodeKeys)
//                    let dict = Dictionary(grouping: lastPaymentsList, by: { $0.tranDate ?? $0.date!/1000000 })
                    let dict = Dictionary(grouping: lastPaymentsList) { (element) -> Int in
                        
                        guard let tranDate =  element.tranDate else {
                            return Int(self.longIntToDateString(longInt: element.date!/1000)?.description.prefix(2) ?? "0") ?? 0
                        }
                        
                        return  Int(self.longIntToDateString(longInt: tranDate/1000)?.description.prefix(2) ?? "0") ?? 0
                                            }
                    
                    self.sorted = dict.sorted(by:{ ($0.value[0].tranDate ?? $0.value[0].date) ?? 0 > $1.value[0].tranDate ?? $1.value[0].date ?? 0})
                    self.tableView?.stopSkeletonAnimation()
                    self.tableView?.hideSkeleton()
                    self.statusBarView.stopSkeletonAnimation()
                    self.statusBarView.hideSkeleton()
//                    self.sorted = dict.sorted(by: { newItem1, newItem in
//                        if newItem1.value[0].tranDate != nil{
//                             newItem1.value[0].tranDate ?? 0 > newItem.value[0].tranDate ?? 0
//                        } else {
//                            newItem1.value[0].date ?? 0 > newItem.value[0].date ?? 0
//                        }
//                        return false
//                    })


//                    self.sortData = self.groupByCategory.sorted(by:{$0.key < $1.key})
                    for (index, element) in self.groupByCategory.enumerated() {
                        print("Index:", index, "Language:", element)
                    }
                    
                    for i in lastPaymentsList{
                        if i.operationType == "DEBIT"{
                            self.totalExpenses  += Double(i.amount ?? 0.0)
                        }
                    }
                    
                }
//                    self.dataUSD = lastPaymentsList
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")

            }
        }
    }
    }
}

extension ProductViewController{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case products.count:
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as? CardCollectionViewCell
    //        item?.card = products[indexPath.item]
            item?.cardImageView.image = UIImage(named: "cardMore")
//            item?.backgroundColor = .gray
//            item?.selectedView.isHidden = true
            
            item?.isSelected = false

            return item ?? UICollectionViewCell()
        default:
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as? CardCollectionViewCell
    //        item?.card = products[indexPath.item]
//            item?.selectedView.isHidden = true
            item?.cardImageView.image = products[indexPath.row].smallDesign?.convertSVGStringToImage()
            if firstTimeLoad{
                item?.isSelected = false
            }
            return item ?? UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tableView?.showAnimatedGradientSkeleton()
        historyArray.removeAll()
        historyArrayAccount.removeAll()
        sorted.removeAll()
        groupByCategory.removeAll()
        tableView?.reloadInputViews()
        tableView?.isSkeletonable = true
        
        statusBarView.showAnimatedGradientSkeleton()
       
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
        
        if firstTimeLoad{
            firstTimeLoad = false
            self.collectionView?.selectItem(at: IndexPath(item: indexItem ?? 0, section: 0), animated: true, scrollPosition: .bottom)
            let cell = collectionView.cellForItem(at: IndexPath(item: indexItem ?? 0, section: 0)) as? CardCollectionViewCell
            cell?.showSelect()
        } else {
            if indexPath.item < products.count{
                product = products[indexPath.item]
                self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
//                guard let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell else {return}
//                cell.showSelect()
            } else {
                self.collectionView?.deselectItem(at: indexPath, animated: true)
                let vc = ProductsViewController()
                vc.addCloseButton()
                present(vc, animated: true, completion: nil)
            }
        }
        if product?.status == "Заблокирована банком" || product?.status == "Блокирована по решению Клиента" || product?.status == "BLOCKED_CREDIT" || product?.status == "BLOCKED_DEBET" || product?.status == "BLOCKED", product?.statusPC == "3" || product?.statusPC == "5" || product?.statusPC == "6"  || product?.statusPC == "7"  || product?.statusPC == "20"  || product?.statusPC == "21" ||  product?.statusPC == nil{
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
        } else if product?.status == "Действует" || product?.status == "Выдано клиенту", product?.statusPC == "17"{
                button.isEnabled = false
                button.alpha = 0.4
                button2.isEnabled = false
                button2.alpha = 0.4
                button4.isEnabled = false
                button4.alpha = 0.4
                activateSlider.isHidden = false
                blockView.isHidden = true
        } else {
            button.isEnabled = true
            button.alpha = 1
            button2.isEnabled = true
            button2.alpha = 1
            button4.setTitle("Блокировать", for: .normal)
            button4.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            blockView.isHidden = true
            activateSlider.isHidden = true
            let btnImage4 = UIImage(named: "lock")
            button4.tintColor = .black
            button4.setImage(btnImage4 , for: .normal)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell
        cell?.hideSelect()
    }

    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell{
            
        }
    }
  
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell{
            
        }
    }
    
    

    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
//            let width = UIScreen.main.bounds.width
//           return CGSize(width: width, height: 50)
//       }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
//           return UIEdgeInsets(top: 20, left: 8, bottom: 5, right: 8)
//       }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//
//        let totalCellWidth = 50 * products.count
//        let totalSpacingWidth = 5 * (products.count - 1)
//
//        let leftInset = (collectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
//        let rightInset = leftInset
//
//        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
//    }
    
}

extension ProductViewController{

    func numberOfSections(in tableView: UITableView) -> Int {
        return sorted.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//            return groupByCategory[section].count
        var countSection = Array<Any>()
        
        sorted.map({
            print(countSection.append(($0.value as AnyObject).count ?? 0))
//            countSection.append(($0.value as AnyObject).count ?? 0)
            countSection.append(($0.value as AnyObject).count ?? 0)
        })
//        sorted[section].value.count
        return sorted[section].value.count

    }
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "HistoryTableViewCell"
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch historyArray.isEmpty{
        case false:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else { return  UITableViewCell() }
//            let data = groupByCategory.forEach({$0.value[indexPath.row]})
//            let section = groupByCategory[indexPath.section] as? Array<Any>
            let data = Array(groupByCategory.values)[indexPath.section]
//            sorted[indexPath.section].value[indexPath.item]
            cell.operation = sorted[indexPath.section].value[indexPath.row]
//            groupByCategory[index].value[indexPath.row]
            
            cell.titleLable.isSkeletonable = true
           
            cell.configure(currency: product?.currency ?? "RUB")
            cell.selectionStyle = .none
            return cell
        case true:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else { return  UITableViewCell() }
    //
    //        cell.titleLable.text = historyArray[indexPath.row].comment
      
            
            let data = Array(groupByCategory.values)[indexPath.section]
            print(data)
//            cell.accountOperation = (data as! [GetAccountStatementDatum])[indexPath.row]
//            groupByCategory[index].value[indexPath.row]
            cell.titleLable.isSkeletonable = true

            cell.configure(currency: product?.currency ?? "RUB")
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc = PaymentsDetailsSuccessViewController()
//        vc.button.isHidden = true
//        vc.addCloseButton_2()
//        vc.confurmView.operatorImageView.isHidden = true
//        vc.confurmView.statusImageView.isHidden = true
//        vc.confurmView.statusLabel.text = historyArray[indexPath.row].comment
//
////        if historyArray[indexPath.row].operationType == "DEBIT"{
////            vc.confurmView.summLabel.text = "+\(historyArray[indexPath.row].amount?.currencyFormatter(symbol: "RUB") ?? "")"
////        } else {
////            vc.confurmView.summLabel.text = "-\(historyArray[indexPath.row].amount?.currencyFormatter(symbol: "RUB") ?? "")"
////        }
//
//        if historyArray[indexPath.row].operationType == "DEBIT"{
////            vc.confurmView.summLabel.text = "-\(historyArray[indexPath.row].amount?.currencyFormatter(symbol: "RUB") ?? "")"
//        } else if historyArray[indexPath.row].operationType == "CREDIT"{
//            vc.confurmView.summLabel.textColor = UIColor(hexString: "22C183")
////            vc.confurmView.summLabel.text =  "+\(historyArray[indexPath.row].amount?.currencyFormatter(symbol: "RUB") ?? "")"
//        }
//
//        present(vc, animated: true, completion: nil)
        
        let vc = OperationDetailViewController()
       
        vc.documentId = "\(sorted[indexPath.section].value[indexPath.row].documentID ?? 0)"
        vc.categoryGroupLabel.text = sorted[indexPath.section].value[indexPath.row].groupName
        vc.transferImage.image = sorted[indexPath.section].value[indexPath.row].svgImage?.convertSVGStringToImage()
        if sorted[indexPath.section].value[indexPath.row].operationType == "DEBIT"{
            vc.amount.textColor = UIColor(hexString: "1C1C1C")
            vc.amount.text = "-\(Double(sorted[indexPath.section].value[indexPath.row].amount ?? 0.0).currencyFormatter(symbol:  product?.currency ?? "RUB"))"
        } else if sorted[indexPath.section].value[indexPath.row].operationType == "CREDIT"{
            vc.amount.textColor = UIColor(hexString: "1C1C1C")
            vc.amount.text = "+\(Double(sorted[indexPath.section].value[indexPath.row].amount ?? 0.0).currencyFormatter(symbol:  product?.currency ?? "RUB"))"
        }
//        vc.commissionLabel.text = sorted[indexPath.section].value[indexPath.row].comment
        if sorted[indexPath.section].value[indexPath.row].merchantNameRus != nil{
            vc.mainLabel.text = sorted[indexPath.section].value[indexPath.row].merchantNameRus
        } else {
            vc.mainLabel.text = sorted[indexPath.section].value[indexPath.row].merchantName
        }
        
        vc.addCloseButton_xMark()
//        vc.modalPresentationStyle = .pageSheet
//        vc.providesPresentationContextTransitionStyle = true
//        vc.definesPresentationContext = true
//        vc.transitioningDelegate = self
////        vc.transitioningDelegate = self
//        self.present(vc, animated: true, completion: nil)
//        self.navigationController?.pushViewController(vc, animated: true)
//        present(vc, animated: true, completion: nil)
        
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .custom
        navController.transitioningDelegate = self
        halfScreen = true
        self.present(navController, animated: true, completion: nil)

    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            
            headerView.showAnimatedGradientSkeleton()

            headerView.backgroundColor = .white
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height)
        
        if sorted.isEmpty == false{
            guard let tranDate = self.sorted[section].value[0].tranDate  else {
                label.text = longIntToDateString(longInt: self.sorted[section].value[0].date!/1000)
                label.font = .boldSystemFont(ofSize: 16)

                label.textColor =  UIColor(hexString: "1C1C1C")
                headerView.addSubview(label)
                label.centerY(inView: headerView)
                headerView.hideSkeleton()
                headerView.stopSkeletonAnimation()
                return headerView
            }
            label.text = longIntToDateString(longInt: tranDate/1000)

        }

            label.font = .boldSystemFont(ofSize: 16)

            label.textColor =  UIColor(hexString: "1C1C1C")
            headerView.addSubview(label)
            label.centerY(inView: headerView)
            return headerView
        }
  
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            tableView?.isScrollEnabled = (self.scrollView.contentOffset.y >= 200)
        }

        if scrollView == self.tableView {
            self.tableView?.isScrollEnabled = (tableView?.contentOffset.y ?? 0 > 0)
        }
    }
    
    
    func longIntToDateString(longInt: Int) -> String?{
        let date = Date(timeIntervalSince1970: TimeInterval(longInt))
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.none//Set time style
            dateFormatter.dateStyle = DateFormatter.Style.long //Set date style
            dateFormatter.timeZone = .current
            dateFormatter.locale = Locale(identifier: "ru_RU")
            let localDate = dateFormatter.string(from: date)
            print(localDate)
        
        
        
        return localDate
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
                completion(model.data, nil)
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")

                completion(nil, model.errorMessage)
            }
        }
    }
}

//extension ProductViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width:300 , height: 50)
//    }
//}



extension UINavigationItem {
    
    func setTitle(title:String, subtitle:String, color: String?) {
        let one = UILabel()
        one.text = title
        one.font = UIFont.systemFont(ofSize: 18)
        one.sizeToFit()
        
        let two = UILabel()
        two.text = subtitle
        two.font = UIFont.systemFont(ofSize: 12)
        two.textAlignment = .center
        two.sizeToFit()
        
        let stackView = UIStackView(arrangedSubviews: [one, two])
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        stackView.alignment = .center
        
        let width = max(one.frame.size.width, two.frame.size.width)
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: 35)
        
        one.textColor = UIColor(hexString: color ?? "FFFFFF")
        two.textColor = UIColor(hexString: color ?? "FFFFFF")

        one.sizeToFit()
        two.sizeToFit()
        
        self.titleView = stackView
    }
}

//extension UIView {
//func addoverlay(color: UIColor = .black,alpha : CGFloat = 0.6) {
//    let overlay = UIView()
//    overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//    overlay.frame = bounds
//    overlay.backgroundColor = color
//    overlay.alpha = alpha
//    addSubview(overlay)
//    }
//    //This function will add a layer on any `UIView` to make that `UIView` look darkened
//}

extension UIColor {
    private func makeColor(componentDelta: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Extract r,g,b,a components from the
        // current UIColor
        getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )
        
        // Create a new UIColor modifying each component
        // by componentDelta, making the new UIColor either
        // lighter or darker.
        return UIColor(
            red: add(componentDelta, toComponent: red),
            green: add(componentDelta, toComponent: green),
            blue: add(componentDelta, toComponent: blue),
            alpha: alpha
        )
    }
}

extension UIColor {
    // Add value to component ensuring the result is
    // between 0 and 1
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        return max(0, min(1, toComponent + value))
    }
}

extension UIColor {
    func lighter(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: componentDelta)
    }
    
    func darker(componentDelta: CGFloat = 0.1) -> UIColor {
        return makeColor(componentDelta: -1*componentDelta)
    }
}

extension ProductViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//        var presenter: UIPresentationController?
        
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        if halfScreen == true {
            presenter.height = 490
        } else {
            presenter.height = 310
            //            presenter = PresentationThirdController(presentedViewController: presented, presenting: presenting)
        }
        return presenter
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
}

