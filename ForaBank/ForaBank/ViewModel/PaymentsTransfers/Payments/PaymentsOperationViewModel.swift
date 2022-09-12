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
    @Published var itemsVisible: [PaymentsParameterViewModel]
    @Published var footer: FooterViewModel?
    @Published var popUpSelector: PaymentsPopUpSelectView.ViewModel?
    
    @Published var isConfirmViewActive: Bool
    var confirmViewModel: PaymentsConfirmViewModel?
    
    internal var operation: Payments.Operation
    internal var items: CurrentValueSubject<[PaymentsParameterViewModel], Never> = .init([])
    internal var isAdditionalItemsCollapsed: CurrentValueSubject<Bool, Never> = .init(true)
    internal let rootActions: PaymentsViewModel.RootActions
    internal let model: Model
    internal var bindings = Set<AnyCancellable>()
    internal var itemsBindings = Set<AnyCancellable>()
    
    var itemsAll: [PaymentsParameterViewModel] {
        
        if case .amount(let amountItem) = footer {
            
            return items.value + [amountItem]
            
        } else {
            
            return items.value
        }
    }
    
    internal init(header: HeaderViewModel,
                  items: [PaymentsParameterViewModel],
                  footer: FooterViewModel?,
                  popUpSelector: PaymentsPopUpSelectView.ViewModel? = nil,
                  isConfirmViewActive: Bool = false,
                  confirmViewModel: PaymentsConfirmViewModel? = nil,
                  operation: Payments.Operation = .emptyMock,
                  rootActions: PaymentsViewModel.RootActions,
                  model: Model = .emptyMock) {
        
        self.header = header
        self.itemsVisible = items
        self.footer = footer
        self.popUpSelector = popUpSelector
        self.isConfirmViewActive = isConfirmViewActive
        self.confirmViewModel = confirmViewModel
        self.operation = operation
        self.rootActions = rootActions
        self.model = model
    }
    
    internal init(_ model: Model, operation: Payments.Operation, rootActions: PaymentsViewModel.RootActions) {
        
        self.model = model
        self.header = .init(title: operation.service.name, action: rootActions.dismiss)
        self.itemsVisible = []
        self.isConfirmViewActive = false
        self.operation = operation
        self.rootActions = rootActions
        
        createItemsAndFooter(from: operation.parameters)
        bind()
    }
    
    //MARK: Bind
    
    internal func bind() {
        
        bind(model: model)
        bindAction()
        bindItems()
    }
    
    //MARK: Bind Model
    
    internal func bind(model: Model) {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Payment.Continue.Response:
                    rootActions.spinner.hide()
                    switch payload.result {
                    case .step(let operation):
                        createItemsAndFooter(from: operation.parameters)
                        self.operation = operation
                        
                    case .confirm(let operation):
                        confirmViewModel = PaymentsConfirmViewModel(model, operation: operation, rootActions: .init(dismiss: {[weak self] in
                            self?.action.send(PaymentsOperationViewModelAction.DismissConfirm())
                        }, spinner: rootActions.spinner, alert: rootActions.alert))
                        isConfirmViewActive = true
                        self.operation = self.operation.finalized()
                        
                    case .failure(let errorMessage):
                        rootActions.alert(errorMessage)
                    }
                    
                case let payload as ModelAction.Auth.VerificationCode.PushRecieved:
                    guard let codeParameter = items.value.first(where: { $0.id == Payments.Parameter.Identifier.code.rawValue }) as? PaymentsInputView.ViewModel else {
                        return
                    }
                    
                    codeParameter.content = payload.code

                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    //MARK: Bind Action
    
    internal func bindAction() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsOperationViewModelAction.Continue:
                    let results = itemsAll.map{ ($0.result, $0.source.affectsHistory) }
                    let update = operation.update(with: results)
                    model.action.send(ModelAction.Payment.Continue.Request(operation: update.operation))
                    rootActions.spinner.show()
                    
                case _ as PaymentsOperationViewModelAction.Confirm:
                    let results = itemsAll.map{ ($0.result, $0.source.affectsHistory) }
                    let update = operation.update(with: results)
                    model.action.send(ModelAction.Payment.Complete.Request(operation: update.operation))
                    rootActions.spinner.show()
                    
                case let payload as PaymentsOperationViewModelAction.ShowPopUpSelectView:
                    popUpSelector = PaymentsPopUpSelectView.ViewModel(title: payload.title, description: payload.description, options: payload.options, selected: payload.selected, action: { [weak self] selectedId in
                        
                        let item = self?.itemsVisible.first(where: { $0.id == payload.parameterId })
                        item?.update(value: selectedId)
                        
                        self?.popUpSelector = nil
                    })

                case _ as PaymentsOperationViewModelAction.DismissConfirm:
                    isConfirmViewActive = false
                    confirmViewModel = nil
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    //MARK: Bind Items
    
    internal func bindItems() {
        
        items
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] items in
                
                withAnimation {
                    
                    itemsVisible = updateCollapsable(items: items, isCollapsed: isAdditionalItemsCollapsed.value)
                }
                
                itemsBindings = Set<AnyCancellable>()
                bind(items: itemsVisible)
                
            }.store(in: &bindings)
        
        isAdditionalItemsCollapsed
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isCollapsed in
                
                withAnimation {
                    
                    itemsVisible = updateCollapsable(items: items.value, isCollapsed: isCollapsed)
                }
                
                itemsBindings = Set<AnyCancellable>()
                bind(items: itemsVisible)
   
            }.store(in: &bindings)
    }
    
    //MARK: Bind Visible Items
    
    private func bind(items: [PaymentsParameterViewModel]) {
        
        for item in items {
            
            item.$value
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] value in
                    
                   reduce(value: value)
                    
                }.store(in: &itemsBindings)
            
            if let selectItem = item as? PaymentsSelectView.ViewModel,
                selectItem.value.current != nil {
                
                selectItem.action
                    .receive(on: DispatchQueue.main)
                    .sink {[unowned self] action in
                        
                        switch action {
                        case _ as PaymentsSelectView.ViewModelAction.SelectOptionExternal:
                            
                            guard let parameter = selectItem.source as? Payments.ParameterSelect,
                                    let selected = parameter.parameter.value else {
                                return
                            }
                            
                            let options = parameter.options.map{ Option(id: $0.id, name: $0.name)}
                            
                            self.action.send(PaymentsOperationViewModelAction.ShowPopUpSelectView(parameterId: parameter.parameter.id, title: parameter.title, description: nil, options: options, selected: selected))
                            
                        default:
                            break
                        }
                        
                    }.store(in: &itemsBindings)
            }
            
            if let simpleSelectItem = item as? PaymentsSelectSimpleView.ViewModel {
                
                simpleSelectItem.action
                    .receive(on: DispatchQueue.main)
                    .sink {[unowned self] action in
                        
                        switch action {
                        case _ as PaymentsSelectSimpleView.ViewModelAction.SelectOptionExternal:
                            
                            guard let parameter = simpleSelectItem.source as? Payments.ParameterSelectSimple else {
                                return
                            }
                            
                            let options = parameter.options.map{ Option(id: $0.id, name: $0.name)}
                            let selected = parameter.parameter.value
                            
                            self.action.send(PaymentsOperationViewModelAction.ShowPopUpSelectView(parameterId: parameter.parameter.id, title: parameter.title, description: parameter.description, options: options, selected: selected))
                            
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
                        
                        isAdditionalItemsCollapsed.value = selected

                    }.store(in: &itemsBindings)
            }
        }
        
        if case .amount(let amount) = footer {
            
            amount.$value
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] value in
                    
                   reduce(value: value)
                    
                }.store(in: &itemsBindings)
        }
    }
    
    //MARK: - Create Items
    
    func createItemsAndFooter(from parameters: [ParameterRepresentable]) {
        
        items.value = createItems(from: parameters)

        withAnimation {
      
            footer = createFooter(from: parameters)
        }
        
        updateFooter(isContinueEnabled: isItemsValuesValid())
    }
    
    func createItems(from parameters: [ParameterRepresentable]) -> [PaymentsParameterViewModel] {

        var result = [PaymentsParameterViewModel]()
        for parameter in parameters {

            switch parameter {
            case let parameterSelect as Payments.ParameterSelect:
                result.append(PaymentsSelectView.ViewModel(with: parameterSelect))
                
            case let parameterSwitch as Payments.ParameterSelectSwitch:
                result.append(PaymentsSwitchView.ViewModel(with: parameterSwitch))
                
            case let parameterInfo as Payments.ParameterInfo:
                result.append(PaymentsInfoView.ViewModel(with: parameterInfo))
                
            case let parameterInput as Payments.ParameterInput:
                result.append(PaymentsInputView.ViewModel(with: parameterInput))
                
            case let paremetrName as Payments.ParameterName:
                result.append(PaymentsNameView.ViewModel(with: paremetrName))
                
            case let parameterSelectSimple as Payments.ParameterSelectSimple:
                result.append(PaymentsSelectSimpleView.ViewModel(
                    with: parameterSelectSimple))
                
            case let parameterProduct as Payments.ParameterProduct:
                result.append(PaymentsProductView.ViewModel(parameterProduct: parameterProduct, model: model))
                
            default:
                continue
            }
        }
        
        return result
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

//MARK: - Conditions

extension PaymentsOperationViewModel {
    
    func isItemsValuesValid() -> Bool {
        
        for item in itemsAll {
            
            guard item.isValid == true else {
                return false
            }
        }
        
        return true
    }
    
    func isAutoContinueRequired(for parameterId: Payments.Parameter.ID) -> Bool {
        
        guard let parameterViewModel = items.value.first(where: { $0.id == parameterId}) else {
            return false
        }
 
        return parameterViewModel.source.isAutoContinue
    }
}

//MARK: - Reducers and Updates

extension PaymentsOperationViewModel {
    
    func reduce(value: PaymentsParameterViewModel.Value) {
        
        guard value.isChanged == true else {
            return
        }

        let results = self.itemsAll.map{ ($0.result, $0.source.affectsHistory) }
        let update = operation.update(with: results)
        
        switch update.type {
        case .normal:
            
            if isAutoContinueRequired(for: value.id) {
                
                action.send(PaymentsOperationViewModelAction.Continue())
                
            } else {
                
                operation = update.operation
                updateFooter(isContinueEnabled: isItemsValuesValid())
            }
            
        case .historyChanged:
            
            action.send(PaymentsOperationViewModelAction.Continue())
        }
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
}


//MARK: - Types

extension PaymentsOperationViewModel {
    
    struct HeaderViewModel {
        
        let title: String
        let backButtonIcon = Image("back_button")
        let action: () -> Void
    }
    
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

//MARK: - Action

enum PaymentsOperationViewModelAction {
    
    struct Continue: Action {}
    
    struct Confirm: Action {}

    struct ShowPopUpSelectView: Action {
        
        let parameterId: Payments.Parameter.ID
        let title: String
        let description: String?
        let options: [Option]
        let selected: Option.ID?
    }
    
    struct DismissConfirm: Action {}
}
