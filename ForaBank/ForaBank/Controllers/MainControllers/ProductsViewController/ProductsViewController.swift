//
//  ProductsViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 30.08.2021.
//

import UIKit

class ProductsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    var totalMoney: Double = 0.0 {
        didSet{
            totalMoneyView.totalBalance.text = String(totalMoney.currencyFormatter(symbol: ""))
        }
    }
    
    weak var delegateProducts: CtoBDelegate?

    var products = [GetProductListDatum](){
        didSet {
            DispatchQueue.main.async {
                self.totalMoney = 0.0
                self.notActivated.removeAll()
                for i in self.products{
                    self.totalMoney += i.balance ?? 0.0
                    self.blocked.removeAll()
                    self.activeProduct.removeAll()
                    self.notActivated.removeAll()
                    for i in self.products {
                        if i.statusPC == "17", i.status == "Действует" || i.status == "Выдано клиенту"{
                            self.notActivated.append(i)
                            continue
                        } else if i.status == "Заблокирована банком" || i.status == "Блокирована по решению Клиента" || i.status == "BLOCKED_DEBET" || i.status == "BLOCKED_CREDIT" || i.status == "BLOCKED", i.statusPC == "3" || i.statusPC == "5" || i.statusPC == "6"  || i.statusPC == "7"  || i.statusPC == "20"  || i.statusPC == "21" || i .statusPC == nil {
                            self.blocked.append(i)
                            continue
                        } else if  i.statusPC == "0" || i.statusPC == nil, i.status == "Действует" || i.status == "NOT_BLOCKED"{
                            self.activeProduct.append(i)
                            continue
                        }
                        
                        
                    }
                }
                
                self.tableView?.reloadData()
            }
        }
    }
    
    var blocked = [GetProductListDatum](){
        didSet{
            
            self.tableView?.reloadData()
            
        }
    }
    
    var activeProduct = [GetProductListDatum](){
        didSet{
            self.tableView?.reloadData()
            
        }
    }
    
    var notActivated = [GetProductListDatum](){
        didSet{
            self.tableView?.reloadData()
            
        }
    }
    let totalMoneyView: TotalMoneyView = UIView.fromNib()

    var tableView: UITableView!
    var sectionData: [PaymentsModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCardList { products, errorMessage in
            self.products = products ?? []
        }
        sectionData = MockItems.returnSectionInProducts()
        
        // Do any additional setup after loading the view.
        setupUI()
    }
    

    func setupUI() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.view.backgroundColor =  .white
        navigationController?.navigationBar.backgroundColor = .white
        title = "Мои продукты"
        totalMoneyView.backgroundColor = .clear
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(action))
        self.navigationItem.rightBarButtonItem?.tintColor = .black


        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
//        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView?.anchor(top: totalMoneyView.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, width: 200, height: 500)
        tableView = UITableView(frame: CGRect(x: 0, y: totalMoneyView.bounds.height, width: displayWidth, height: displayHeight))
        tableView.register(ProductTableViewCell.nib(), forCellReuseIdentifier: ProductTableViewCell.identifier)
        tableView?.delegate = self
        tableView?.dataSource = self

        
        
        view.addSubview(totalMoneyView)
        view.addSubview(tableView)
        tableView?.anchor(top: totalMoneyView.bottomAnchor ,left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,paddingTop: 10)
//        tableView.layoutMargins = .init(top: 0.0, left: 23.5, bottom: 0.0, right: 23.5)
         // if you want the separator lines to follow the content width
         tableView.separatorInset = tableView.layoutMargins
        totalMoneyView.anchor(top: view.topAnchor ,left: view.leftAnchor,
                          right: view.rightAnchor, paddingTop: 10, paddingBottom: 5, paddingRight: 10)
        
        tableView?.backgroundColor = .white
        tableView.separatorStyle = .none
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 0.965, green: 0.965, blue: 0.969, alpha: 1)
        totalMoneyView.backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.969, alpha: 1)
        

        view.backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.969, alpha: 1)
        
        
        
    
        
    }
    @objc func action(sender: UIBarButtonItem) {
        guard let url = URL(string: "https://promo.forabank.ru" ) else { return  }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectionData[section].name{
            case "Неактивированные продукты":
                return notActivated.count
            case "Карты и счета":
                return activeProduct.count
            case "Заблокированные продукты":
                return blocked.count
        default:
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier, for: indexPath) as! ProductTableViewCell
        switch sectionData[indexPath.section].name{
        case "Неактивированные продукты":
            if notActivated.count > 0{
                let str = notActivated[indexPath.row].numberMasked ?? ""
                cell.titleProductLabel.text = notActivated[indexPath.row].customName ?? notActivated[indexPath.row].mainField
                cell.numberProductLabel.text = "\(str.suffix(4))"
                cell.balanceLabel.text = "\(notActivated[indexPath.row].balance?.currencyFormatter(symbol: notActivated[indexPath.row].currency ?? "") ?? "")"
                cell.coverpProductImage.image = notActivated[indexPath.row].smallDesign?.convertSVGStringToImage()
                cell.cardTypeImage.image = notActivated[indexPath.row].paymentSystemImage?.convertSVGStringToImage()
                cell.typeOfProduct.text = notActivated[indexPath.row].additionalField
                if notActivated[indexPath.row].paymentSystemImage == nil{
                    cell.cardTypeImage.isHidden = true
                }
            }
        case "Карты и счета":
            if activeProduct.count > 0{
                let str = activeProduct[indexPath.row].numberMasked ?? ""
                cell.titleProductLabel.text = activeProduct[indexPath.row].customName ?? activeProduct[indexPath.row].mainField
                cell.numberProductLabel.text = "\(str.suffix(4))"
                cell.balanceLabel.text = "\(activeProduct[indexPath.row].balance?.currencyFormatter(symbol: activeProduct[indexPath.row].currency ?? "") ?? "")"
                cell.coverpProductImage.image = activeProduct[indexPath.row].smallDesign?.convertSVGStringToImage()
                cell.cardTypeImage.image = activeProduct[indexPath.row].paymentSystemImage?.convertSVGStringToImage()
                cell.typeOfProduct.text = activeProduct[indexPath.row].additionalField
                if activeProduct[indexPath.row].paymentSystemImage == nil{
                    cell.cardTypeImage.isHidden = true
                }
            }
        case "Заблокированные продукты":
            if blocked.count > 0{
                let str = blocked[indexPath.item].numberMasked ?? ""
                cell.titleProductLabel.text = blocked[indexPath.item].customName ?? blocked[indexPath.item].mainField
                cell.numberProductLabel.text = "\(str.suffix(4))"
                cell.balanceLabel.text = "\(blocked[indexPath.item].balance?.currencyFormatter(symbol: blocked[indexPath.item].currency ?? "") ?? "")"
                cell.coverpProductImage.image = blocked[indexPath.item].smallDesign?.convertSVGStringToImage()
                cell.cardTypeImage.image = blocked[indexPath.item].paymentSystemImage?.convertSVGStringToImage()
                cell.typeOfProduct.text = blocked[indexPath.item].additionalField
                if blocked[indexPath.item].paymentSystemImage == nil{
                    cell.cardTypeImage.isHidden = true
                }
            }
        default:
//            cell.backgroundColor = .blue
            print("nil")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegateProducts == nil {
            let viewController = ProductViewController()
//            viewController.products = products
//            viewController.indexItem = indexPath.item
            viewController.firstTimeLoad = true
            switch indexPath.section{
                case 0:
                viewController.product = self.notActivated[indexPath.row]
                case 1:
                viewController.product = self.activeProduct[indexPath.row]
                case 6:
                viewController.product = self.blocked[indexPath.row]
            default:
                print("default")
            }
            let navVC = UINavigationController(rootViewController: viewController)
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
            
        } else {
            switch indexPath.section{
                case 0:
                delegateProducts?.sendMyDataBack(product: self.notActivated[indexPath.row])
                case 1:
                delegateProducts?.sendMyDataBack(product: self.activeProduct[indexPath.row])
                case 6:
                delegateProducts?.sendMyDataBack(product: self.blocked[indexPath.row])
            default:
                print("default")
            }
    //        delegateProducts?.sendMyDataBack(product: self.products[0])
            dismiss(animated: true, completion: nil)
        }
    }
    

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            if indexPath.section == 0, sectionData[0].name == "Неактивированные продукты"{
                let title = "Активировать"

                let action = UIContextualAction(style: .normal, title: title,
                  handler: { (action, view, completionHandler) in
                  // Update data source when user taps action
                    self.activateProduct(idCard: self.notActivated[indexPath.row].cardID, number: self.notActivated[indexPath.row].number)

                  completionHandler(true)
                })
              action.backgroundColor = .systemGreen
                let configuration = UISwipeActionsConfiguration(actions: [action])
                  configuration.performsFirstActionWithFullSwipe = true
                return configuration
            } else {
                return nil
            }
        }
    
         func tableView(_ tableView: UITableView,
          editingStyleForRowAt indexPath: IndexPath)
        -> UITableViewCell.EditingStyle {
          return .none
        }
    
    private func activateProduct(idCard: Int?, number: String?) {
            
            let alertController = UIAlertController(title: "Активировать карту?", message: "После активации карта будет готова к использованию", preferredStyle: .alert)
               let doneAction = UIAlertAction(title: "OK", style: .default) { (action) in
                   
                   guard let idCard = idCard else { return }
                   guard let number = number else { return }
                   
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
                               self.getCardList{ cardList,error in
                                   print("")
                               }

                           }
                       } else {
                           self.showAlert(with: "Ошибка", and: error ?? "")
                           print("DEBUG: Error: ", model.errorMessage ?? "")
                       }
                   }
                   
               }
                let cancelAction = UIAlertAction(title: "Отмена", style: .default) { (action) in
                    
                }
                alertController.addAction(cancelAction)
                alertController.addAction(doneAction)
                present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            let label = UILabel()
            label.frame = CGRect.init(x: 20, y: 0, width: headerView.frame.width-10, height: headerView.frame.height-10)
            label.text = sectionData[section].name
            label.font = .boldSystemFont(ofSize: 18)
            label.textColor = .black
            label.alpha = 0.3
            headerView.addSubview(label)
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            button.setImage(UIImage(systemName: "arrow"), for: .normal)
                        
            headerView.backgroundColor = .white
            headerView.addSubview(button)
            button.anchor(left: label.leftAnchor, paddingLeft: 10, width: 24, height: 24)
            switch sectionData[section].name {
            case "Неактивированные продукты":
                if notActivated.count > 0 {
                    label.alpha = 1
                } else{
                    label.alpha = 0.3
                    
                }

            case "Карты и счета":
                if activeProduct.count == 0 {
                    label.alpha = 0.3
                } else {
                    label.alpha = 1
                }
            case "Заблокированные продукты":
                if blocked.count > 0 {
                    label.alpha = 1
                } else{
                    label.alpha = 0.3
                }
                
                
            default:
                print("")
            }
            return headerView
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch sectionData[section].name {
        case "Неактивированные продукты":
            if notActivated.count > 0 {
                return 50
            } else{
                return 0
            }

        case "Заблокированные продукты":
            if blocked.count > 0 {
                return 50
            } else{
                return 0
            }
            
            
        default:
            return 50
        }
        
    }
    
    private func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?, _ error: String?) ->() ) {
        
        let param = ["isCard": "true", "isAccount": "true", "isDeposit": "false", "isLoan": "false"]
        
        NetworkManager<GetProductListDecodableModel>.addRequest(.getProductListByFilter, param, [:]) { model, error in
            if error != nil {
                completion(nil, error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                guard let cardList = model.data else { return }
                self.products = model.data ?? []
                completion(cardList, nil)
            } else {
                guard let error = model.errorMessage else { return }
                completion(nil, error)
            }
        }
}
}


