//
//  ExtensionGKHInputRequest.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.11.2021.
//

import UIKit

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
            vc.operatorView = self.operatorData?.logotypeList.first?.content ?? ""
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
                        if product.allowDebit == true {
                        filterProduct.append(product)
                        }
                    }
                }
                
                self?.footerView.cardListView.cardList = filterProduct
                self?.footerView.cardFromField.cardModel = filterProduct.first
                self?.cardNumber  = filterProduct.first?.number ?? ""
                self?.cardId = filterProduct.first?.id ?? 0

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
        
        NetworkManager<CreateDirectTransferDecodableModel>.addRequest(.createServiceTransfer, [:], body) { respModel, error in
            if error != nil {
                print("DEBUG: Error: ContaktPaymentBegin ", error ?? "")
                completion(nil, error!)
            }
            guard let respModel = respModel else { return }
            if respModel.statusCode == 0 {
                guard let data = respModel.data else { return }
                let model = ConfirmViewControllerModel(type: .gkh)

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
    
    //CreateServiceTransferDecodableModel
    /// Запрос по получения полей при многошаговом операторе
    final func operatorStep() {
        fieldid += 1
        let body = [ "check" : false,
                     "amount" : nil,
                     "currencyAmount" : "RUB",
                     "payer" : [ "cardId" : self.cardId,
                                 "cardNumber" : nil,
                                 "accountId" : nil ],
                     "puref" : puref,
                     "additional" : bodyArray ] as [String: AnyObject]
        NetworkManager<CreateServiceTransferDecodableModel>.addRequest(.createServiceTransfer, [:], body) { model, error in
            if error != nil {
                print(#function, "CreateServiceTransfer Error")
            }
            guard let respModel = model else { return }
            if respModel.statusCode == 0 {
                guard let data = respModel.data else { return }
                
                var additionalListDic = [String: String]()
                var parameterListForNextStepDic = [String: String]()
                data.additionalList?.forEach{ additionalList in
                    additionalListDic.updateValue(additionalList.fieldValue ?? "", forKey: additionalList.fieldTitle ?? "")
                }
                data.parameterListForNextStep?.forEach{ parameterListForNextStep in
                    parameterListForNextStepDic.updateValue(parameterListForNextStep.title ?? "", forKey: "title")
                    parameterListForNextStepDic.updateValue(parameterListForNextStep.id ?? "", forKey: "id")
                    parameterListForNextStepDic.updateValue(String(parameterListForNextStep.order ?? 0), forKey: "order")
                    parameterListForNextStepDic.updateValue(parameterListForNextStep.subTitle ?? "", forKey: "subTitle")
                    parameterListForNextStepDic.updateValue(parameterListForNextStep.viewType ?? "", forKey: "viewType")
                    parameterListForNextStepDic.updateValue(parameterListForNextStep.dataType ?? "", forKey: "dataType")
                    parameterListForNextStepDic.updateValue(parameterListForNextStep.type ?? "", forKey: "type")
                    parameterListForNextStepDic.updateValue(parameterListForNextStep.mask ?? "", forKey: "mask")
                    parameterListForNextStepDic.updateValue(parameterListForNextStep.regExp ?? "", forKey: "regExp")
                    parameterListForNextStepDic.updateValue(parameterListForNextStep.maxLength ?? "", forKey: "maxLength")
                    parameterListForNextStepDic.updateValue(parameterListForNextStep.minLength ?? "", forKey: "minLength")
                    parameterListForNextStepDic.updateValue(String(parameterListForNextStep.rawLength ?? 0), forKey: "rawLength")
                    parameterListForNextStepDic.updateValue(String(parameterListForNextStep.isRequired ?? false), forKey: "isRequired")
                }
                
                self.dataArray.removeAll()
                self.dataArray.append(additionalListDic)
                self.dataArray.append(parameterListForNextStepDic)
                
                self.finalStep = data.finalStep ?? true
                self.needSum = data.needSum ?? true
                self.tableView.reloadData()
            } else {
                print(#function, respModel.errorMessage ?? "")
            }
        }
    }
    
}
