//
//  C2BRequstsApi.swift.swift
//  ForaBank
//
//  Created by Роман Воробьев on 16.03.2022.
//

import Foundation

class C2BApiRequests {

    static func updateContract(contractId: String?, cardModel: GetProductListDatum, isOff: Bool, completion: @escaping (_ success: Bool, _ error: String?) -> ()) {
        guard let fpcontractID = contractId else {
            return
        }

        var body = ["contractId": fpcontractID,
                    "cardId": nil,
                    "accountId": nil,
                    "flagBankDefault": "EMPTY",
                    "flagClientAgreementIn": isOff ? "YES" : "NO",
                    "flagClientAgreementOut": isOff ? "YES" : "NO"
        ] as [String: AnyObject]

        if cardModel.productType == "CARD" {
            body["cardId"] = cardModel.id as AnyObject?
        } else if cardModel.productType == "ACCOUNT" {
            body["accountId"] = cardModel.id as AnyObject?
        }

        NetworkManager<UpdateFastPaymentContractDecodableModel>.addRequest(.updateFastPaymentContract, [:], body) { model, error in
            if error != nil {
                completion(false, error)
            }
            guard let model = model else {
                return
            }
            if model.statusCode == 0 {
                completion(true, nil)
            } else {
                guard let error = model.errorMessage else {
                    return
                }
                completion(false, error)
            }
        }
    }

    static func createContract(cardModel: GetProductListDatum, completion: @escaping (_ success: Bool, _ error: String?) -> ()) {
        guard let accountId = cardModel.ownerID else {
            return
        }
        let body = ["accountId": accountId,
                    "flagBankDefault": "YES",
                    "flagClientAgreementIn": "YES",
                    "flagClientAgreementOut": "YES"
        ] as [String: AnyObject]

        NetworkManager<CreateServiceTransferDecodableModel>.addRequest(.createFastPaymentContract, [:], body) { model, error in
            if error != nil {
                completion(false, error)
            }
            guard let model = model else {
                return
            }
            if model.statusCode == 0 {
                completion(true, nil)
            } else {
                guard let error = model.errorMessage else {
                    return
                }
                completion(false, error)
            }
        }
    }

    static func getQRData(link: String, completion: @escaping (_ model: GetQRDataAnswer?, _ error: String?) -> ()) {
        let body = ["QRLink": link] as [String: AnyObject]

        NetworkManager<GetQRDataAnswer>.addRequest(.getQRData, [:], body) { model, error in
            if error != nil {
                completion(nil, error)
            }
            guard let model = model else {
                return
            }
            if model.statusCode == 0 {
                completion(model, nil)
            } else {
                guard let error = model.errorMessage else {
                    return
                }
                completion(nil, error)
            }
        }
    }

    static func getFastPaymentContractList(_ completion: @escaping (_ model: [FastPaymentContractFindListDatum]?, _ error: String?) -> Void) {
        NetworkManager<FastPaymentContractFindListDecodableModel>.addRequest(.fastPaymentContractFindList, [:], [:]) { model, error in
            if error != nil {
                completion(nil, error)
            }
            guard let model = model else {
                return
            }
            if model.statusCode == 0 {
                completion(model.data, nil)
            } else {
                completion(nil, model.errorMessage)
            }
        }
    }

    static func createC2BTransfer(body: [String: AnyObject] , completion: @escaping (_ model: CreateDirectTransferDecodableModel?, _ error: String?) -> ()) {
        NetworkManager<CreateDirectTransferDecodableModel>.addRequest(.createC2BTransfer, [:], body) { model, error in
            if error != nil {
                completion(nil, error)
            }
            guard let model = model else {
                return
            }
            if model.statusCode == 0 {
                completion(model, nil)
            } else {
                guard let error = model.errorMessage else {
                    return
                }
                completion(nil, error)
            }
        }
    }

    static func makePayment(completion: @escaping (_ model: MakeTransferDecodableModel?, _ error: String?) -> ()) {
        let code = "0"
        let body = ["verificationCode": code] as [String: AnyObject]
        NetworkManager<MakeTransferDecodableModel>.addRequest(.makeTransfer, [:], body) { response, error in
            
            if error != nil {
                completion(nil, error)
            }
            guard let model = response else {
                completion(nil, error)
                return
            }

            if model.statusCode == 0 {
                completion(model, nil)
            } else {
                completion(nil, error)
            }
        }
    }
}
