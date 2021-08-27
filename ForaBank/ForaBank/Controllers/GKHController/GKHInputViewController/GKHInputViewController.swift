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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomInputView: BottomInputView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "GKHInputCell", bundle: nil), forCellReuseIdentifier: GKHInputCell.reuseId)
        tableView.register(UINib(nibName: "GKHCardCell", bundle: nil), forCellReuseIdentifier: GKHCardCell.reuseId)
        // Изменения символа валюты
        bottomInputView.currencySymbol = "₽"
        
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
    }
    
    
}

extension GKHInputViewController {
    
    //MARK: - Helpers
    func goToConfurmVC(with model: ConfirmViewControllerModel) {
        DispatchQueue.main.async {
            let vc = ContactConfurmViewController()
            vc.title = "Подтвердите реквизиты"
            vc.confurmVCModel = model
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
                
                let cell = self?.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! GKHCardCell
                cell.cardListView.cardList = filterProduct
                cell.cardChooseView.cardModel = filterProduct.first
                
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
        
        let body = [ "check" : false,
                     "amount" : amount,
                     "currencyAmount" : "RUB",
                     "payer" : [ "cardId" : nil,
                                 "cardNumber" : 4656260142582070,
                                 "accountId" : nil ],
                     "puref" : "iFora||TNS",
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
                
                //                    model.cardFrom = self.cardFromField.cardModel
                //                    model.summTransction = data.debitAmount?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
                //                    model.summInCurrency = data.creditAmount?.currencyFormatter(symbol: data.currencyPayee ?? "RUB") ?? ""
                //
                //                    model.taxTransction = data.fee?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
                //                    model.fullName = data.payeeName ?? "Получатель не оперделен"
                //                    model.statusIsSuccses = true
                //                    model.bank = self.selectedBank
                //                    respModel.data?.additionalList?.forEach({ additional in
                //                        if additional.fieldName == "RECP" {
                //                            model.phone = additional.fieldValue ?? ""
                //                        }
                //                    })
                
                completion(model, nil)
                
            } else {
                print("DEBUG: Error: ContaktPaymentBegin ", respModel.errorMessage ?? "")
                completion(nil, respModel.errorMessage)
            }
            
            
            
        }
        
    }
}
