//
//  AccountDetailsViewController.swift
//  ForaBank
//
//  Created by Mikhail on 08.11.2021.
//

import UIKit

class AccountDetailsViewController: UIViewController {

    let cellReuse = "PayTableViewCell"
    
    var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    
    var product: GetProductListDatum?
    
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
    
    
    func presentRequisitsVc(product: GetProductListDatum?){
        showActivity()
        var body = ["cardId": product?.cardID] as [String : AnyObject]
        
        if product?.productType == "ACCOUNT" {
            body = ["accountId": product?.id] as [String : AnyObject]
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
                    mockItem[1].description = product?.accountNumber
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
                    
                    self.dismiss(animated: true) {
                        let topvc = UIApplication.topViewController()
                        topvc?.present(navController, animated: true)
                    }
//                    self.present(navController, animated: true, completion: nil)
                }
                
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                self.showAlert(with: "Ошибка", and: model.errorMessage ?? "")

            }
        }

    }
    
}

extension AccountDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuse, for: indexPath) as? PayTableViewCell else { return UITableViewCell() }
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = "Реквизиты счета карты"
            cell.imageButton.image = UIImage(named: "file-text")?.withRenderingMode(.alwaysTemplate)
        case 1:
            cell.titleLabel.text = "Выписка по счету"
            cell.imageButton.image = UIImage(named: "accaunt")?.withRenderingMode(.alwaysTemplate)
        default:
            cell.titleLabel.text = "default"
            cell.imageButton.image = UIImage(named: "otherAccountButton")
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
#if DEBUG
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
            
#endif
        default:
            self.dismiss(animated: true, completion: nil)
        }
    }
}

    
extension AccountDetailsViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        presenter.height = 490
        return presenter
    }
}

