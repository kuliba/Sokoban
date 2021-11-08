//
//  AccountDetailsViewController.swift
//  ForaBank
//
//  Created by Mikhail on 08.11.2021.
//

import UIKit

class AccountDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let cellReuse = "PayTableViewCell"
    
    var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    
    let product: GetProductListDatum
    
    init(product: GetProductListDatum) {
        self.product = product
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
//        setupUI()
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
    
//    func setupUI(){
//        let label = UILabel()
//        label.textColor = UIColor.black
//        label.font = UIFont.boldSystemFont(ofSize: 16)
//        label.text = "Пополнить"
//        navigationController?.navigationBar.barTintColor = .white
//
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
//        self.navigationItem.leftItemsSupplementBackButton = true
//        let close = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(backButton))
//        close.tintColor = .black
//        //        self.navigationItem.setRightBarButton(close, animated: true)
//
//        //        self.navigationItem.rightBarButtonItem?.action = #selector(backButton)
//        self.navigationItem.rightBarButtonItem = close
//        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
//        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .highlighted)
//    }
//
//    @objc func backButton(){
//        dismiss(animated: true, completion: nil)
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuse, for: indexPath) as? PayTableViewCell else { return UITableViewCell() }
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = "Реквизиты счета карты"
            cell.imageButton.image = UIImage(named: "sbpButton2")
        case 1:
            cell.titleLabel.text = "Выписка по счету"
            cell.imageButton.image = UIImage(named: "myAccountButton")
        default:
            cell.titleLabel.text = "defaul"
            cell.imageButton.image = UIImage(named: "otherAccountButton")
        }
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            presentRequisitsVc(product: product)
            
        case 1:
            let popView = CustomPopUpWithRateView()
            popView.modalPresentationStyle = .custom
            popView.transitioningDelegate = self
            self.present(popView, animated: true, completion: nil)
        default:
            self.dismiss(animated: true, completion: nil)
        }
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
    
    func presentRequisitsVc(product: GetProductListDatum){
        showActivity()
        var body = ["cardId": product.cardID] as [String : AnyObject]
        
        if product.productType == "ACCOUNT" {
            body = ["accountId": product.id] as [String : AnyObject]
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
                    var mockItem = MockItems.returnsRequisits()
                    mockItem[0].description = model.data?.payeeName
                    mockItem[1].description = product.accountNumber
                    mockItem[2].description = model.data?.bic
                    mockItem[3].description = model.data?.corrAccount
                    mockItem[4].description = model.data?.inn
                    mockItem[5].description = model.data?.kpp
                    mockItem[6].description = model.data?.holderName
                    mockItem[7].description = model.data?.maskCardNumber
                    mockItem[8].description = model.data?.expireDate
                    viewController.addCloseButton()
                    viewController.addCloseButton_3()
                    viewController.mockItem = mockItem
                    viewController.product = product
                    viewController.model = model.data
                    navController.modalPresentationStyle = .fullScreen
                    navController.transitioningDelegate = self
                    self.present(navController, animated: true, completion: nil)
                }
                
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")

            }
        }

    }
    
}

extension AccountDetailsViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}














class ClosureSleeve {
    let closure: () -> ()

    init(attachTo: AnyObject, closure: @escaping () -> ()) {
        self.closure = closure
        objc_setAssociatedObject(attachTo, "[\(arc4random())]", self, .OBJC_ASSOCIATION_RETAIN)
    }

    @objc func invoke() {
        closure()
    }
}

extension UIControl {
    func addAction(for controlEvents: UIControl.Event, action: @escaping () -> ()) {
        let sleeve = ClosureSleeve(attachTo: self, closure: action)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
    }
}
