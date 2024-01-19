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
        
        guard let banks = model.dictionaryBankListLegacy else {
            return completion(nil, "Не удалось загрузить список банков")
        }
            
        completion(banks, nil)
    }
    
    //90-535-8663013
    func phoneNumberFormate( str : NSMutableString)->String{
            str.insert("-", at: 2)
            str.insert("-", at: 6)
            return str as String
        }
    
    func contaktPayment(with card: UserAllCardsModel, surname: String, name: String, secondName: String, phone: String?, amount: Double, completion: @escaping (_ model: ConfirmViewControllerModel? ,_ error: String?) -> ()) {
        
        guard let countryCode = country?.contactCode else { return }
        guard let currencyAmount = card.currency else { return }
        
        var body = ["check" : false,
                    "amount" : amount,
                    "currencyAmount" : currencyAmount,
                    "payer" : [
                        "cardId" : nil,
                        "cardNumber" : nil,
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
                           "fieldvalue": self.currency == "RUB" ? "RUR" : self.currency
                        ]
                    ] ] as [String: AnyObject]
        
        if country?.code == "TR" {
            
            var phone = phone ?? ""
        
            switch phone.prefix(4) {
            case "+90-":
                phone = phone.applyPatternOnNumbers(pattern: "##-###-#######", replacmentCharacter: "#")
            case "+374":
                phone = phone.applyPatternOnNumbers(pattern: "###-##-######", replacmentCharacter: "#")
            default: break
            }
            
            switch phone.prefix(3) {
            case "+90":
                phone = phone.applyPatternOnNumbers(pattern: "##-###-#######", replacmentCharacter: "#")
            case "+79":
                phone = phone.applyPatternOnNumbers(pattern: "#-###-#######", replacmentCharacter: "#")
            case "374":
                phone = phone.applyPatternOnNumbers(pattern: "###-##-######", replacmentCharacter: "#")
            default: break
            }
            
            switch phone.prefix(2) {
            case "79":
                phone = phone.applyPatternOnNumbers(pattern: "#-###-#######", replacmentCharacter: "#")
            case "+7":
                phone = phone.applyPatternOnNumbers(pattern: "#-###-#######", replacmentCharacter: "#")
            case "90":
                phone = phone.applyPatternOnNumbers(pattern: "##-###-#######", replacmentCharacter: "#")
            
            default: break
            }
            
            switch phone.prefix(1) {
            case "8":
                phone = phone.applyPatternOnNumbers(pattern: "#-###-#######", replacmentCharacter: "#")
                
            default: break
            }
            
            let field = ["fieldid": 6,
                         "fieldname": "bPhone",
                         "fieldvalue": phone] as [String: AnyObject]
            
            var anyBody = body["additional"] as? [[String: AnyObject]]
            anyBody?.append(field)
            body["additional"] = anyBody as AnyObject
        }
        
        if card.productType == "CARD" {
            body["payer"] = ["cardId": card.cardID,
                             "cardNumber" : nil,
                             "accountId" : nil] as AnyObject
        } else if card.productType == "ACCOUNT" {
            body["payer"] = ["cardId": nil,
                             "cardNumber" : nil,
                             "accountId" : card.id] as AnyObject
        } else if card.productType == "DEPOSIT" {
            body["payer"] = ["cardId": nil,
                             "cardNumber" : nil,
                             "accountId" : card.accountID] as AnyObject
        }
        
        NetworkManager<CreateContactAddresslessTransferDecodableModel>.addRequest(.createContactAddresslessTransfer, [:], body, completion: { respModel, error in
            if error != nil {
                completion(nil, error!)
            }
            let phone = self.phoneField.textField.phoneNumber?.numberString ?? ""
            guard let respModel = respModel else { return }
            if respModel.statusCode == 0 {
                guard let country = self.country else { return }
                guard let data = respModel.data else { return }
        
                var status = ConfirmViewControllerModel.StatusOperation.succses
                
                switch respModel.data?.documentStatus{
                case .some("COMPLETE"):
                    status = .succses
                    
                case .some("IN_PROGRESS"):
                    status = .inProgress
                    
                case .some("REJECTED"):
                    status = .error
                    
                case .some("SUSPEND"):
                    status = .antifraudCanceled
                                        
                case .some(_):
                    status = .error

                case .none:
                    status = .error
                }
                
                let model = ConfirmViewControllerModel(
                    type: .contact,
                    status: status
                )
                
                model.country = country
                model.cardFrom = self.cardFromField.cardModel
                model.cardFromRealm = self.cardFromField.model
                model.summTransction = data.debitAmount?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
                model.taxTransction = data.fee?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
                model.summInCurrency = data.amount?.currencyFormatter(symbol: data.currencyPayee ?? "RUB") ?? ""
                model.fullName = data.payeeName ?? "Получатель не определен"
                model.surname = surname
                model.name = name
                model.secondName = secondName
                model.currancyTransction = "Наличные"
                model.status = .succses
                model.phone = phone
                // TODO: add paymentSystem in model
                model.paymentSystem = self.paymentSystem
                model.template = self.paymentTemplate
                respModel.data?.additionalList?.forEach({ additional in
                    if additional.fieldName == "trnReference" {
                        model.numberTransction = additional.fieldValue ?? ""
                    }
                })
                completion(model, nil)
        
            } else {
                completion(nil, respModel.errorMessage)
            }
        })
    }
    
    func migPayment(with card: UserAllCardsModel, phone: String?, amount: Double, completion: @escaping (_ model: ConfirmViewControllerModel? ,_ error: String?) -> ()) {
        guard let phone = phone?.replacingOccurrences(of: "+", with: "") else {
            return
        }

        var body = ["check" : false,
                    "amount" : amount,
                    "currencyAmount" : self.currency,
                    "payer" : [
                        "cardId" : nil,
                        "cardNumber" : nil,
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
        
        if card.productType == "CARD" {
            body["payer"] = ["cardId": card.cardID,
                             "cardNumber" : nil,
                             "accountId" : nil] as AnyObject
        } else if card.productType == "ACCOUNT" {
            body["payer"] = ["cardId": nil,
                             "cardNumber" : nil,
                             "accountId" : card.id] as AnyObject
        } else if card.productType == "DEPOSIT" {
            body["payer"] = ["cardId": nil,
                             "cardNumber" : nil,
                             "accountId" : card.accountID] as AnyObject
        }
        
        NetworkManager<CreateDirectTransferDecodableModel>.addRequest(.createDirectTransfer, [:], body, completion: { respModel, error in
            if error != nil {
                completion(nil, error!)
            }
            guard let respModel = respModel else { return }
            if respModel.statusCode == 0 {
                guard let country = self.country else { return }
                guard let data = respModel.data else { return }
                let model = ConfirmViewControllerModel(type: .mig, status: .succses)
                model.country = country
                model.cardFrom = self.cardFromField.cardModel
                model.summTransction = data.debitAmount?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
                model.summInCurrency = data.creditAmount?.currencyFormatter(symbol: data.currencyPayee ?? "RUB") ?? ""
                
                model.taxTransction = data.fee?.currencyFormatter(symbol: data.currencyPayer ?? "RUB") ?? ""
                model.fullName = data.payeeName ?? "Получатель не определен"
                model.status = .succses
                model.bank = self.selectedBank
                model.paymentSystem = self.paymentSystem
                model.template = self.paymentTemplate
                respModel.data?.additionalList?.forEach({ additional in
                    if additional.fieldName == "RECP" {
                        model.phone = additional.fieldValue ?? ""
                    }
                })
                completion(model, nil)
        
            } else {
                completion(nil, respModel.errorMessage)
            }
        })
    }
    
    
}


extension String {

    func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: self)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
}
