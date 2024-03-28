//
//  PayViewController.swift
//  ForaBank
//
//  Created by Дмитрий on 17.09.2021.
//

import UIKit

class PayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let getUImage: (Md5hash) -> UIImage?
    var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    let card: UserAllCardsModel?
    
    init(card: UserAllCardsModel?, getUImage: @escaping (Md5hash) -> UIImage?) {
        self.card = card
        self.getUImage = getUImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
        tableView.register(UINib(nibName: "PayTableViewCell", bundle: nil), forCellReuseIdentifier: "PayTableViewCell")
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView.rowHeight = 56

    }
    
    func setupUI(){
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "Пополнить"
        navigationController?.navigationBar.barTintColor = .white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        self.navigationItem.leftItemsSupplementBackButton = true
        let close = UIBarButtonItem(title: "Закрыть", style: .plain, target: self, action: #selector(backButton))
        close.tintColor = .black

        self.navigationItem.rightBarButtonItem = close
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .highlighted)
    }

    @objc func backButton(){
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PayTableViewCell", for: indexPath) as? PayTableViewCell else { return UITableViewCell() }
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = "С моего счета в другом банке"
            cell.imageButton.image = UIImage(named: "sbpButton2")

        case 1:
            cell.titleLabel.text = "Со своего счета"
            cell.imageButton.image = UIImage(named: "myAccountButton")
        case 2:
            cell.titleLabel.text = "С карты другого банка"
            cell.imageButton.image = UIImage(named: "otherAccountButton")
            cell.titleLabel.alpha = 0.4
            cell.imageButton.alpha = 0.4
            cell.alpha = 0.4
            cell.isUserInteractionEnabled = false
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
            if card?.currency == "RUB" {
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
                                self?.navigationController?.pushViewController(vc, animated: true)
                            } else {
                                let viewController = MeToMeViewController(cardFrom: self?.card, getUImage: self?.getUImage ?? { _ in nil })
                                
                                viewController.meToMeContract = contractList
                                viewController.addCloseButton()
                                let navController = UINavigationController(rootViewController: viewController)
                                navController.modalPresentationStyle = .fullScreen
                                self?.present(navController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            } else {
                self.showAlert(with: "Ошибка", and: "Нельзя пополнить валютный счет")
            }
        case 1:
            let model = ConfirmViewControllerModel(type: .card2card, status: .succses)
            var popView = CustomPopUpWithRateView()
            
            if let card = card {
                popView = CustomPopUpWithRateView(cardTo: card)
            }
            popView.viewModel = model
            popView.modalPresentationStyle = .custom
            popView.transitioningDelegate = self
            self.present(popView, animated: true, completion: nil)
        case 3:
            let popView = MemeDetailVC()
            popView.titleLabel.text = "На другую карту"
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
                completion(nil, error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                completion(model.data, nil)
            } else {

                completion(nil, model.errorMessage)
            }
        }
    }
}

extension PayViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        presenter.height = 490
        return presenter
    }
}


