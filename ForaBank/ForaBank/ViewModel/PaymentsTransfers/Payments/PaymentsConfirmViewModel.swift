//
//  PaymentsConfirmViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 10.03.2022.
//

import Foundation
import SwiftUI
import Combine

class PaymentsConfirmViewModel: PaymentsOperationViewModel {
    
    convenience init(operation: Payments.Operation, model: Model, closeAction: @escaping () -> Void) {

        self.init(navigationBar: .init(), top: [], feed: [], bottom: [], link: nil, bottomSheet: nil, operation: operation, model: model, closeAction: closeAction)
        
        bind()
        
        if let antifraudData = model.paymentsAntifraudData(for: operation) {
            
            showAntifraudBottomSheet(with: antifraudData, operation: operation)
        }
    }
    
    override func bind() {
        
        super.bind()
        bindItems()
    }
    
    override func bindModel() {
        super.bindModel()
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Auth.VerificationCode.PushRecieved:
                    updateFeedSection(code: payload.code)
                    
                case let payload as ModelAction.Transfers.ResendCode.Response:
                    switch payload {
                    case let .success(data: data):
                        if data.resendOTPCount < 1 {
                            
                            guard let codeItem = items.compactMap({ $0 as? PaymentsCodeView.ViewModel }).first else {
                                return
                            }
                            
                            codeItem.action.send(PaymentsParameterViewModelAction.Code.ResendCodeDisabled())
                        }
                        
                    case let .failure(message: message):
                        self.action.send(PaymentsConfirmViewModelAction.ShowErrorAlert(message: message))
                    }

                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    override func bindAction() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsOperationViewModelAction.ItemDidUpdated:
                    // update bottom section continue button
                    updateBottomSection(isContinueEnabled: isItemsValuesValid)
                    
                case _ as PaymentsOperationViewModelAction.Continue:
                    // update operation with parameters
                    let updatedOperation = Self.reduce(operation: operation.value, items: items)
                    
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "Confirm operation: \(updatedOperation)")
                    
                    // continue operation
                    model.action.send(ModelAction.Payment.Process.Request(operation: updatedOperation))
                    self.action.send(PaymentsOperationViewModelAction.Spinner.Show())
                    
                    // hide keyboard
                    UIApplication.shared.endEditing()
                    
                case _ as PaymentsConfirmViewModelAction.IcorrectCodeEnterred:
                    guard let codeItem = items.compactMap({ $0 as? PaymentsCodeView.ViewModel }).first else {
                        return
                    }
                    
                    codeItem.action.send(PaymentsParameterViewModelAction.Code.IncorrectCodeEntered())
                    
                case _ as PaymentsOperationViewModelAction.Spinner.Show:
                    withAnimation {
                        spinner = .init()
                    }
                    
                case _ as PaymentsOperationViewModelAction.Spinner.Hide:
                    withAnimation {
                        spinner = nil
                    }
                    
                case _ as PaymentsOperationViewModelAction.CloseBottomSheet:
                    bottomSheet = nil
     
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    func bindItems() {
        
        $top
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] topGroups in
                
                guard let topItems = topGroups else { return }
                updateEditable(for: topItems)
                
            }.store(in: &bindings)
        
        $feed
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] contentGroups in
                
                updateEditable(for: contentGroups)
                
            }.store(in: &bindings)
        
        $bottom
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] bottomGroups in
                
                guard let bottomGroups = bottomGroups else { return }
                updateEditable(for: bottomGroups)
                
            }.store(in: &bindings)
    }
}

//MARK: - Action

enum PaymentsConfirmViewModelAction {
    
    struct IcorrectCodeEnterred: Action {}
    
    struct ShowErrorAlert: Action {
        
        let message: String
    }
    
    struct CancelOperation: Action {
        
        let amount: String
        let reason: String?
    }
}

//MARK: - Helpers

extension PaymentsConfirmViewModel {
    
    func updateFeedSection(code: String) {
        
        guard let codeParameter = items.first(where: { $0.source.id == Payments.Parameter.Identifier.code.rawValue }) as? PaymentsCodeView.ViewModel else {
            return
        }
        
        codeParameter.textField.setText(to: code)
    }
    
    func updateEditable(for groups: [PaymentsGroupViewModel]) {
        
        for group in groups {
            
            for item in group.items {
                
                switch item.source.id {
                case Payments.Parameter.Identifier.code.rawValue:
                    continue
                    
                default:
                    item.updateEditable(update: .value(false))
                }
            }
        }
    }
    
    func showAntifraudBottomSheet(with antifraudData: Payments.AntifraudData, operation: Payments.Operation) {
        
        let antifraudViewModel = PaymentsAntifraudViewModel(with: antifraudData) { [weak self] in
            
            self?.action.send(PaymentsOperationViewModelAction.CloseBottomSheet())
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                
                self?.action.send(PaymentsConfirmViewModelAction.CancelOperation(amount: antifraudData.amount, reason: nil))
            }
            
        } continueAction: { [weak self] in
            
            self?.action.send(PaymentsOperationViewModelAction.CloseBottomSheet())
        }
        
        let antifraudBottomSheet = BottomSheet(type: .antifraud(antifraudViewModel))
        antifraudBottomSheet.isUserInteractionEnabled.value = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
            
            self.bottomSheet = antifraudBottomSheet
        }
    }
}
