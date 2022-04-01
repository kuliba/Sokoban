import Foundation

class GIBDDFineDetailsFormViewModel {

    static var additionalDic = [String: [String: String]]()
    var controller: GIBDDFineDetailsFormController? = nil
    var firstStep = true
    var finalStep = false
    var additionalFields = [[String: String]]()
    var stepsPayment = [[[String: String]]]()
    var requisites = [RequisiteDO]()
    var puref = ""
    var cardNumber = ""
    var product: GetProductListDatum?


    func setupNextStep(_ answer: CreateTransferAnswerModel) {
        fillRequisites(answer: answer)
        DispatchQueue.main.async {
            if let msg = answer.data?.infoMessage {
                let infoView = GKHInfoView()
                infoView.label.text = msg
                self.controller?.showAlert(infoView)
            }
        }
    }

    func fillRequisites(answer: CreateTransferAnswerModel) {
        requisites.forEach { item in
            item.readOnly = true
        }
        answer.data?.additionalList?.forEach { item in
            let param = RequisiteDO()
            param.subTitle = ""
            param.id = item.fieldName
            param.title = item.fieldTitle
            param.content = item.fieldValue
            param.readOnly = true
            param.svgImage = item.svgImage
            if (requisites.first { requisite in
                requisite.id == param.id
            } == nil) {
                requisites.append(param)
            }
        }

        answer.data?.parameterListForNextStep?.forEach { item in
            let req = RequisiteDO.convertParameter(item)
            if let userInfoUnw = InternetTVApiRequests.userInfo {
                if item.id?.lowercased().contains("iregcert") == true {
                    req.content = "\(userInfoUnw.regSeries ?? "")\(userInfoUnw.regNumber ?? "")"
                } else if item.id?.lowercased().contains("lastname") == true {
                    req.content = userInfoUnw.lastName
                } else if item.id?.lowercased().contains("firstname") == true {
                    req.content = userInfoUnw.firstName
                } else if item.id?.lowercased().contains("middlename") == true {
                    req.content = userInfoUnw.patronymic
                } else if item.id?.lowercased().contains("address") == true {
                    req.content = userInfoUnw.address
                }
            }
            if (requisites.first { requisite in
                requisite.id == req.id
            } == nil) {
                requisites.append(req)
            }
        }
        DispatchQueue.main.async {
            self.controller?.tableView?.reloadData()
        }
    }

    func retryPayment(amount: String) {
        guard let controller = controller else {
            return
        }
        let request = getRequestBody(amount: amount, additionalArray: additionalFields)
        InternetTVApiRequests.createAnywayTransferNew(request: request) { response, error in
            controller.dismissActivity()
            sleep(1)
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
        guard let controller = controller else {
            return
        }
        var additionalArray = [[String: String]]()
        InternetTVDetailsFormViewModel.additionalDic.forEach { item in
            additionalArray.append(item.value)
        }
        var request = getRequestBody(amount: amount, additionalArray: additionalFields)
        if stepsPayment.count > 0 {
            request = getRequestBody(amount: amount, additionalArray: stepsPayment.removeFirst())
        }
        InternetTVApiRequests.createAnywayTransfer(request: request) { response, error in
            guard let controller = self.controller else {
                return
            }
            controller.dismissActivity()
            controller.animationShow(controller.goButton!)
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

    func doFirstStep(amount: String) {
        guard let controller = controller else {
            return
        }
        var additionalArray = [[String: String]]()
        InternetTVDetailsFormViewModel.additionalDic.forEach { item in
            additionalArray.append(item.value)
        }
        additionalFields = additionalArray
        let request = getRequestBody(amount: amount, additionalArray: additionalArray)

        InternetTVApiRequests.createAnywayTransferNew(request: request) { response, error in
            guard let controller = self.controller else {
                return
            }
            DispatchQueue.main.async {
                controller.dismissActivity()
                sleep(1)
                controller.animationShow(controller.goButton!)
                if error != nil {
                    controller.goButton?.isHidden = true
                    controller.showAlert(with: "Ошибка", and: error!)
                } else {
                    if InternetTVApiRequests.isSingleService {
                        controller.doConfirmation(response: response)
                    } else {
                        if let respUnw = response {
                            if respUnw.data?.needSum ?? false {
                                self.fillRequisites(answer: respUnw)
                                if let sum = respUnw.data?.amount, sum > 0 {
                                    self.controller?.bottomInputView?.amountTextField.text = "\(sum)\(self.controller?.bottomInputView?.amountTextField.text ?? "")"
                                    //self.controller?.bottomInputView?.amountTextField.isEnabled = false
                                }
                                controller.showPaymentField()
                            }
                            self.finalStep = respUnw.data?.finalStep ?? false
                            if self.finalStep {
                                controller.showPaymentField()
                            } else {
                                self.setupNextStep(respUnw)
                            }
                        }
                    }
                }
            }
        }
    }

    func doNextStep(amount: String) {
        guard let controller = controller else {
            return
        }
        var additionalArray = [[String: String]]()
        InternetTVDetailsFormViewModel.additionalDic.forEach { item in
            additionalArray.append(item.value)
        }
        stepsPayment.append(additionalArray)
        let request = getRequestBody(amount: amount, additionalArray: additionalArray)
        InternetTVApiRequests.createAnywayTransfer(request: request) { response, error in
            guard let controller = self.controller else {
                return
            }
            DispatchQueue.main.async {
                controller.dismissActivity()
                sleep(1)
                controller.animationShow(controller.goButton!)
                if error != nil {
                    controller.goButton?.isHidden = true
                    controller.showAlert(with: "Ошибка", and: error!)
                } else {
                    if let respUnw = response {
                        if respUnw.data?.finalStep ?? false {
                            controller.doConfirmation(response: respUnw)
                        } else {
                            if respUnw.data?.needSum ?? false {
                                if let sum = respUnw.data?.amount, sum > 0 {
                                    self.controller?.bottomInputView?.amountTextField.text = "\(sum)\(self.controller?.bottomInputView?.amountTextField.text ?? "")"
                                    //self.controller?.bottomInputView?.amountTextField.isEnabled = false
                                }
                                controller.showPaymentField()
                            }
                            self.finalStep = respUnw.data?.finalStep ?? false
                            if self.finalStep {
                                controller.showPaymentField()
                            } else {
                                self.setupNextStep(respUnw)
                            }
                        }
                    }
                }
            }
        }
    }

    func getRequestBody(amount: String, additionalArray: [[String: String]]) -> [String: AnyObject] {
        let productType = controller?.footerView.cardFromField.model?.productType ?? ""
        let id = controller?.footerView.cardFromField.model?.id ?? -1

        var request = [String: AnyObject]()
        if productType == "ACCOUNT" {
            request = ["check": false,
                       "amount": amount,
                       "currencyAmount": "RUB",
                       "payer": ["cardId": nil,
                                 "cardNumber": nil,
                                 "accountId": String(id)],
                       "puref": puref,
                       "additional": additionalArray] as [String: AnyObject]

        } else if productType == "CARD" {
            request = ["check": false,
                       "amount": amount,
                       "currencyAmount": "RUB",
                       "payer": ["cardId": String(id),
                                 "cardNumber": nil,
                                 "accountId": nil],
                       "puref": puref,
                       "additional": additionalArray] as [String: AnyObject]
        }
        return request
    }

    func getCardList(completion: @escaping (_ cardList: [GetProductListDatum]?, _ error: String?) -> ()) {
        let param = ["isCard": "true", "isAccount": "true", "isDeposit": "false", "isLoan": "false"]
        NetworkManager<GetProductListDecodableModel>.addRequest(.getProductListByFilter, param, [:]) { model, error in
            if error != nil {
                completion(nil, error)
            }
            guard let model = model else {
                return
            }
            if model.statusCode == 0 {
                guard let cardList = model.data else {
                    return
                }
                completion(cardList, nil)
            } else {
                guard let error = model.errorMessage else {
                    return
                }
                completion(nil, error)
            }
        }
    }
}
