//
//  ProductViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 31.08.2021.
//

import UIKit

class ProductViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{

    var card = LargeCardCell()
    var mockItem: [PaymentsModel] = []

    var scrollView = UIScrollView()
    var collectionView: UICollectionView?
    var products = [GetProductListDatum]()
    var product: GetProductListDatum? {
        didSet{
            card.card = product
            backgroundView.backgroundColor = UIColor(hexString: product?.background[0] ?? "").darker()
            tableView?.reloadData()
            loadHistoryForCard()
            guard let number = product?.numberMasked else {
                return
            }
            navigationController?.navigationBar.barTintColor = UIColor(hexString: product?.background[0] ?? "").darker()
            self.navigationItem.setTitle(title: (product?.customName ?? product?.mainField)!, subtitle: "· \(String(number.suffix(4)))", color: product?.fontDesignColor)
            collectionView?.reloadData()
        }
    }
    var tableView: UITableView?
    var backgroundView = UIView()
    var topStackView = UIStackView()
//    var buttonStackView = UIStackView(arrangedSubviews: [])
    
    var historyArray = [GetCardStatementDataClass](){
        didSet{
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.bounces = false
        tableView?.bounces = false
        tableView?.isScrollEnabled = false
        view.addSubview(scrollView)
        scrollView.isScrollEnabled = true
//        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 21000)//or what ever size you want to set
        
        scrollView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 2000)
        let screenHeight = UIScreen.main.bounds.height
        let scrollViewContentHeight = 1200 as CGFloat
        func scrollViewDidScroll(scrollView: UIScrollView) {
            let yOffset = scrollView.contentOffset.y

            if scrollView == self.scrollView {
                if yOffset >= scrollViewContentHeight - screenHeight {
                    scrollView.isScrollEnabled = false
                    tableView?.isScrollEnabled = true
                }
            }

            if scrollView == self.tableView {
                if yOffset <= 0 {
                    self.scrollView.isScrollEnabled = true
                    self.tableView?.isScrollEnabled = false
                }
            }
        }
        _ = CardViewModel(card: self.product!)
        guard let number = product?.numberMasked else {
            return
        }
        self.navigationItem.setTitle(title: (product?.customName ?? product?.mainField)!, subtitle: "· \(String(number.suffix(4)))", color: product?.fontDesignColor)
        loadHistoryForCard()
        view.backgroundColor = .white
//        navigationController?.view.addoverlay(color: .black, alpha: 0.2)
        navigationController?.navigationBar.barTintColor = UIColor(hexString: product?.background[0] ?? "").darker()
//        UINavigationBar.appearance().tintColor =  UIColor(hexString: product?.fontDesignColor ?? "000000")
        addCloseColorButton(with: UIColor(hexString: product?.fontDesignColor ?? "000000"))


        scrollView.addSubview(backgroundView)
        scrollView.addSubview(card)
        
        backgroundView.backgroundColor = UIColor(hexString: product?.background[0] ?? "").darker()
        backgroundView.anchor(top: scrollView.topAnchor, left: view.leftAnchor, bottom: card.centerYAnchor, right: view.rightAnchor)
//        backgroundView.backgroundColor = UIColor(hex: "#\(product?.background[0] ?? "")")
//        view.backgroundColor = .red

        
        //Add buttons
        let button = UIButton()
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

        let button2 = UIButton()
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
        
     

        let button3 = UIButton()
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
        
        button3.addTarget(self, action: #selector(presentRequisitsVc), for: .touchUpInside)

        
        let button4 = UIButton()
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

        scrollView.addSubview(stackView)
        
        stackView.anchor(top: card.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20)
        
        
        stackView2.alignment = .fill
        stackView2.distribution = .fillEqually
        stackView2.spacing = 8.0

        stackView2.addArrangedSubview(button3)
        stackView2.addArrangedSubview(button4)
//        stackView.addArrangedSubview(button3)
//        stackView.addArrangedSubview(button4)

        scrollView.addSubview(stackView2)
        
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
        collectionView?.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: CGFloat(products.count) * 80,  height: 65)
//        collectionView?.contentInsetAdjustmentBehavior = .always
        collectionView?.centerX(inView: view)
        collectionView?.contentMode = .center
        
        //CardView set
        card.anchor(top: collectionView?.bottomAnchor, paddingTop: 0,  paddingBottom: 30,  width: 268, height: 160)
        card.backgroundColor = .clear
        card.centerX(inView: view)
        card.card = product
        card.backgroundImageView.image = product?.XLDesign?.convertSVGStringToImage()

        
        // UIView
        let headerView = UIView()
        let tableViewLabel = UILabel(text: "История операций", font: UIFont.boldSystemFont(ofSize: 20), color: UIColor(hexString: "#1C1C1C"))
        let filterButton = UIButton()
        scrollView.addSubview(headerView)
        headerView.addSubview(tableViewLabel)
        headerView.addSubview(filterButton)
        
        tableViewLabel.anchor(left: headerView.leftAnchor)
        filterButton.anchor(right: headerView.rightAnchor)
        filterButton.setImage(UIImage(imageLiteralResourceName: "more-horizontalProfile"), for: .normal)
        filterButton.setDimensions(height: 32, width: 32)
        filterButton.alpha = 0.3
        tableViewLabel.centerY(inView: filterButton)
        headerView.anchor(top: stackView2.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: 20, height: 20)
        
        //TableView set
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        tableView?.dataSource = self
        tableView?.delegate = self
        scrollView.addSubview(tableView ?? UITableView())
//        tableView?.isScrollEnabled = false
        tableView?.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
        tableView?.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryTableViewCell")
        tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView?.showsVerticalScrollIndicator = false
        
    
        //Right navigation button
        let item = UIBarButtonItem(image: UIImage(named: "pencil-3"), style: .done, target: self, action: #selector(customName))
        self.navigationItem.setRightBarButton(item, animated: false)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
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
                                     action: #selector(onClose))
        button.tintColor = color
        navigationItem.leftBarButtonItem = button
    }
    
    
    @objc func customName(){
        let alertController = UIAlertController(title: "Название карты", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
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
                        self.navigationItem.setTitle(title: name, subtitle: "· \(String(number.suffix(4)))", color: self.product?.fontDesignColor)
                    }
//                    self.dataUSD = lastPaymentsList
                } else {
                    print("DEBUG: Error: ", model.errorMessage ?? "")
                    self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                    DispatchQueue.main.async {
                        if model.errorMessage == "Пользователь не авторизован"{
                            AppLocker.present(with: .validate)
                        }
                    }
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
    
    @objc func presentRequisitsVc(){
        
        let body = [ "cardId": product?.cardID
                     ] as [String : AnyObject]
        
        NetworkManager<GetProductDetailsDecodableModel>.addRequest(.getProductDetails, [:], body) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            print("DEBUG: LatestPayment: ", model)
            if model.statusCode == 0 {
                DispatchQueue.main.async {
                    let viewController = RequisitesViewController()
                    let navController = UINavigationController(rootViewController: viewController)
                    self.mockItem = MockItems.returnsRequisits()
                    self.mockItem[0].description =  model.data?.payeeName
                    self.mockItem[1].description =  self.product?.accountNumber
                    self.mockItem[2].description =  self.product?.numberMasked
                    self.mockItem[3].description = model.data?.bic
                    self.mockItem[4].description = model.data?.corrAccount
                    self.mockItem[5].description = model.data?.inn
                    self.mockItem[6].description = model.data?.kpp
                    viewController.mockItem =  self.mockItem
                    viewController.product = self.product
                    navController.modalPresentationStyle = .custom
                    navController.transitioningDelegate = self
                    self.present(navController, animated: true, completion: nil)
                }
                
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                DispatchQueue.main.async {
                    if model.errorMessage == "Пользователь не авторизован"{
                        AppLocker.present(with: .validate)
                    }
                }
            }
        }
        
//        navController.modalPresentationStyle = .formSheet
//        present(navController, animated: true, completion: nil)
    }
    
    @objc func showAlert(sender: AnyObject) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        alert.title = nil
        alert.message = nil
        
        alert.addAction(UIAlertAction(title: "С моего счета в другом банке", style: .default , handler:{ (UIAlertAction)in
            self.getFastPaymentContractList { [weak self] contractList, error in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.showAlert(with: "Ошибка", and: error!)
                    } else {
                        let contr = contractList?.first?.fastPaymentContractAttributeList?.first
                        if contr?.flagClientAgreementIn == "NO" || contr?.flagClientAgreementOut == "NO" {
                            let vc = MeToMeSettingViewController()
                            if contractList != nil {
                                vc.model = contractList
                            } else {
                                vc.model = []
                            }
//                            vc.addCloseButton()
                            self?.navigationController?.pushViewController(vc, animated: true)
//                            let navVC = UINavigationController(rootViewController: vc)
//                            navVC.modalPresentationStyle = .fullScreen
//                            //                    navVC.addCloseButton()
//                            self?.present(navVC, animated: true, completion: nil)
                        } else {
                            
                            let viewController =  MeToMeViewController()
                            viewController.meToMeContract = contractList
                            self?.navigationController?.pushViewController(viewController, animated: true)
//                            viewController.addCloseButton()
//                            let navVC = UINavigationController(rootViewController: viewController)
//                            navVC.modalPresentationStyle = .fullScreen
//                            self?.present(navVC, animated: true)
                        }
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Со своего счета", style: .default , handler:{ (UIAlertAction)in
            let popView = CustomPopUpWithRateView()
            popView.onlyMy = false
            popView.modalPresentationStyle = .custom
            popView.transitioningDelegate = self
            self.present(popView, animated: true, completion: nil)
        }))

        alert.addAction(UIAlertAction(title: "С карты в другом банке", style: .default , handler:{ (UIAlertAction)in
            let popView = MemeDetailVC()
            popView.onlyMy = false
            popView.onlyCard = true
            popView.titleLabel.text = "На другую карту"
            popView.modalPresentationStyle = .custom
            popView.transitioningDelegate = self
            self.present(popView, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))

        
        //uncomment for iPad Support
        //alert.popoverPresentationController?.sourceView = self.view

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    @objc func blockProduct(){
        let alertController = UIAlertController(title: "Заблокироать карту?", message: "Карту можно будет разблокироать в колл-центре", preferredStyle: UIAlertController.Style.alert)
        
        let saveAction = UIAlertAction(title: "Ок", style: UIAlertAction.Style.default, handler: { alert -> Void in
            
            guard let idCard = self.product?.cardID else { return }
            guard let number = self.product?.number else { return }

            let body = [ "cardId": idCard,
                         "cardNumber": number
                         
                         ] as [String : AnyObject]
            
            NetworkManager<BlockCardDecodableModel>.addRequest(.blockCard, [:], body) { model, error in
                if error != nil {
                    print("DEBUG: Error: ", error ?? "")
                }
                guard let model = model else { return }
                print("DEBUG: LatestPayment: ", model)
                if model.statusCode == 0 {
//                    DispatchQueue.main.async {
//
//
//                        let body = [ "cardId": idCard,
//                                     "cardNumber": number
//                        ] as [String : AnyObject]
//
//                    NetworkManager<UnBlockCardDecodableModel>.addRequest(.unblockCard, [:], body) { model, error in
//                        if error != nil {
//                            print("DEBUG: Error: ", error ?? "")
//                        }
//                        guard let model = model else { return }
//                        print("DEBUG: LatestPayment: ", model)
//                        if model.statusCode == 0 {
//
//        //                    guard let lastPaymentsList  = model.data else { return }
//                            guard let number = self.product?.numberMasked else {
//                                return
//                            }
////                            self.navigationItem.setTitle(title: name, subtitle: "· \(String(number.suffix(4)))", color: self.product?.fontDesignColor)
//        //                    self.dataUSD = lastPaymentsList
//                        } else {
//                            print("DEBUG: Error: ", model.errorMessage ?? "")
//                            DispatchQueue.main.async {
//                                if model.errorMessage == "Пользователь не авторизован"{
//                                    AppLocker.present(with: .validate)
//                                }
//                            }
//                        }
//                    }
//                    }
//                    guard let lastPaymentsList  = model.data else { return }
                    self.showAlert(with: "Карта заблокирована", and: "")
                    guard let number = self.product?.numberMasked else {
                        return
                    }
//                    self.navigationItem.setTitle(title: name, subtitle: "· \(String(number.suffix(4)))", color: self.product?.fontDesignColor)
//                    self.dataUSD = lastPaymentsList
                } else {
                    print("DEBUG: Error: ", model.errorMessage ?? "")
                    self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")

                    DispatchQueue.main.async {
                        if model.errorMessage == "Пользователь не авторизован"{
                            AppLocker.present(with: .validate)
                        }
                    }
                }
            }
           })
        
        let cancelAction = UIAlertAction(title: "Отмена", style: UIAlertAction.Style.default, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
           
        self.present(alertController, animated: true, completion: nil)
    }
    
    func loadHistoryForCard(){
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
                    self.historyArray.sort(by: { (a, b) -> Bool in
                        if let timestamp1 = a.date, let timestamp2 = b.date {
                            return timestamp1 > timestamp2
                        } else {
                            //At least one of your timestamps is nil.  You have to decide how to sort here.
                            return true
                        }
                    })
                    for i in self.historyArray{
                        let timeInterval = TimeInterval(i.date ?? 0)
                        // create NSDate from Double (NSTimeInterval)
                        let myNSDate = Date(timeIntervalSince1970: timeInterval)
                        print(myNSDate)
                        
                        if let timeResult = (i.date) {
                            let date = Date(timeIntervalSince1970: TimeInterval(timeResult))
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
                            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
                            dateFormatter.timeZone = .current
                            let localDate = dateFormatter.string(from: date)
                            print(localDate)
                        }
                    }
                    
                }
//                    self.dataUSD = lastPaymentsList
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
            return item ?? UICollectionViewCell()
        default:
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as? CardCollectionViewCell
    //        item?.card = products[indexPath.item]
//            item?.selectedView.isHidden = true
            item?.cardImageView.image = products[indexPath.row].smallDesign?.convertSVGStringToImage()
            return item ?? UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        switch indexPath.row {
//        case products.count:
//            let vc = ProductsViewController()
//            vc.addCloseButton()
//            present(vc, animated: true, completion: nil)
//        default:
//            if let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell{
//                product = products[indexPath.row]
//                cell.showSelect()
//            }
//
////            cell?.selectedView?.backgroundColor = .black
////            cell?.selectedView.layer.cornerRadius = cell?.frame.size.width ?? 0/2
//
//        }
        if indexPath.row < products.count{
            let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell
            cell?.showSelect()
            

        } else {
            let vc = ProductsViewController()
            vc.addCloseButton()
            present(vc, animated: true, completion: nil)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell else { return  UITableViewCell() }
        if historyArray[indexPath.row].operationType == "DEBIT"{
            cell.amountLabel.textColor = UIColor(hexString: "22C183")
            cell.amountLabel.text = "+\(historyArray[indexPath.row].amount?.currencyFormatter(symbol: "RUB") ?? "")"
        } else {
            cell.amountLabel.text =  "-\(historyArray[indexPath.row].amount?.currencyFormatter(symbol: "RUB") ?? "")"
        }
        
        cell.titleLable.text = historyArray[indexPath.row].comment
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PaymentsDetailsSuccessViewController()
        vc.button.isHidden = true
        vc.addCloseButton_2()
        vc.confurmView.operatorImageView.isHidden = true
        vc.confurmView.statusImageView.isHidden = true
        vc.confurmView.statusLabel.text = historyArray[indexPath.row].comment
        
        if historyArray[indexPath.row].operationType == "DEBIT"{
            vc.confurmView.summLabel.text = "+\(historyArray[indexPath.row].amount?.currencyFormatter(symbol: "RUB") ?? "")"
        } else {
            vc.confurmView.summLabel.text = "-\(historyArray[indexPath.row].amount?.currencyFormatter(symbol: "RUB") ?? "")"
        }
        
        present(vc, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 0))
            headerView.backgroundColor = .white
            let label = UILabel()
            label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height)
            label.text = ""
            label.font = .systemFont(ofSize: 16)
            label.textColor = .black
            headerView.backgroundColor = .white
            headerView.addSubview(label)
            
            return headerView
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
                DispatchQueue.main.async {
                if model.errorMessage == "Пользователь не авторизован"{
                    AppLocker.present(with: .validate)
                }
                }
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
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

