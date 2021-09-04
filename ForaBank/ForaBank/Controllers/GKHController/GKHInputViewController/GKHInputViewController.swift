//
//  GKHDetailViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 18.08.2021.
//

import UIKit
import RealmSwift

class GKHInputViewController: UIViewController {
    
    var bodyValue = [String : String]()
    var bodyArray = [[String : String]]()
    var operatorData: GKHOperatorsModel?
    var valueToPass : String?
    var puref = ""
    var cardNumber = ""
    
    var qrData = [String: String]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomInputView: BottomInputView!
    @IBOutlet weak var goButton: UIButton!
    
    /// MARK - REALM
    lazy var realm = try? Realm()
    var cardList: Results<UserAllCardsModel>? = nil
    
    
    let footerView = GKHInputFooterView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardList = realm?.objects(UserAllCardsModel.self)
        
        if !qrData.isEmpty {
            let a = qrData.filter { $0.key == "Sum"}
            bottomInputView.tempTextFieldValue = a.first?.value ?? ""
        }
        
        
        bottomInputView?.isHidden = true

        setupNavBar()
//        goButton.isEnabled = false
//        goButton.backgroundColor = .lightGray
        goButton.add_CornerRadius(5)
        puref = operatorData?.puref ?? ""
        tableView.register(UINib(nibName: "GKHInputCell", bundle: nil), forCellReuseIdentifier: GKHInputCell.reuseId)
        tableView.register(GKHInputFooterView.self, forHeaderFooterViewReuseIdentifier: "sectionFooter")
        
        // Изменения символа валюты
        bottomInputView.currencySymbol = "₽"
        /// Загружаем карты
        AddAllUserCardtList.add()
        // Замыкание которое срабатывает по нажатию на кнопку продолжить
        // amount значение выдает отформатированное значение для передачи в запрос
        bottomInputView.didDoneButtonTapped = { amount in
            
            self.showActivity()
            
            // Запрос на платеж в ЖКХ : нужно добавить параметры в рапрос
            self.paymentGKH(amount: amount) { model, error in
                
                self.dismissActivity()
                
                if error != nil {
                    print("DEBUG: Error: endContactPayment ", error ?? "")
                    self.showAlert(with: "Ошибка", and: error!)
                } else {
                    guard let model = model else { return }
                    // Переход на экран подтверждения
                    self.goToConfurmVC(with: model)
                }
                // Функция настройки выбранной карты и список карт
                self.setupCardList { error in
                    guard let error = error else { return }
                    self.showAlert(with: "Ошибка", and: error)
                }
                
            }
        }
        
        setupCardList { error in
            guard let error = error else { return }
            self.showAlert(with: "Ошибка", and: error)
        }

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
 //       guard footerView = tableView.tableFooterView else {return}
        let size = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height
            tableView.tableFooterView = footerView
            tableView.layoutIfNeeded()
        }
    }
    
    @IBAction func goButton(_ sender: UIButton) {
        goButton.isHidden = true
        bottomInputView.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        qrData.removeAll()
    }
    
    
}

extension GKHInputViewController {
    
    //MARK: - Helpers
    func goToConfurmVC(with model: ConfirmViewControllerModel) {
        DispatchQueue.main.async {
            let vc = ContactConfurmViewController()
            vc.title = "Подтвердите реквизиты"
            vc.confurmVCModel = model
            vc.countryField.isHidden = true
            vc.phoneField.isHidden = true
            vc.nameField.isHidden = true
            vc.bankField.isHidden = true
            vc.numberTransctionField.isHidden = true
            vc.cardToField.isHidden = true
            vc.summTransctionField.isHidden = false
            vc.taxTransctionField.isHidden = false
            vc.currTransctionField.isHidden = true
            vc.currancyTransctionField.isHidden = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setupCardList(completion: @escaping ( _ error: String?) ->() ) {
        
//        self.cardList?.forEach{ card in
//            if (card.allowDebit && card.productType == "CARD") {
//                var filterProduct: [UserAllCardsModel] = []
//                filterProduct.append(card)
//                self.footerView.cardListView.cardList = filterProduct
//                self.footerView.cardFromField.cardModel = filterProduct.first
//                self.cardNumber  = filterProduct.first?.accountNumber ?? ""
//            }
//        }
        
        
        
        
        
        getCardList { [weak self] data ,error in
            DispatchQueue.main.async {
                
                if error != nil {
                    self?.showAlert(with: "Ошибка", and: error!)
                }
                guard let data = data else { return }
                var filterProduct: [GetProductListDatum] = []
                data.forEach { product in
                    if (product.productType == "CARD" || product.productType == "ACCOUNT") && product.currency == "RUB" {
                        if product.allowDebit == true {
                        filterProduct.append(product)
                        }
                    }
                }
                
                self?.footerView.cardListView.cardList = filterProduct
                self?.footerView.cardFromField.cardModel = filterProduct.first
                self?.cardNumber  = filterProduct.first?.number ?? ""
//                                self?.cardListView.cardList = filterProduct
//
//                                if filterProduct.count > 0 {
//                                    self?.cardFromField.cardModel = filterProduct.first
//                                    guard let cardNumber  = filterProduct.first?.number else { return }
//                                    self?.selectedCardNumber = cardNumber
//                                    self?.cardIsSelect = true
//                                    completion(nil)
//                                }
            }
        }
    }
    
    
    //MARK: - API
    func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?, _ error: String?)->()) {
        let param = ["isCard": "true", "isAccount": "true", "isDeposit": "false", "isLoan": "false"]

        NetworkManager<GetProductListDecodableModel>.addRequest(.getProductListByFilter, param, [:]) { model, error in
            if error != nil {
                completion(nil, error)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                guard let cardList = model.data else { return }
                print(cardList)
                completion(cardList, nil)
            } else {
                guard let error = model.errorMessage else { return }
                completion(nil, error)
            }
        }
    }
    func paymentGKH(amount: String ,completion: @escaping (_ model: ConfirmViewControllerModel? ,_ error: String?) -> ()) {
    
        
        let body = [ "check" : false,
                     "amount" : amount,
                     "currencyAmount" : "RUB",
                     "payer" : [ "cardId" : nil,
                                 "cardNumber" : self.cardNumber,
                                 "accountId" : nil ],
                     "puref" : puref,
                     "additional" : bodyArray] as [String: AnyObject]
        print("DEBUG: GKHInputView" , body)
        
        NetworkManager<CreateDirectTransferDecodableModel>.addRequest(.createServiceTransfer, [:], body) { respModel, error in
            if error != nil {
                print("DEBUG: Error: ContaktPaymentBegin ", error ?? "")
                completion(nil, error!)
            }
            guard let respModel = respModel else { return }
            if respModel.statusCode == 0 {
                guard let data = respModel.data else { return }
                var model = ConfirmViewControllerModel(type: .gkh)
                
                //                                    model.cardFrom = self.cardFromField.cardModel
                let r = Double(data.debitAmount ?? 0)
                
                model.summTransction = r.currencyFormatter(symbol: "RUB")
                
                let c = Double(data.fee ?? 0)
                model.taxTransction = c.currencyFormatter(symbol: "RUB")
                
                completion(model, nil)
                
            } else {
                print("DEBUG: Error: ContaktPaymentBegin ", respModel.errorMessage ?? "")
                completion(nil, respModel.errorMessage)
            }
        }
    }
    
}
