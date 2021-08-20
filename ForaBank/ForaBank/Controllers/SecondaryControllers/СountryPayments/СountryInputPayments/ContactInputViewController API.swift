//
//  ContactInputViewController API.swift
//  ForaBank
//
//  Created by Mikhail on 23.06.2021.
//

import UIKit

extension ContactInputViewController {
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
    
    func startPayment(with card: String, completion: @escaping (_ error: String?)->()) {
//        let amount = amount

        
        let puref = self.puref
        
        let body = ["accountID": nil,
                    "cardID": nil,
                    "cardNumber": card,
                    "provider": nil,
                    "puref": puref] as [String: AnyObject]
        print("DEBUG: Error: anywayPaymentBegin with body:",body)
        NetworkManager<AnywayPaymentBeginDecodebleModel>.addRequest(.anywayPaymentBegin, [:], body, completion: { model, error in
            if error != nil {
                print("DEBUG: Error: anywayPaymentBegin ", error ?? "")
                completion(error!)
            }
            guard let model = model else { return }
            if model.statusCode == 0 {
                
                NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], [:]) { model, error in
                    if error != nil {
                        print("DEBUG: Error: anywayPayment1 ", error ?? "")
                        completion(error!)
                    }
                    guard let model = model else { return }
                    if model.statusCode == 0 {
                        print("DEBUG: Success ")
                        
                        guard let listInput = model.data?.listInputs else { return }
                        
                        listInput.forEach { listInput in
                            if listInput.id == "trnPickupPoint" {
                                let pickupPoint = self.setupContactCountryCode(codeList: listInput.dataType ?? "")
                                self.trnPickupPoint = pickupPoint
                                print("DEBUG: trnPickupPoint", pickupPoint)
                            } else if listInput.id == "oferta" {
                                print("DEBUG: Oferta")
                            }
                        }
                        
                        completion(nil)
                        
                        
                    } else {
                        print("DEBUG: Error: anywayPayment1", model.errorMessage ?? "")
                        completion(model.errorMessage)
                    }
                }
            } else {
                print("DEBUG: Error: anywayPaymentBegin ", model.errorMessage ?? "")
                completion(model.errorMessage)
            }
        })
    }
    
    func endMigPayment(phone: String, amount: String, completion: @escaping (_ error: String?)->()) {
        showActivity()
//        37477404102
        let dataName = ["additional": [
            [ "fieldid": 1,
              "fieldname": "RECP",
              "fieldvalue": phone ],
            [ "fieldid": 1,
              "fieldname": "SumSTrs",
              "fieldvalue": amount ]
        ]] as [String: AnyObject]
        
        NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], dataName) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
                completion(error!)
            }
//            print("DEBUG: amount ", amount)
            guard let model = model else { return }
            if model.statusCode == 0 {
                print("DEBUG: Success send Phone")
                self.dismissActivity()
                guard let country = self.country else { return }
                var model = ConfirmViewControllerModel(
                    country: country,
                    model: model)
                model?.type = .mig
                model?.paymentSystem = self.paymentSystem
                model?.bank = self.selectedBank
                self.goToConfurmVC(with: model!)
                
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                completion(model.errorMessage)
            }
        }
        
    }
    
    func endContactPayment(surname: String, name: String, secondName: String, amount: String, completion: @escaping (_ error: String?)->()) {
        showActivity()
        let dataName = [ "additional": [
            ["fieldid": 1,
             "fieldname": "bName",
             "fieldvalue": surname ],
            ["fieldid": 2,
             "fieldname": "bLastName",
             "fieldvalue": name ],
            [ "fieldid": 3,
              "fieldname": "bSurName",
              "fieldvalue": secondName ],
            [ "fieldid": 4,
              "fieldname": "trnPickupPoint",
              "fieldvalue": self.trnPickupPoint ]
        ] ] as [String: AnyObject]
//        print("DEBUG: ", dataName)
        NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], dataName) { model, error in
            if error != nil {
                print("DEBUG: Error: ", error ?? "")
                completion(error!)
            }
            
            print("DEBUG: amount", amount)
            guard let model = model else { return }
            if model.statusCode == 0 {
                print("DEBUG: Success send Name")
                let dataAmount = [ "additional": [
                    [ "fieldid": 1,
                      "fieldname": "A",
                      "fieldvalue": amount ],
                    [ "fieldid": 2,
                      "fieldname": "CURR",
                      "fieldvalue": "RUR" ]
                ] ] as [String: AnyObject]
                
                NetworkManager<AnywayPaymentDecodableModel>.addRequest(.anywayPayment, [:], dataAmount) { model, error in
                    if error != nil {
                        print("DEBUG: Error: ", error ?? "")
                    }
                    guard let model = model else { return }
                    if model.statusCode == 0 {
                        print("DEBUG: Success send sms code")
                        self.dismissActivity()
                        
                        guard let country = self.country else { return }
                        let fullName = surname + " " + name + " " + secondName
                        var model = ConfirmViewControllerModel(
                            country: country,
                            model: model,
                            fullName: fullName)
                        model?.paymentSystem = self.paymentSystem
                        self.goToConfurmVC(with: model!)
                        
                    } else {
                        print("DEBUG: Error: ", model.errorMessage ?? "")
                        completion(model.errorMessage)
                    }
                }
            } else {
                print("DEBUG: Error: ", model.errorMessage ?? "")
                completion(model.errorMessage)
            }
        }
        
        
    }
    
}
