//
//  ContactInputViewController API.swift
//  ForaBank
//
//  Created by Mikhail on 23.06.2021.
//

import UIKit

extension ContactInputViewController {
    //MARK: - API
    
    func getBankList(completion: @escaping (_ banksList: [BanksList]?, _ error: String?)->()) {
        
        NetworkHelper.request(.getBanks) { banksList , error in
            if error != nil {
                completion(nil, error)
            }
            guard let banksList = banksList as? [BanksList] else { return }
            completion(banksList, nil)
            print("DEBUG: Load Banks List... Count is: ", banksList.count)
        }
    }
    
    func contaktPayment(with card: String, surname: String, name: String, secondName: String, amount: String, completion: @escaping (_ model: ConfirmViewControllerModel? ,_ error: String?) -> ()) {
        
        guard let countryCode = country?.contactCode else { return }
        
        let body = ["check" : false,
                    "amount" : amount,
                    "currencyAmount" : "RUB",
                    "payer" : [
                        "cardId" : nil,
                        "cardNumber" : card,
                        "accountId" : nil
                    ],
                    "puref" : puref,
                    "additional" : [
                        [ "fieldid": 1,
                          "fieldname": "bName",
                          "fieldvalue": surname
                        ],
                        [  "fieldid": 2,
                           "fieldname": "bLastName",
                           "fieldvalue": name
                        ],
                        [  "fieldid": 3,
                           "fieldname": "bSurName",
                           "fieldvalue": secondName
                        ],
                        [ "fieldid": 4,
                          "fieldname": "trnPickupPoint",
                          "fieldvalue": countryCode
                        ],
                        [  "fieldid": 5,
                           "fieldname": "CURR",
                           "fieldvalue": self.currency
                        ]
                    ] ] as [String: AnyObject]
        
        print("DEBUG: ContaktPaymentBegin with body:",body)
        
        NetworkManager<CreateContactAddresslessTransferDecodableModel>.addRequest(.createContactAddresslessTransfer, [:], body, completion: { respModel, error in
            if error != nil {
                print("DEBUG: Error: ContaktPaymentBegin ", error ?? "")
                completion(nil, error!)
            }
            guard let respModel = respModel else { return }
            if respModel.statusCode == 0 {
                guard let country = self.country else { return }
                guard let data = respModel.data else { return }
                print(data)
                var model = ConfirmViewControllerModel(type: .contact)
                model.country = country
                model.cardFrom = self.cardFromField.cardModel
                model.summTransction = data.debitAmount?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
                model.taxTransction = data.fee?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
                model.summInCurrency = data.amount?.currencyFormatter(symbol: data.currencyPayee ?? "RUB") ?? ""
                model.fullName = data.payeeName ?? "Получатель не оперделен"
                model.currancyTransction = "Наличные"
                model.statusIsSuccses = true
                respModel.data?.additionalList?.forEach({ additional in
                    if additional.fieldName == "trnReference" {
                        model.numberTransction = additional.fieldValue ?? ""
                    }
                })
                completion(model, nil)
        
            } else {
                print("DEBUG: Error: ContaktPaymentBegin ", respModel.errorMessage ?? "")
                completion(nil, respModel.errorMessage)
            }
        })
    }
    
    func migPayment(with card: String, phone: String, amount: String, completion: @escaping (_ model: ConfirmViewControllerModel? ,_ error: String?) -> ()) {
        
        let body = ["check" : false,
                    "amount" : amount,
                    "currencyAmount" : "RUB",
                    "payer" : [
                        "cardId" : nil,
                        "cardNumber" : card,
                        "accountId" : nil
                    ],
                    "puref" : puref,
                    "additional" : [
                        [
                            "fieldid": 1,
                            "fieldname": "RECP",
                            "fieldvalue": phone
                        ]
                    ] ] as [String: AnyObject]
        
        print("DEBUG: ContaktPaymentBegin with body:",body)
        
        NetworkManager<CreateDirectTransferDecodableModel>.addRequest(.createDirectTransfer, [:], body, completion: { respModel, error in
            if error != nil {
                print("DEBUG: Error: ContaktPaymentBegin ", error ?? "")
                completion(nil, error!)
            }
            guard let respModel = respModel else { return }
            if respModel.statusCode == 0 {
                guard let country = self.country else { return }
                guard let data = respModel.data else { return }
                var model = ConfirmViewControllerModel(type: .mig)
                model.country = country
                model.cardFrom = self.cardFromField.cardModel
                model.summTransction = data.debitAmount?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
                model.summInCurrency = data.creditAmount?.currencyFormatter(symbol: data.currencyPayee ?? "RUB") ?? ""
                
                model.taxTransction = data.fee?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
                model.fullName = data.payeeName ?? "Получатель не оперделен"
                model.statusIsSuccses = true
                model.bank = self.selectedBank
                respModel.data?.additionalList?.forEach({ additional in
                    if additional.fieldName == "RECP" {
                        model.phone = additional.fieldValue ?? ""
                    }
                })
                completion(model, nil)
        
            } else {
                print("DEBUG: Error: ContaktPaymentBegin ", respModel.errorMessage ?? "")
                completion(nil, respModel.errorMessage)
            }
        })
    }
    
    
}
