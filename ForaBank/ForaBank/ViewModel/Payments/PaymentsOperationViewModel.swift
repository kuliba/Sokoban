//
//  PaymentsOperationViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 16.02.2022.
//

import SwiftUI
import Combine

class PaymentsOperationViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()

    @Published var header: HeaderViewModel
    @Published var items: [PaymentsParameterViewModel]
    @Published var footer: FooterViewModel?
    @Published var popUpSelector: PaymentsPopUpSelectView.ViewModel?
    
    var operation: Payments.Operation
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    internal init(header: HeaderViewModel,
                  items: [PaymentsParameterViewModel],
                  footer: FooterViewModel?,
                  operation: Payments.Operation = .emptyMock,
                  model: Model = .emptyMock) {
        
        self.header = header
        self.items = items
        self.footer = footer
        self.operation = operation
        self.model = model
    }
    
    internal init(_ model: Model, operation: Payments.Operation, dismissAction: @escaping () -> Void) throws {
        
        self.model = model
        self.header = .init(title: operation.service.name, action: dismissAction)
        self.items = []
        self.operation = operation
        
        let updatedItems = try createItems(from: operation.parameters)
        withAnimation {
            items = updatedItems
        }
        
        bind(items: items)
        bind()
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Payment.Continue.Response:
                    
                    let result = payload.result
                    switch result {

                    case .step(let operation):
                        do {
                            
                            let updatedItems = try createItems(from: operation.parameters)
                            withAnimation {
                                self.items = updatedItems
                            }
                            
                            self.bind(items: items)
                            self.operation = operation
                            
                        } catch {
                            //TODO: log error
                            print(error.localizedDescription)
                        }
                        
                    case .confirm(let operation):
                        //TODO: open confirm operation screen
                        
                        
                        break
                        
                    case .fail(_):
                        break
                    }
                default: break
                }
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsOperationViewModelAction.Continue:
                    
                    let results = items.map{ $0.result }
                    let update = operation.update(with: results)
                    model.action.send(ModelAction.Payment.Continue.Request(operation: update.operation))
                    
                case let payload as PaymentsOperationViewModelAction.ShowPopUpSelectView:
                    
                    popUpSelector = PaymentsPopUpSelectView.ViewModel(
                        with: payload.parameter,
                        selectedID: payload.selectedId, action: { [weak self] selectedId in
                            
                            let item = self?.items.first(where: { $0.id == payload.parameter.parameter.id })
                            item?.update(value: selectedId)
                            self?.popUpSelector = nil
                        })
                    
                default: break
                }
            }.store(in: &bindings)
       
        
    }
    
    private func bind(items: [PaymentsParameterViewModel]) {
        
        for item in items {
            
            item.$value
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] value in
                    
                    guard value.isChanged == true else {
                        return
                    }
                    
                    if let parameterViewModel = items.first(where: { $0.id == item.id}) as? PaymentsParameterInputView.ViewModel  {
                        
                        updateFooter(isContinueEnabled: parameterViewModel.isValid)
                        
                    }
                    
                    let results = items.map{ $0.result }
                    let update = operation.update(with: results)
                    
                    switch update.type {
                    case .normal:
                        
                        if isContinueOperationRequired(for: value.id) {
                            
                            model.action.send(ModelAction.Payment.Continue.Request(operation: update.operation))
                        } else {
                            
                            operation = update.operation
                        }
                        
                    case .historyChanged:
                        model.action.send(ModelAction.Payment.Continue.Request(operation: update.operation))
                    }
            
                }.store(in: &bindings)
        }
    }
    
    func updateFooter(isContinueEnabled: Bool) {
        guard let footer = footer else { return }

        switch footer {
            
        case .button(let continueButtonViewModel):
            continueButtonViewModel.isEnabled = isContinueEnabled
            self.footer = .button(continueButtonViewModel)
            
        case .amount(let amountViewModel):
            amountViewModel.updateTranferButton(isEnabled: isContinueEnabled)
            self.footer = .amount(amountViewModel)
        }
    }
    
    
    
    func isContinueOperationRequired(for parameterId: Payments.Parameter.ID) -> Bool {
        
        guard let parameterViewModel = items.first(where: { $0.id == parameterId}) else {
            return false
        }
 
        switch parameterViewModel.source {
        case _ as Payments.ParameterSelect:
            return true
            
        case _ as Payments.ParameterSelectSwitch:
            return true
            
        case _ as Payments.ParameterSelectSimple:
            return true
            
        default:
            return false
        }
    }
    
    func createItems(from parameters: [ParameterRepresentable]) throws -> [PaymentsParameterViewModel] {
        
        //TODO: add action for button
        self.footer = .button(.init(title: "Продолжить", isEnabled: false, action: { [weak self] in
            self?.action.send(PaymentsOperationViewModelAction.Continue())
        }))
        
        var result = [PaymentsParameterViewModel]()
        for parameter in parameters {
            
            
            //TODO: add rest parameters view models
            switch parameter {
            case let parameterSelect as Payments.ParameterSelect:
                result.append(try PaymentsParameterSelectView.ViewModel(with: parameterSelect))
                if parameterSelect.parameter.value == nil, case .button(_) = footer {
                    
                    footer = nil
                }
                
            case let parameterSwitch as Payments.ParameterSelectSwitch:
                result.append(try PaymentsParameterSwitchView.ViewModel(with: parameterSwitch))
                
            case let parameterInfo as Payments.ParameterInfo:
                result.append(try PaymentsParameterInfoView.ViewModel(with: parameterInfo))
                
            case let parameterInput as Payments.ParameterInput:
                result.append(try PaymentsParameterInputView.ViewModel(with: parameterInput))
                
            case let paremetrName as Payments.ParameterName:
                result.append(try PaymentsParameterNameView.ViewModel(with: paremetrName))
                
                //TODO: Init for ParameterAmount
            case let parameterAmount as Payments.ParameterAmount:
                footer = .amount(.init(with: parameterAmount))
                
            case let parameterSelectSimple as Payments.ParameterSelectSimple:
                result.append(try PaymentsParameterSelectSimpleView.ViewModel(
                    with: parameterSelectSimple, action: { [weak self] in
                        self?.action.send(PaymentsOperationViewModelAction.ShowPopUpSelectView(
                            parameter: parameterSelectSimple,
                            selectedId: parameterSelectSimple.parameter.value))
                    }))

                
            default:
                break
            }
            
        }
        
        return result
    }
    
    enum FooterViewModel {
        
        case button(ContinueButtonViewModel)
        case amount(PaymentsParameterAmountView.ViewModel)
    }
    
    class ContinueButtonViewModel: ObservableObject {

        let title: String
        @Published var isEnabled: Bool
        let action: () -> Void
        
        internal init(title: String, isEnabled: Bool, action: @escaping () -> Void) {
            
            self.title = title
            self.action = action
            self.isEnabled = isEnabled
        }
    }
}

extension PaymentsOperationViewModel {
    
    struct HeaderViewModel {
        
        let title: String
        let backButtonIcon = Image("back_button")
        let action: () -> Void
    }
}

enum PaymentsOperationViewModelAction {
    
    struct Continue: Action {}
    
    struct ShowPopUpSelectView: Action {
        
        let parameter: Payments.ParameterSelectSimple
        let selectedId: Payments.ParameterSelectSimple.Option.ID?
    }
}
