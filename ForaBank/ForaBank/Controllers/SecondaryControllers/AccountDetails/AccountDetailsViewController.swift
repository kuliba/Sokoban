//
//  AccountDetailsViewController.swift
//  ForaBank
//
//  Created by Mikhail on 08.11.2021.
//

import UIKit

class AccountDetailsViewController: UIViewController {

    let cellReuse = "PayTableViewCell"
    var productType: String?
    var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    var openControlButtons = false
    var product: UserAllCardsModel?
    var mockItem = MockItems.returnsRequisits()
    var mockItemsDeposit = MockItems.returnsDepositInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupTableView()

    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.anchor(
            top: view.topAnchor, left: view.leftAnchor,
            bottom: view.bottomAnchor, right: view.rightAnchor,
            paddingTop: 20, paddingLeft: 20,
            paddingBottom: 20, paddingRight: 20)
        tableView.register(UINib(nibName: cellReuse, bundle: nil), forCellReuseIdentifier: cellReuse)
        tableView.separatorStyle = .none
        tableView.rowHeight = 56
    }
    
    
    func presentRequisitsVc(product: UserAllCardsModel?){
        showActivity()
        var body: [String : AnyObject]
        
        switch product?.productType {
            
        case ProductType.card.rawValue:
            body = ["cardId": product?.cardID] as [String : AnyObject]
            
        case ProductType.account.rawValue:
            body = ["accountId": product?.id] as [String : AnyObject]

        case ProductType.deposit.rawValue:
            body = ["depositId": product?.id] as [String : AnyObject]

        case ProductType.loan.rawValue:
            body = ["accountId": product?.settlementAccountId] as [String : AnyObject]

        default:
            body = ["cardId": product?.cardID] as [String : AnyObject]

        }
        
        NetworkManager<GetProductDetailsDecodableModel>.addRequest(.getProductDetails, [:], body) { model, error in
            self.dismissActivity()
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                DispatchQueue.main.async {
                    let viewController = RequisitesViewController()
                    let navController = UINavigationController(rootViewController: viewController)
                    self.mockItem[0].description = model.data?.payeeName
                    self.mockItem[1].description = product?.accountNumber
                    self.mockItem[2].description = model.data?.bic
                    self.mockItem[3].description = model.data?.corrAccount
                    self.mockItem[4].description = model.data?.inn
                    self.mockItem[5].description = model.data?.kpp
                    self.mockItem[6].description = model.data?.holderName
                    self.mockItem[7].description = model.data?.maskCardNumber
                    self.mockItem[8].description = model.data?.expireDate
                    if product?.productType == "DEPOSIT"{
                        self.mockItem[8].name = "Вклад действует до"
                    }
                    let newArray = self.mockItem.filter { $0.description != "" }
                    viewController.addCloseButton()
                    viewController.addCloseButton_3()
                    viewController.mockItem = newArray
                    viewController.product = product
                    viewController.model = model.data
                    navController.modalPresentationStyle = .fullScreen
                    navController.transitioningDelegate = self
                    
                    self.dismiss(animated: true) {
                        let topvc = UIApplication.topViewController()
                        topvc?.present(navController, animated: true)
                    }
//                    self.present(navController, animated: true, completion: nil)
                }
                
            } else {
                self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")

            }
        }
        

    }
    func longIntToDateString(longInt: Int) -> String?{
        let date = Date(timeIntervalSince1970: TimeInterval(longInt/1000))
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = DateFormatter.Style.none//Set time style
            dateFormatter.dateStyle = DateFormatter.Style.long //Set date style
            
            dateFormatter.dateFormat =  "d MMMM yyyy"
            dateFormatter.timeZone = .current
            dateFormatter.locale = Locale(identifier: "ru_RU")
            var localDate = dateFormatter.string(from: date)
            print(localDate)
            if localDate == "1 января 1970"{
                localDate = "-"
            }
        
        return localDate
    }
    
    func presentToDepositInfo(product: UserAllCardsModel?){
        showActivity()
        let bodyForInfo = ["id": product?.id] as [String : AnyObject]

    
        NetworkManager<DepositInfoGetDepositInfoDecodebleModel>.addRequest(.getDepositInfo, [:], bodyForInfo) { model, error in
            self.dismissActivity()
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                DispatchQueue.main.async {
                    let viewController = RequisitesViewController()
                    let navController = UINavigationController(rootViewController: viewController)
                    self.mockItemsDeposit[0].description = model.data?.initialAmount?.currencyFormatter(symbol:  product?.currency ?? "RUB")
                    self.mockItemsDeposit[1].description = self.longIntToDateString(longInt: model.data?.dateOpen ?? 0)
                    self.mockItemsDeposit[2].description = self.longIntToDateString(longInt:  model.data?.dateEnd  ?? 0)
                    self.mockItemsDeposit[3].description = model.data?.termDay
                    self.mockItemsDeposit[4].description = String("\(model.data?.interestRate ?? 0.0) %")
                    
                    self.mockItemsDeposit[5].description = self.longIntToDateString(longInt:  model.data?.dateNext  ?? 0)
                    self.mockItemsDeposit[6].description = model.data?.sumPayInt?.currencyFormatter(symbol:  product?.currency ?? "RUB")
                    self.mockItemsDeposit[7].description = model.data?.sumCredit?.currencyFormatter(symbol:  product?.currency ?? "RUB")
                    self.mockItemsDeposit[8].description = model.data?.sumDebit?.currencyFormatter(symbol:  product?.currency ?? "RUB")
                    self.mockItemsDeposit[9].description = model.data?.sumAccInt?.currencyFormatter(symbol:  product?.currency ?? "RUB")

                    let newArray = self.mockItemsDeposit.filter { $0.description != "" || $0.description != "0.0"}
                    viewController.addCloseButton()
                    viewController.addCloseButton_3()
                    viewController.mockItem = newArray
                    viewController.product = product
                    viewController.modelDeposit = model.data
                    navController.modalPresentationStyle = .fullScreen
                    navController.transitioningDelegate = self
                    self.dismiss(animated: true) {
                        let topvc = UIApplication.topViewController()
                        topvc?.present(navController, animated: true)
                    }
                }
                
            } else {
                self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
            }
        }
    }
    
    func getPrintFormForDepositConditions() {
        
    }
    
}

extension AccountDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if product?.productType == "DEPOSIT", openControlButtons == true{
            return 3
        } else {
            
            switch product?.productType {
            case "DEPOSIT":
                return 6
            default:
                return 2
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuse, for: indexPath) as? PayTableViewCell else { return UITableViewCell() }
        
        switch product?.productType {
        case ProductType.deposit.rawValue:
            
            if product?.productType == "DEPOSIT", openControlButtons == false {
                switch indexPath.row {
                case 0:
                    cell.titleLabel.text = "Реквизиты счета вклада"
                    cell.imageButton.image = UIImage(named: "requisitsButton")
                case 1:
                    cell.titleLabel.text = "Выписка по счету"
                    cell.imageButton.image = UIImage(named: "dischargeButton")
                case 2:
                    cell.titleLabel.text = "Информация по вкладу"
                    cell.imageButton.image = UIImage(named: "infoButton")
                case 3:
                    cell.titleLabel.text = "Лимиты на операции"
                    cell.imageButton.image = UIImage(named: "limitButton")
                    cell.alpha = 0.3
                    cell.isUserInteractionEnabled = false
                case 4:
                    cell.titleLabel.text = "График выплаты % по вкладу"
                    cell.imageButton.image = UIImage(named: "scheduleButton")
                    cell.alpha = 0.3
                    cell.isUserInteractionEnabled = false

                case 5:
                    cell.titleLabel.text = "Условия по вкладу"
                    cell.imageButton.image = UIImage(named: "conditionButton")
                    cell.alpha = 0.3
                    cell.isUserInteractionEnabled = false
                default:
                    cell.titleLabel.text = "default"
                    cell.imageButton.image = UIImage(named: "otherAccountButton")
                }
                cell.imageButton.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
                cell.selectionStyle = .none
            } else  if product?.productType == "DEPOSIT", openControlButtons == true {
                switch indexPath.row {
                case 0:
                    cell.titleLabel.text = "Закрыть вклад"
                    cell.imageButton.image = UIImage(named: "closeDeposit")
                case 1:
                    cell.titleLabel.text = "Скрыть с главной"
                    cell.imageButton.image = UIImage(named: "hideDeposit")
                case 2:
                    cell.titleLabel.text = "Заказать справку"
                    cell.imageButton.image = UIImage(named: "requisitsButton")
                default:
                    cell.titleLabel.text = "default"
                    cell.imageButton.image = UIImage(named: "otherAccountButton")
                }
                cell.imageButton.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
                cell.selectionStyle = .none
            }
        case ProductType.account.rawValue, ProductType.loan.rawValue:
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Реквизиты счета"
                cell.imageButton.image = UIImage(named: "requisitsButton")
            case 1:
                cell.titleLabel.text = "Выписка по счету"
                cell.imageButton.image = UIImage(named: "dischargeButton")
            default:
                cell.titleLabel.text = "default"
                cell.imageButton.image = UIImage(named: "otherAccountButton")
            }
        default:
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Реквизиты счета карты"
                cell.imageButton.image = UIImage(named: "requisitsButton")
            case 1:
                cell.titleLabel.text = "Выписка по счету"
                cell.imageButton.image = UIImage(named: "dischargeButton")
            default:
                cell.titleLabel.text = "default"
                cell.imageButton.image = UIImage(named: "otherAccountButton")
            }
        }
          
            cell.imageButton.tintColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
            cell.selectionStyle = .none
        return cell
    }
    
}

extension AccountDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            presentRequisitsVc(product: product)
        case 1:
            let controller = AccountStatementController()
            controller.modalPresentationStyle = .fullScreen
            controller.startProduct = product
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = .fullScreen
            self.dismiss(animated: true) {
                let topvc = UIApplication.topViewController()
                topvc?.present(navController, animated: true)
            }
        case 5:
            let pdfViewerVC = PDFViewerViewController()
            pdfViewerVC.modalPresentationStyle = .fullScreen
            pdfViewerVC.id = product?.id
            pdfViewerVC.printFormType = "depositConditions"
            let navController = UINavigationController(rootViewController: pdfViewerVC)
            navController.modalPresentationStyle = .fullScreen
            self.dismiss(animated: true) {
                let topvc = UIApplication.topViewController()
                topvc?.present(navController, animated: true)
            }
        default:
            self.dismiss(animated: true, completion: nil)
        }
    }
}

    
extension AccountDetailsViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        presenter.height = 460
        return presenter
    }
}

