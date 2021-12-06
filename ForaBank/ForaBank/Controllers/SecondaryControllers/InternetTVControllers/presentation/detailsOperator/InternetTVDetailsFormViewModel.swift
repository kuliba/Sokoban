//
//  InternetTVDetailsFormViewModel.swift
//  ForaBank
//
//  Created by Роман Воробьев on 04.12.2021.
//

import Foundation

class InternetTVDetailsFormViewModel {
    
    var controller: InternetTVDetailsFormController? = nil
    var firstStep = true
    var additionalElement = [String : String]()
    var additionalDic = [String : [String : String]]()
    var firstAdditional = [[String: String]]()
    var stepsPayment = [[[String: String]]]()
    
    init() {}

    func retryPayment(amount: String) {
        guard let controller = controller else {return}
        let request = getCreateRequest(amount: amount, additionalArray: firstAdditional, productType: controller.footerView.cardFromField.cardModel?.productType ?? "", id: controller.footerView.cardFromField.cardModel?.id ?? -1, puref: controller.puref)
        doCreateInternetTransfer(request: request) {  response, error in
            controller.dismissActivity()
            if error != nil {
                controller.showAlert(with: "Ошибка", and: error!)
            } else {
                if let respUnw = response {
                    if respUnw.data?.finalStep ?? false {
                        controller.doConfirmation(response: respUnw)
                    } else {
                        controller.showActivity()
                        self.continueRetry(amount: amount)
                    }
                }
            }
        }
    }

    func continueRetry(amount: String) {
        guard let controller = controller else {return}
        var additionalArray = [[String: String]]()
        additionalDic.forEach { item in
            additionalArray.append(item.value)
        }
        var request = getNextStepRequest(amount: amount, additionalArray: additionalArray)
        if stepsPayment.count > 0 {
            request = getNextStepRequest(amount: amount, additionalArray: stepsPayment.removeFirst())
        }
        doNextStepServiceTransfer(request: request) { response, error in
            guard let controller = self.controller else {return}
            controller.dismissActivity()
            controller.animationShow(controller.goButton)
            if error != nil {
                controller.showAlert(with: "Ошибка", and: error!)
            } else {
                if let respUnw = response {
                    if respUnw.data?.finalStep ?? false {
                        controller.doConfirmation(response: respUnw)
                    } else {
                        self.continueRetry(amount: amount)
                    }
                }
            }
        }
    }

    func requestCreateInternetTransfer(amount: String) {
        guard let controller = controller else {return}

        controller.showActivity()
        var additionalArray = [[String: String]]()
        additionalDic.forEach { item in
            additionalArray.append(item.value)
        }
        firstAdditional = additionalArray
        let request = getCreateRequest(amount: amount, additionalArray: additionalArray,productType: controller.footerView.cardFromField.cardModel?.productType ?? "", id: controller.footerView.cardFromField.cardModel?.id ?? -1, puref: controller.puref)

        doCreateInternetTransfer(request: request) { response, error in
            guard let controller = self.controller else {return}
            controller.dismissActivity()
            controller.animationShow(controller.goButton)
            if error != nil {
                controller.showAlert(with: "Ошибка", and: error!)
            } else {
                if InternetTVApiRequests.isSingleService {
                    controller.doConfirmation(response: response)
                } else {
                    if let respUnw = response {
                        if respUnw.data?.needSum ?? false {
                            controller.showFinalStep()
                        } else {
                            controller.setupNextStep(respUnw)
                        }
                    }
                }
            }
            controller.setupCardList { error in
                guard let error = error else { return }
                controller.showAlert(with: "Ошибка", and: error)
            }
        }
    }

    func requestNextCreateInternetTransfer(amount: String) {
        guard let controller = controller else {return}
        controller.showActivity()
        var additionalArray = [[String: String]]()
        additionalDic.forEach { item in
            additionalArray.append(item.value)
        }
        stepsPayment.append(additionalArray)
        let request = getNextStepRequest(amount: amount, additionalArray: additionalArray)
        doNextStepServiceTransfer(request: request) { response, error in
            guard let controller = self.controller else {return}
            controller.dismissActivity()
            controller.animationShow(controller.goButton)
            if error != nil {
                controller.showAlert(with: "Ошибка", and: error!)
            } else {
                if let respUnw = response {
                    if respUnw.data?.finalStep ?? false {
                        controller.doConfirmation(response: respUnw)
                    } else {
                        if respUnw.data?.needSum ?? false {
                            controller.showFinalStep()
                        } else {
                            controller.setupNextStep(respUnw)
                        }
                    }
                }
            }
        }
    }

    func getNextStepRequest(amount: String, additionalArray: [[String: String]]) -> [String: AnyObject] {
        var request = [String: AnyObject]()
        request = [ "amount" : amount,
                    "additional" : additionalArray] as [String: AnyObject]
        return request
    }

    func getCreateRequest(amount: String, additionalArray: [[String: String]], productType: String, id: Int, puref: String) -> [String: AnyObject] {
        var request = [String: AnyObject]()
        if productType == "ACCOUNT" {
            request = [ "check" : false,
                        "amount" : amount,
                        "currencyAmount" : "RUB",
                        "payer" : [ "cardId" : nil,
                                    "cardNumber" : nil,
                                    "accountId" : id ],
                        "puref" : puref,
                        "additional" : additionalArray] as [String: AnyObject]

        } else if productType ==  "CARD" {
            request = [ "check" : false,
                        "amount" : amount,
                        "currencyAmount" : "RUB",
                        "payer" : [ "cardId" : id,
                                    "cardNumber" : nil,
                                    "accountId" : nil ],
                        "puref" : puref,
                        "additional" : additionalArray] as [String: AnyObject]
        }
        return request
    }

    func doCreateInternetTransfer(request: [String: AnyObject], completion: @escaping (CreateTransferAnswerModel?, String?) -> ()) {
        NetworkManager<CreateTransferAnswerModel>.addRequest(.createInternetTransfer, [:], request) { respModel, error in
            if error != nil {
                completion(nil, error!)
            }
            guard let respModel = respModel else { return }
            if respModel.statusCode == 0 {
                completion(respModel, nil)
            } else {
                completion(nil, respModel.errorMessage)
            }
        }
    }

    func doNextStepServiceTransfer(request: [String: AnyObject], completion: @escaping (CreateTransferAnswerModel?, String?) -> ()) {
        NetworkManager<CreateTransferAnswerModel>.addRequest(.nextStepServiceTransfer, [:], request) { respModel, error in
            if error != nil {
                completion(nil, error!)
            }
            guard let respModel = respModel else { return }
            if respModel.statusCode == 0 {
                completion(respModel, nil)
            } else {
                completion(nil, respModel.errorMessage)
            }
        }
    }

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

}
