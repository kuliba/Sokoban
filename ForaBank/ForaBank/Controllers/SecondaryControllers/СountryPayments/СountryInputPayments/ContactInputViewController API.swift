//
//  ContactInputViewController API.swift
//  ForaBank
//
//  Created by Mikhail on 23.06.2021.
//

import UIKit

extension ContactInputViewController {
    
    func startPayment(with card: String, type: PaymentType,
                      completion: @escaping (_ error: String?)->()) {
        
        let puref = type.puref
        
        let body = ["accountID": nil,
                    "cardID": nil,
                    "cardNumber": card,
                    "provider": nil,
                    "puref": puref] as [String: AnyObject]
        
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
//                        completion(nil)
                        let amount = self.summTransctionField.textField.text ?? ""
                        let doubelAmount = amount.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
                        
                        switch self.typeOfPay {
                        case .migAIbank:
                            let phone = self.phoneField.textField.unmaskedText ?? ""
                            
                            self.endMigPayment(phone: phone, amount: doubelAmount) { error in
                                self.dismissActivity()
                                if error != nil {
                                    print("DEBUG: Error: endMigPayment ", error ?? "")
                                    completion(error!)
                                }
                            }
                        default:
                            let surname = self.surnameField.textField.text ?? ""
                            let name = self.nameField.textField.text ?? ""
                            let secondName = self.secondNameField.textField.text ?? ""
                            
                            self.endContactPayment(surname: surname, name: name, secondName: secondName, amount: doubelAmount) { error in
                                self.dismissActivity()
                                if error != nil {
                                    print("DEBUG: Error: endContactPayment ", error ?? "")
                                    completion(error!)
                                }
                            }
                        }
                        
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
                let model = ConfirmViewControllerModel(
                    country: country,
                    model: model)
                self.goToConfurmVC(with: model)
                
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
              "fieldvalue": "BTOC" ]
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
                        let model = ConfirmViewControllerModel(
                            country: country,
                            model: model,
                            fullName: fullName)
                                                
                        self.goToConfurmVC(with: model)
                        
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
