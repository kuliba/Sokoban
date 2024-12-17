//
//  ExtensionCustomPopUpSetup.swift
//  ForaBank
//
//  Created by Константин Савялов on 02.08.2021.
//

import UIKit

extension CustomPopUpWithRateView {
    //MARK: - API
    
    func doneButtonTapped(with viewModel: ConfirmViewControllerModel) {
        self.dismissKeyboard()
        self.showActivity()
        checkDeposit(with: viewModel.cardToRealm,
                     and: viewModel.summTransction,
                     currency: viewModel.cardFromRealm?.currency ?? "") { check, error in
            if error != nil {
                self.dismissActivity()
                self.showAlert(with: "Невозможно пополнить", and: error ?? "")
            } else {
                if check == true {
                    self.transferModey(with: viewModel)
                } else {
                    self.dismissActivity()
                }
            }
        }
    }
    
    func closeDeposit() {
        
        let product = cardFromField.model
        
        if viewModel.cardToRealm?.productType == ProductType.account.rawValue {
            
            Model.shared.action.send(ModelAction.Deposits.Close.Request(payload: .init(id: product?.depositID ?? 0, name: product?.productName, startDate: nil, endDate: nil, statementFormat: nil, accountId: viewModel.cardToRealm?.id, cardId: nil)))
        } else {
            
            Model.shared.action.send(ModelAction.Deposits.Close.Request(payload: .init(id: product?.depositID ?? 0, name: product?.productName, startDate: nil, endDate: nil, statementFormat: nil, accountId: nil, cardId: viewModel.cardToRealm?.cardID)))
        }
    }
    
    func interestPayment(amount: Double) {
        
        let payer = cardFromField.model
        let payeeInternal = cardToField.model
        
        if let depositId = payer?.depositID {
            
            switch cardToField.model?.productType {
            case "CARD":
             
                Model.shared.action.send(ModelAction.Transfers.CreateInterestDepositTransfer.Request(payload: .init(check: false, amount: amount, currencyAmount: payer?.currency, payer: .init(cardId: nil, cardNumber: nil, accountId: payer?.accountID, accountNumber: nil, phoneNumber: nil, inn: nil), comment: nil, payeeInternal: .init(accountId: nil, accountNumber: nil, cardId: payeeInternal?.cardID, cardNumber: nil, phoneNumber: nil, productCustomName: nil), payeeExternal: nil, depositId: depositId)))
                
            case "ACCOUNT":
                Model.shared.action.send(ModelAction.Transfers.CreateInterestDepositTransfer.Request(payload: .init(check: false, amount: amount, currencyAmount: payer?.currency, payer: .init(cardId: nil, cardNumber: nil, accountId: payer?.accountID, accountNumber: nil, phoneNumber: nil, inn: nil), comment: nil, payeeInternal: .init(accountId: payeeInternal?.id, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil, productCustomName: nil), payeeExternal: nil, depositId: depositId)))
                
            default:
                Model.shared.action.send(ModelAction.Transfers.CreateInterestDepositTransfer.Request(payload: .init(check: false, amount: amount, currencyAmount: payer?.currency, payer: .init(cardId: nil, cardNumber: nil, accountId: payer?.accountID, accountNumber: nil, phoneNumber: nil, inn: nil), comment: nil, payeeInternal: .init(accountId: payeeInternal?.id, accountNumber: nil, cardId: nil, cardNumber: nil, phoneNumber: nil, productCustomName: nil), payeeExternal: nil, depositId: depositId)))
            }
        }
    }
    
    func transferModey(with viewModel: ConfirmViewControllerModel) {
        
        bottomView.doneButtonIsEnabled(true)

        self.bottomView.requestModel.to = viewModel.cardFromRealm?.currency ?? ""
        
        let body = [ "check" : false,
                     "amount" : viewModel.summTransction,
                     "currencyAmount" : self.bottomView.requestModel.to,
                     "payer" : [
                        "cardId" : viewModel.cardFromCardId,
                        "cardNumber" : viewModel.cardFromCardNumber,
                        "accountId" : viewModel.cardFromAccountId,
                        "accountNumber" : viewModel.cardFromAccountNumber
                     ],
                     "payeeInternal" : [
                        "cardId" : viewModel.cardToCardId,
                        "cardNumber" : viewModel.cardToCardNumber,
                        "accountId" : viewModel.cardToAccountId,
                        "accountNumber" : viewModel.cardToAccountNumber,
                        "productCustomName" : viewModel.cardToCastomName
                     ] ] as [String : AnyObject]
        NetworkManager<CreatTransferDecodableModel>.addRequest(.createTransfer, [:], body) { [weak self] model, error in
            DispatchQueue.main.async {
                self?.dismissActivity()
                self?.bottomView.doneButtonIsEnabled(false)
                if error != nil {
                    guard let error = error else { return }
                    self?.showAlert(with: "Ошибка", and: error)
                } else {
                    guard let model = model else { return }
                    guard let statusCode = model.statusCode else { return }
                    if statusCode == 0 {
                        if let needMake = model.data?.needMake {
                            if needMake {
                                viewModel.taxTransction = "\(model.data?.fee ?? 0)"
                                viewModel.status = .succses
                                let vc = ContactConfurmViewController()
                                vc.getUImage = { self?.model.images.value[$0]?.uiImage }
                                vc.modalPresentationStyle = .fullScreen
                                vc.confurmVCModel?.type = .card2card
                                viewModel.summTransction = model.data?.debitAmount?.currencyFormatter(symbol: model.data?.currencyPayer ?? "RUB") ?? ""
                                viewModel.summInCurrency = model.data?.creditAmount?.currencyFormatter(symbol: model.data?.currencyPayee ?? "RUB") ?? ""
                                viewModel.taxTransction = model.data?.fee?.currencyFormatter(symbol: model.data?.currencyPayer ?? "RUB") ?? ""
                                viewModel.template = self?.paymentTemplate
                                
                                vc.smsCodeField.isHidden = !(model.data?.needOTP ?? true)
                                vc.confurmVCModel = viewModel
                                vc.addCloseButton()
                                vc.title = "Подтвердите реквизиты"
                                let navVC = UINavigationController(rootViewController: vc)
                                navVC.modalPresentationStyle = .fullScreen
                                self?.present(navVC, animated: true)
                                
                            } else {
                                let vc = PaymentsDetailsSuccessViewController()
                                if model.data?.documentStatus == "COMPLETE" {
                                    viewModel.status = .succses
                                    viewModel.taxTransction = model.data?.fee?.currencyFormatter(symbol: model.data?.currencyAmount ?? "RUB") ?? ""
                                    viewModel.summTransction = model.data?.debitAmount?.currencyFormatter(symbol: model.data?.currencyAmount ?? "RUB") ?? ""
                                    viewModel.paymentOperationDetailId = model.data?.paymentOperationDetailID ?? 0
                                    vc.printFormType = "internal"
                                    viewModel.template = self?.paymentTemplate
                                    if let paymentOperationDetailId = model.data?.paymentOperationDetailID {
                                        if viewModel.template == nil {
                                            viewModel.templateButtonViewModel = .sfp(name: "Перевод между счетами", paymentOperationDetailId: paymentOperationDetailId)
                                        } else {
                                            viewModel.templateButtonViewModel = .template(paymentOperationDetailId)
                                        }
                                    }
                                }
                                vc.confurmVCModel = viewModel
                                vc.closeAction = viewModel.closeAction
                                vc.modalPresentationStyle = .fullScreen
                                self?.present(vc, animated: true, completion: nil)
                            }
                        } else {
                            viewModel.status = .succses
                            let vc = PaymentsDetailsSuccessViewController()
                            vc.confurmVCModel = viewModel
                            vc.closeAction = viewModel.closeAction
                            vc.modalPresentationStyle = .fullScreen
                            self?.present(vc, animated: true, completion: nil)
                        }
                    } else {
                        self?.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                    }
                }
            }
        }
    }
    
    func checkDeposit(with: UserAllCardsModel?, and amount: String, currency: String, completion: @escaping(_ rate: Bool?,_ error: String?) -> Void) {
        if with?.productType == "DEPOSIT" {
            if let card = with {
                if card.allowCredit {
                    let amount = Double(amount) ?? 0.0
                    
                    if currency == with?.currency {
                        if card.creditMinimumAmount <= amount {
                            completion(true, nil)
                        } else {
                            completion(false, "Введенная сумма меньше минимальной суммы пополнения")
                        }
                    } else {
                        checkCurrency(currency: currency) { rate, error in
                            if error != nil {
                                completion(false, "Вклад не предусматривает возможности пополнения. Подробнее в информации о вкладе в деталях")
                            } else {
                                let rate = amount * (rate ?? 0)
                                if card.creditMinimumAmount <= rate {
                                    completion(true, nil)
                                } else {
                                    completion(false, "Введенная сумма меньше минимальной суммы пополнения")
                                }
                            }
                        }
                    }
                } else {
                    completion(false, "Вклад не предусматривает возможности пополнения. Подробнее в информации о вкладе в деталях")
                }
            } else {
                completion(false, "Вклад не предусматривает возможности пополнения. Подробнее в информации о вкладе в деталях")
            }
        } else {
            completion(true, nil)
        }
    }
    
    private func checkCurrency(currency: String, completion: @escaping(_ rate: Double?,_ error: String?) -> Void)  {
        let bodyFrom = [ "currencyCodeAlpha" : currency] as [String: AnyObject]
        NetworkManager<GetExchangeCurrencyRatesDecodableModel>.addRequest(.getExchangeCurrencyRates, [:], bodyFrom) { model, error in
            if error != nil {
                completion(nil, error)
            } else {
                completion(model?.data?.rateSell ?? 0, nil)
            }
        }
    }
    
    final func hideCustomCardView() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1) {
                self.cardView.alpha = 0
                self.stackView.isHidden = false
                self.titleLabel.isHidden = false
                self.bottomView.isHidden = false
            } completion: { finish in
                if finish {
                    self.cardView.removeFromSuperview()
                    self.cardView.alpha = 1
                }
            }
        }
    }
    
    //MARK: - Animation
    func openOrHideView(_ view: UIView, completion: @escaping () -> Void ) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                if view.isHidden == true {
                    view.alpha = 1
                    view.isHidden = false
                } else {
                    view.isHidden = true
                    view.alpha = 0
                }
                self.stackView.layoutIfNeeded()
            }
        }
        completion()
    }
    
    func hideView(_ view: UIView, needHide: Bool, completion: @escaping () -> Void ) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                view.isHidden = needHide
                view.alpha = needHide ? 0 : 1
                self.stackView.layoutIfNeeded()
            }
        }
        completion()
    }
    
    
    final func setupCardViewActions() {
        cardView.closeView = { [weak self] () in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.1) {
                    self?.cardView.alpha = 0
                    self?.stackView.isHidden = false
                    self?.titleLabel.isHidden = false
                    self?.bottomView.isHidden = false
                } completion: { finish in
                    if finish {
                        self?.cardView.removeFromSuperview()
                        self?.cardView.alpha = 1
                    }
                }
            }
        }
        cardView.finishAndCloseView = { [weak self]  (model) in
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.1) {
                    self?.cardView.alpha = 0
                    self?.stackView.isHidden = false
                    self?.titleLabel.isHidden = false
                    self?.bottomView.isHidden = false
                } completion: { finish in
                    if finish {
                        self?.cardView.removeFromSuperview()
                        self?.cardView.alpha = 1
                    }
                    self?.viewModel.customCardTo = model
                    self?.cardToField.customCardModel = model
                }
            }
        }
    }
}
