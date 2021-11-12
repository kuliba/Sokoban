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
        bottomView.doneButtonIsEnabled(true)
        if self.bottomView.requestModel.to == ""{
            self.bottomView.requestModel.to = viewModel.cardFromRealm?.currency ?? ""
        }
        
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
        print("DEBUG: ", #function, body)
        NetworkManager<CreatTransferDecodableModel>.addRequest(.createTransfer, [:], body) { [weak self] model, error in
            DispatchQueue.main.async {
                self?.dismissActivity()
                self?.bottomView.doneButtonIsEnabled(false)
                if error != nil {
                    guard let error = error else { return }
                    print("DEBUG: ", #function, error)
                    self?.showAlert(with: "Ошибка", and: error)
                } else {
                    guard let model = model else { return }
                    guard let statusCode = model.statusCode else { return }
                    if statusCode == 0 {
                        if let needMake = model.data?.needMake {
                            if needMake {
                                viewModel.taxTransction = "\(model.data?.fee ?? 0)"
                                viewModel.statusIsSuccses = true
                                print("DEBUG: cardToCard payment Succses", #function, model)
                                let vc = ContactConfurmViewController()
                                vc.modalPresentationStyle = .fullScreen
                                vc.confurmVCModel?.type = .card2card
                                viewModel.summTransction = model.data?.debitAmount?.currencyFormatter(symbol: model.data?.currencyPayer ?? "RUB") ?? ""
                                viewModel.summInCurrency = model.data?.creditAmount?.currencyFormatter(symbol: model.data?.currencyPayee ?? "RUB") ?? ""
                                viewModel.taxTransction = model.data?.fee?.currencyFormatter(symbol: model.data?.currencyPayer ?? "RUB") ?? ""
                                vc.smsCodeField.isHidden = !(model.data?.needOTP ?? true)
                                vc.confurmVCModel = viewModel
                                vc.addCloseButton()
                                vc.title = "Подтвердите реквизиты"
                                let navVC = UINavigationController(rootViewController: vc)
                                self?.present(navVC, animated: true)
                                
                            } else {
                                let vc = PaymentsDetailsSuccessViewController()
                                if model.data?.documentStatus == "COMPLETE" {
                                    viewModel.statusIsSuccses = true
                                    viewModel.taxTransction = model.data?.fee?.currencyFormatter(symbol: model.data?.currencyAmount ?? "RUB") ?? ""
                                    viewModel.summTransction = model.data?.debitAmount?.currencyFormatter(symbol: model.data?.currencyAmount ?? "RUB") ?? ""
                                    vc.id = model.data?.paymentOperationDetailID ?? 0
                                    vc.printFormType = "internal"
                                  
                                }
                                vc.confurmVCModel = viewModel
                                vc.modalPresentationStyle = .fullScreen
                                self?.present(vc, animated: true, completion: nil)
                                
                            }
                        } else {
                            viewModel.statusIsSuccses = true
                            let vc = PaymentsDetailsSuccessViewController()
                            vc.confurmVCModel = viewModel
                            vc.modalPresentationStyle = .fullScreen
                            self?.present(vc, animated: true, completion: nil)
                        }
                    } else {
                        print("DEBUG: ", #function, model.errorMessage ?? "nil")
                        self?.showAlert(with: "Ошибка", and: model.errorMessage ?? "")
                    }
                }
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
    
//   final func hideAllCardList() {
//        DispatchQueue.main.async {
//            UIView.animate(withDuration: 0.2) {
//                self.cardFromListView.isHidden = true
//                self.cardFromListView.alpha = 0
//
//                self.cardToListView.isHidden = true
//                self.cardToListView.alpha = 0
//
//                self.stackView.layoutIfNeeded()
//            }
//        }
//    }
    
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
