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
    private var itemsBindings = Set<AnyCancellable>()
    
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
        
        try createItemsAndFooter(from: operation.parameters, isCollapsed: true)
        bind()
        
        print("Payments: init")
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Payment.Continue.Response:
                    
                    print("Payments: continue response")
                    
                    let result = payload.result
                    switch result {
                    case .step(let operation):
                        do {
                            
                            try createItemsAndFooter(from: operation.parameters, isCollapsed: true)
                            self.operation = operation
                            
                        } catch {
                            //TODO: log error
                            print(error.localizedDescription)
                        }
                        
                    case .confirm(let operation):
                        //TODO: open confirm operation screen
                        
                        print("Payments: open confirm view")
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
                    
                    print("Payments: item value changed")

                    let results = items.map{ $0.result }
                    let update = operation.update(with: results)
                    
                    switch update.type {
                    case .normal:
                        
                        print("Payments: normal update")
                        
                        if isContinueOperationRequired(for: value.id) {
                            
                            model.action.send(ModelAction.Payment.Continue.Request(operation: update.operation))
                            
                        } else {
                            
                            operation = update.operation
                            updateFooter(isContinueEnabled: isAllItemsValid())
                        }
                        
                    case .historyChanged:
                        
                        print("Payments: history changed")
                        model.action.send(ModelAction.Payment.Continue.Request(operation: update.operation))
                    }
                    
                }.store(in: &itemsBindings)
            
            
            if let simpleSelectItem = item as? PaymentsSelectSimpleView.ViewModel {
                
                simpleSelectItem.action
                    .receive(on: DispatchQueue.main)
                    .sink {[unowned self] action in
                        
                        switch action {
                        case _ as PaymentsSelectSimpleView.ViewModelAction.SelectOptionExternal:
                            
                            guard let simpleSelectParameter = simpleSelectItem.source as? Payments.ParameterSelectSimple else {
                                return
                            }
                            
                            self.action.send(PaymentsOperationViewModelAction.ShowPopUpSelectView(
                                parameter: simpleSelectParameter,
                                selectedId: simpleSelectParameter.parameter.value))
                            
                        default:
                            break
                        }
                        
                    }.store(in: &itemsBindings)
            }
            
            if let additionalButtonItem = item as? PaymentsButtonAdditionalView.ViewModel {
                
                additionalButtonItem.$isSelected
                    .dropFirst()
                    .receive(on: DispatchQueue.main)
                    .sink {[unowned self] selected in
                        
                        do {
                            
                            try createItemsAndFooter(from: operation.parameters, isCollapsed: selected)
                            
                        } catch {
                            
                            //TODO: log error
                            print(error.localizedDescription)
                        }
       
                    }.store(in: &itemsBindings)
            }
        }
    }

    func isAllItemsValid() -> Bool {
        
        for item in items {
            
            guard item.isValid == true else {
                return false
            }
        }
        
        return true
    }
    
    func updateFooter(isContinueEnabled: Bool) {
        
        guard let footer = footer else { return }

        switch footer {
        case .button(let continueButtonViewModel):
            print("Payments: footer button updated", isContinueEnabled)
            continueButtonViewModel.isEnabled = isContinueEnabled
            self.footer = .button(continueButtonViewModel)
            
        case .amount(let amountViewModel):
            print("Payments: footer amount updated", isContinueEnabled)
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
    
    func createItemsAndFooter(from parameters: [ParameterRepresentable], isCollapsed: Bool) throws {
        
        let updatedItems = try Self.createItems(from: parameters)
        let collapsableItems = updateCollapsable(items: updatedItems, isCollapsed: isCollapsed)
        
        withAnimation {
            
            items = collapsableItems
            footer = createFooter(from: parameters)
        }
        
        itemsBindings = Set<AnyCancellable>()
        bind(items: items)
        
        updateFooter(isContinueEnabled: isAllItemsValid())
    }
    
    static func createItems(from parameters: [ParameterRepresentable]) throws -> [PaymentsParameterViewModel] {

        var result = [PaymentsParameterViewModel]()
        for parameter in parameters {

            //TODO: add rest parameters view models
            switch parameter {
            case let parameterSelect as Payments.ParameterSelect:
                result.append(try PaymentsSelectView.ViewModel(with: parameterSelect))
                
            case let parameterSwitch as Payments.ParameterSelectSwitch:
                result.append(try PaymentsSwitchView.ViewModel(with: parameterSwitch))
                
            case let parameterInfo as Payments.ParameterInfo:
                result.append(try PaymentsInfoView.ViewModel(with: parameterInfo))
                
            case let parameterInput as Payments.ParameterInput:
                result.append(try PaymentsInputView.ViewModel(with: parameterInput))
                
            case let paremetrName as Payments.ParameterName:
                result.append(try PaymentsNameView.ViewModel(with: paremetrName))
                
            case let parameterSelectSimple as Payments.ParameterSelectSimple:
                result.append(try PaymentsSelectSimpleView.ViewModel(
                    with: parameterSelectSimple))
                
            case let parameterCard as Payments.ParameterCard:
                result.append(PaymentsCardView.ViewModel(with: parameterCard))
                
            default:
                break
            }
        }
        
        return result
    }
    
    func updateCollapsable(items: [PaymentsParameterViewModel], isCollapsed: Bool) -> [PaymentsParameterViewModel] {
        
        guard let lastCollapsableItem = items.filter({ $0.isCollapsable == true }).last,
        let lastCollapsableItemIndex = items.firstIndex(where: { $0.source.parameter.id == lastCollapsableItem.id}) else {
 
            return items
        }
        
        var mutableItems = items
        
        let additionalButtonItem = PaymentsButtonAdditionalView.ViewModel(title: "Дополнительные данные", isSelected: isCollapsed)
        mutableItems.insert(additionalButtonItem, at: lastCollapsableItemIndex + 1)
        
        if isCollapsed == true {
            
            // remove all collapsable items
            var updatedItems = [PaymentsParameterViewModel]()
            for item in mutableItems {
                
                guard item.isCollapsable == false else {
                    continue
                }
                
                updatedItems.append(item)
            }
            
            return updatedItems
            
        } else {
            
            return mutableItems
        }
    }
    
    func createFooter(from parameters: [ParameterRepresentable]) -> FooterViewModel? {

        var footer: FooterViewModel?  = .button(.init(title: "Продолжить", isEnabled: false, action: { [weak self] in
            self?.action.send(PaymentsOperationViewModelAction.Continue())
        }))
        
        for parameter in parameters {

            switch parameter {
            case let parameterSelect as Payments.ParameterSelect:
                if parameterSelect.parameter.value == nil, case .button(_) = footer {
                    
                    footer = nil
                }

            case let parameterAmount as Payments.ParameterAmount:
                footer = .amount(.init(with: parameterAmount,actionTitle: "Перевести", action: { [weak self] in
                    self?.action.send(PaymentsOperationViewModelAction.Continue())
                }))
                                
            default:
                break
            }
            
        }
        
        return footer
    }
}

//MARK: - Types

extension PaymentsOperationViewModel {
    
    enum FooterViewModel {
        
        case button(ContinueButtonViewModel)
        case amount(PaymentsAmountView.ViewModel)
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
