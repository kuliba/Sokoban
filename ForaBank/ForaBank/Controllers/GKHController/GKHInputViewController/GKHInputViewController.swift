//
//  GKHDetailViewController.swift
//  ForaBank
//
//  Created by Константин Савялов on 18.08.2021.
//

import UIKit

class GKHInputViewController: UIViewController {
    
    var operatorData: GKHOperatorsModel?
    var valueToPass : String?
    var puref = ""
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomInputView: BottomInputView!
    @IBOutlet weak var goButton: UIButton!
    
    let footerView = GKHFooterView(text: "This is the text to be displayed in the footer view. Lets just think this contains some sort of disclaimer or maybe information that needs to be always shown below the content of the table. We don't know the length of this, especially if we want to support different languages, so we rely Auto Layout to calculate the correct size.")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomInputView.isHidden = true
        setupNavBar()
//        goButton.isEnabled = false
        //        goButton.backgroundColor = .lightGray
        goButton.add_CornerRadius(5)
        puref = operatorData?.puref ?? ""
        tableView.register(UINib(nibName: "GKHInputCell", bundle: nil), forCellReuseIdentifier: GKHInputCell.reuseId)
        tableView.register(UINib(nibName: "GKHCardCell", bundle: nil), forCellReuseIdentifier: GKHCardCell.reuseId)
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
        self.tableView.tableFooterView = footerView
        
        
        setupCardList { error in
            guard let error = error else { return }
            self.showAlert(with: "Ошибка", and: error)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let footerView = self.tableView.tableFooterView else {
            return
        }
        
        let width = self.tableView.bounds.size.width
        let size = footerView.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height))
        
        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height
            self.tableView.tableFooterView = footerView
        }
    }
    
    @IBAction func goButton(_ sender: UIButton) {
        goButton.isHidden = true
        bottomInputView.isHidden = false
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
        getCardList { [weak self] data ,error in
            DispatchQueue.main.async {
                
                if error != nil {
                    self?.showAlert(with: "Ошибка", and: error!)
                }
                guard let data = data else { return }
                var filterProduct: [GetProductListDatum] = []
                data.forEach { product in
                    if (product.productType == "CARD" || product.productType == "ACCOUNT") && product.currency == "RUB" {
                        filterProduct.append(product)
                    }
                }
                
//                let cell = self?.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! GKHCardCell
                
                self?.footerView.cardListView.cardList = filterProduct
                self?.footerView.cardFromField.cardModel = filterProduct.first
                
                //                self?.cardListView.cardList = filterProduct
                
                //                if filterProduct.count > 0 {
                //                    self?.cardFromField.cardModel = filterProduct.first
                //                    guard let cardNumber  = filterProduct.first?.number else { return }
                //                    self?.selectedCardNumber = cardNumber
                //                    self?.cardIsSelect = true
                //                    completion(nil)
                //                }
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
        
        let a = puref
        print(a)
        let body = [ "check" : false,
                     "amount" : amount,
                     "currencyAmount" : "RUB",
                     "payer" : [ "cardId" : nil,
                                 "cardNumber" : 4656260142582070,
                                 "accountId" : nil ],
                     "puref" : puref,
                     "additional" : [
                        [ "fieldid": 1,
                          "fieldname": "account",
                          "fieldvalue": "766440148001" ],
                        [ "fieldid": 2,
                          "fieldname": "fine",
                          "fieldvalue": "0" ],
                        [ "fieldid": 3,
                          "fieldname": "counter",
                          "fieldvalue": "120001" ],
                        [ "fieldid": 4,
                          "fieldname": "counterDay",
                          "fieldvalue": "120002" ],
                        [ "fieldid": 5,
                          "fieldname": "counterNight",
                          "fieldvalue": "120003" ]
                     ] ] as [String: AnyObject]
        print("DEBUG: GKHInputView" ,body)
        
        NetworkManager<CreateServiceTransferDecodableModel>.addRequest(.createServiceTransfer, [:], body) { respModel, error in
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
