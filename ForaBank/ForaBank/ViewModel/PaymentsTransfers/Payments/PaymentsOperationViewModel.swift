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
    @Published var sections: [PaymentsSectionViewModel]
    
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var bottomSheet: BottomSheet?
        
    internal var operation: Payments.Operation
    internal let model: Model
    internal var bindings = Set<AnyCancellable>()
    
    var topSection: PaymentsTopSectionViewModel? {
        sections.first(where: { $0.placement == .top }) as? PaymentsTopSectionViewModel
    }
    
    var contentSections: [PaymentsSectionViewModel] {
        sections.filter({ $0.placement == .feed || $0.placement == .spoiler })
    }
    
    var bottomSection: PaymentsBottomSectionViewModel? {
        sections.first(where: { $0.placement == .bottom }) as? PaymentsBottomSectionViewModel
    }
    var items: [PaymentsParameterViewModel] { sections.flatMap{ $0.items } }
    
    init(header: HeaderViewModel, sections: [PaymentsSectionViewModel], link: Link?, bottomSheet: BottomSheet?, operation: Payments.Operation, model: Model) {
        
        self.header = header
        self.sections = sections
        self.link = link
        self.bottomSheet = bottomSheet
        self.operation = operation
        self.model = model
    }
    
    convenience init(operation: Payments.Operation, model: Model) {
        
        let header = HeaderViewModel(title: operation.service.name)
        let sections = PaymentsSectionViewModel.reduce(operation: operation, model: model)
        
        self.init(header: header, sections: sections, link: nil, bottomSheet: nil, operation: operation, model: model)

        bind()
    }
    
    //MARK: Bind
    
    internal func bind() {
        
        bind(model: model)
        bindAction()
        bind(sections: sections)
    }
    
    //MARK: Bind Model
    
    internal func bind(model: Model) {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Payment.Process.Response:
                    self.action.send(PaymentsOperationViewModelAction.Spinner.Hide())
                    switch payload.result {
                    case .step(let operation):
                        createItemsAndFooter(from: operation.parameters)
                        self.operation = operation
                        
                    case .confirm(let operation):
                        /*
                        confirmViewModel = PaymentsConfirmViewModel(model, operation: operation)
                        isConfirmViewActive = true
                         */
                        //TODO: refactor
//                        self.operation = self.operation.finalized()
                        
                        break
                        
                    default:
                        break
                    }
                    
                case let payload as ModelAction.Auth.VerificationCode.PushRecieved:
                    guard let codeParameter = items.first(where: { $0.id == Payments.Parameter.Identifier.code.rawValue }) as? PaymentsInputView.ViewModel else {
                        return
                    }
                    
                    codeParameter.content = payload.code

                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    //MARK: Bind Sections
    
    internal func bind(sections: [PaymentsSectionViewModel]) {
        
        for section in sections {
            
            section.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as PaymentsSectionViewModelAction.ItemValueDidChanged:
                        reduce(value: payload.value)
                        
                    case _ as PaymentsSectionViewModelAction.Continue:
                        break
                        
                    case let payload as PaymentsSectionViewModelAction.ShowPopUpSelectView:
                        bottomSheet = .init(type: .popUp(payload.viewModel))
                       
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
        }
    }
    
    //MARK: Bind Action
    
    internal func bindAction() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsOperationViewModelAction.Continue:
                    //FIXME: refactor
                    break
                    /*
                    let results = itemsAll.map{ ($0.result, $0.source.affectsHistory) }
                    let update = operation.update(with: results)
                    model.action.send(ModelAction.Payment.Continue.Request(operation: update.operation))
                    rootActions.spinner.show()
                     */
                    
                case _ as PaymentsOperationViewModelAction.Confirm:
                    //FIXME: refactor
                    break
                    /*
                    let results = itemsAll.map{ ($0.result, $0.source.affectsHistory) }
                    let update = operation.update(with: results)
                    model.action.send(ModelAction.Payment.Complete.Request(operation: update.operation))
                    rootActions.spinner.show()
                     */
                    
                case _ as PaymentsOperationViewModelAction.DismissConfirm:
//                    isConfirmViewActive = false
//                    confirmViewModel = nil
                    break
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }

    //MARK: - Create Items
    
    func createItemsAndFooter(from parameters: [PaymentsParameterRepresentable]) {
        /*
        items.value = createItems(from: parameters)

        withAnimation {
      
            footer = createFooter(from: parameters)
        }
         */
        
        updateFooter(isContinueEnabled: isItemsValuesValid())
    }

    func createFooter(from parameters: [PaymentsParameterRepresentable]) -> FooterViewModel? {

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
                footer = .amount(.init(with: parameterAmount,actionTitle: "Перевести"))
                
                                
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

        for item in items {
            
            guard item.isValid == true else {
                return false
            }
        }
        
        return true
    }
    
    func isAutoContinueRequired(for parameterId: Payments.Parameter.ID) -> Bool {
        
        return false
        //TODO: refactor
        /*
        guard let parameterViewModel = items.value.first(where: { $0.id == parameterId}) else {
            return false
        }
 
        return parameterViewModel.source.onChange == .autoContinue
         */
    }
}

//MARK: - Reducers and Updates

extension PaymentsOperationViewModel {
    
    func reduce(value: PaymentsParameterViewModel.Value) {
        
        guard value.isChanged == true else {
            return
        }

        //FIXME: refactor
        return
        /*
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
         */
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
        
        /*
        guard let footer = footer else { return }

        switch footer {
        case .button(let continueButtonViewModel):
            continueButtonViewModel.isEnabled = isContinueEnabled
            self.footer = .button(continueButtonViewModel)
            
        case .amount(let amountViewModel):
            amountViewModel.updateTranferButton(isEnabled: isContinueEnabled)
            self.footer = .amount(amountViewModel)
        }
         */
    }
}


//MARK: - Types

extension PaymentsOperationViewModel {
    
    struct HeaderViewModel {
        
        let title: String
        let backButtonIcon = Image("back_button")
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
    
    enum Link {
        
        case confirm(PaymentsConfirmViewModel)
    }
    
    struct BottomSheet: Identifiable {

        let id = UUID()
        let type: BottomSheetType

        enum BottomSheetType {

            case popUp(PaymentsPopUpSelectView.ViewModel)
        }
    }
}

//MARK: - Action

enum PaymentsOperationViewModelAction {
    
    struct Continue: Action {}
    
    struct Confirm: Action {}

    struct ShowPopUpSelectView: Action {
        
        let viewModel: PaymentsPopUpSelectView.ViewModel
    }
    
    struct DismissConfirm: Action {}
    
    struct Dismiss: Action {}
    
    enum Spinner {
        
        struct Show: Action {}
        struct Hide: Action {}
    }
    
    struct Alert: Action {
        
        let message: String
    }
}
