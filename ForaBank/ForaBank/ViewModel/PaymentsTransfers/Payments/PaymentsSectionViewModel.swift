//
//  PaymentsSectionViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 27.10.2022.
//

import SwiftUI
import Combine

class PaymentsSectionViewModel {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let placement: Payments.Parameter.Placement
    let groups: [PaymentsGroupViewModel]
    
    var items: [PaymentsParameterViewModel] { groups.flatMap({ $0.items }) }
    
    internal var bindings = Set<AnyCancellable>()
    
    init(
        placement: Payments.Parameter.Placement,
        groups: [PaymentsGroupViewModel]
    ) {
        self.placement = placement
        self.groups = groups
    }
    
    convenience init(
        placement: Payments.Parameter.Placement,
        items: [PaymentsParameterViewModel]
    ) {
        self.init(placement: placement, groups: Self.reduce(items: items))
        
        bind()
    }
    
    internal func bind() {
        
        action
            .compactMap { $0 as? PaymentsSectionViewModelAction.Button.EnabledChanged }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] payload in
                
                guard let self else { return }
                
                for item in items {
                    
                    switch item {
                    case let continuableItem as PaymentsParameterViewModelContinuable:
                        continuableItem.update(isContinueEnabled: payload.isEnabled)
                        
                    default:
                        continue
                    }
                }
            }
            .store(in: &bindings)
        
        for item in items {
            
            item.$value
                .receive(on: DispatchQueue.main)
                .sink { [weak self] value in
                    
                    self?.action.send(PaymentsSectionViewModelAction.ItemValueDidChanged(value: value))
                    
                }.store(in: &bindings)
            
            item.action
                .receive(on: DispatchQueue.main)
                .sink { [weak self] action in
                    
                    guard let self else { return }
                    
                    switch action {
                        
                        // MARK: SelectSimpleComponent
                    case let payload as PaymentsParameterViewModelAction.SelectSimple.PopUpSelector.Show:
                        self.action.send(PaymentsSectionViewModelAction.PopUpSelector.Show(viewModel: payload.viewModel))
                        
                    case _ as PaymentsParameterViewModelAction.SelectSimple.PopUpSelector.Close:
                        self.action.send(PaymentsSectionViewModelAction.PopUpSelector.Close())
                        
                        // MARK: CodeComponent
                    case _ as PaymentsParameterViewModelAction.Code.ResendButtonDidTapped:
                        self.action.send(PaymentsSectionViewModelAction.ResendCode())
                        
                        // MARK: InputPhoneComponent
                    case let payload as PaymentsParameterViewModelAction.InputPhone.ContactSelector.Show:
                        self.action.send(PaymentsSectionViewModelAction.ContactSelector.Show(viewModel: payload.viewModel))
                        
                    case _ as PaymentsParameterViewModelAction.InputPhone.ContactSelector.Close:
                        self.action.send(PaymentsSectionViewModelAction.ContactSelector.Close())
                        
                    case let payload as PaymentsParameterViewModelAction.Hint.Show:
                        self.action.send(PaymentsSectionViewModelAction.Hint.Show(viewModel: payload.viewModel))
                        
                    case _ as PaymentsParameterViewModelAction.Hint.Close:
                        self.action.send(PaymentsSectionViewModelAction.Hint.Close())
                        
                        // MARK: Bank List Component
                    case let payload as PaymentsParameterViewModelAction.SelectBank.ContactSelector.Show:
                        self.action.send(PaymentsSectionViewModelAction.BankSelector.Show(type: payload.type))
                        
                    case _ as PaymentsParameterViewModelAction.SelectBank.ContactSelector.Close:
                        self.action.send(PaymentsSectionViewModelAction.ContactSelector.Close())
                        
                        // MARK: Bottom
                        
                    case _ as PaymentsParameterViewModelAction.Amount.ContinueDidTapped:
                        self.action.send(PaymentsSectionViewModelAction.Button.DidTapped(action: .continue))
                        
                    case let payload as PaymentsParameterViewModelAction.Button.DidTapped:
                        self.action.send(PaymentsSectionViewModelAction.Button.DidTapped(action: payload.action))
                        
                        // MARK: - Success Options Buttons
                        
                    case let payload as PaymentsParameterViewModelAction.SuccessOptionButtons.ButtonDidTapped:
                        self.action.send(PaymentsSectionViewModelAction.OptionButtonDidTapped(option: payload.option))
                        
                    case let payload as PaymentsParameterViewModelAction.SuccessAdditionalButtons.ButtonDidTapped:
                        switch payload.option {
                        case .change:
                            self.action.send(PaymentsSectionViewModelAction.Button.DidTapped(action: .additionalChange))
                            
                        case .return:
                            self.action.send(PaymentsSectionViewModelAction.Button.DidTapped(action: .additionalReturn))
                        }
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

// MARK: - Reducers

extension PaymentsSectionViewModel {
    
    static func reduce(items: [PaymentsParameterViewModel]) -> [PaymentsGroupViewModel] {
        
        var order = [Payments.Parameter.Group]()
        var processed = [Payments.Parameter.Group: [PaymentsParameterViewModel]]()
        for item in items {
            
            if let group = item.source.group {
                
                if var groupItems = processed[group] {
                    
                    groupItems.append(item)
                    processed[group] = groupItems
                    
                } else {
                    
                    order.append(group)
                    processed[group] = [item]
                }
                
            } else {
                
                let group = Payments.Parameter.Group(id: UUID().uuidString, type: .regular)
                order.append(group)
                processed[group] = [item]
            }
        }
        
        var groups = [PaymentsGroupViewModel]()
        for group in order {
            
            guard let items = processed[group] else {
                continue
            }
            
            switch group.type {
            case .regular:
                groups.append(.init(id: group.id, items: items))
                
            case .spoiler:
                groups.append(PaymentsSpoilerGroupViewModel(id: group.id, items: items, isCollapsed: true))
                
            case .contact:
                groups.append(PaymentsContactGroupViewModel(id: group.id, items: items, isCollapsed: true))
                
            case .info:
                groups.append(PaymentsInfoGroupViewModel(id: group.id, items: items))
                
            }
        }
        
        return groups
    }
    
    static func reduce(operation: Payments.Operation, model: Model) -> [PaymentsSectionViewModel] {
        
        var result = [PaymentsSectionViewModel]()
        let visibleParameters = operation.visibleParameters
        
        for placement in Payments.Parameter.Placement.allCases {
            
            let items = Self.reduce(parameters: visibleParameters, placement: placement, model: model)
            
            switch placement {
            case .bottom:
                if items.isEmpty == false {
                    
                    result.append(PaymentsSectionViewModel(placement: placement, items: items))
                    
                } else {
                    
                    //TODO: move to Model side
                    let continueButtonParameter = Payments.ParameterButton(parameterId: Payments.Parameter.Identifier.continue.rawValue, title: "Продолжить", style: .primary, acton: .continue)
                    let continueButtonItem = PaymentsButtonView.ViewModel( continueButtonParameter)
                    result.append(PaymentsSectionViewModel(placement: placement, items: [continueButtonItem]))
                }
                
            default:
                guard items.isEmpty == false else {
                    continue
                }
                
                result.append(PaymentsSectionViewModel(placement: placement, items: items))
            }
        }
        
        return result
    }
    
    static func reduce(success: Payments.Success, model: Model) -> [PaymentsSectionViewModel] {
        
        var result = [PaymentsSectionViewModel]()

        for placement in Payments.Parameter.Placement.allCases {
            
            let items = Self.reduce(
                parameters: success.parameters,
                placement: placement,
                model: model
            )
            result.append(PaymentsSectionViewModel(placement: placement, items: items))
        }
        
        return result
    }
    
    static func reduce(parameters: [PaymentsParameterRepresentable], placement: Payments.Parameter.Placement, model: Model) -> [PaymentsParameterViewModel] {
        
        var result = [PaymentsParameterViewModel]()
        
        for parameter in parameters {
            
            guard parameter.placement == placement,
                  let parameterViewModel = Self.reduce(parameter: parameter, model: model) else {
                
                continue
            }
            
            result.append(parameterViewModel)
        }
        
        return result
    }
    
    //TODO: change optional return into throwable 
    static func reduce(parameter: PaymentsParameterRepresentable, model: Model) -> PaymentsParameterViewModel? {
        
        switch parameter {
        case let parameterSelect as Payments.ParameterSelect:
            return PaymentsSelectView.ViewModel(with: parameterSelect)
           
        case let parameterSelectBank as Payments.ParameterSelectBank:
            return try? PaymentsSelectBankView.ViewModel(with: parameterSelectBank, model: model)
        
        case let parameterSelectCountry as Payments.ParameterSelectCountry:
            return try? PaymentsSelectCountryView.ViewModel(with: parameterSelectCountry, model: model)
      
        case let parameterSwitch as Payments.ParameterSelectSwitch:
            return PaymentsSwitchView.ViewModel(with: parameterSwitch)
            
        case let parameterCheckBox as Payments.ParameterCheck:
            return try? PaymentsCheckView.ViewModel(with: parameterCheckBox)
            
        case let parameterInfo as Payments.ParameterInfo:
            return PaymentsInfoView.ViewModel(with: parameterInfo, model: model)
            
        case let parameterInput as Payments.ParameterInput:
            return PaymentsInputView.ViewModel(with: parameterInput)
            
        case let parameterInputPhone as Payments.ParameterInputPhone:
            return PaymentsInputPhoneView.ViewModel(with: parameterInputPhone, model: model)
            
        case let parameterName as Payments.ParameterName:
            return PaymentsNameView.ViewModel(with: parameterName)
            
        case let parameterDropDownList as Payments.ParameterSelectDropDownList:
            return try? PaymentSelectDropDownView.ViewModel(with: parameterDropDownList)

        case let parameterSelectSimple as Payments.ParameterSelectSimple:
            return PaymentsSelectSimpleView.ViewModel(with: parameterSelectSimple, model: model)
            
        case let parameterProduct as Payments.ParameterProduct:
            return PaymentsProductView.ViewModel(model, parameterProduct: parameterProduct)
            
        case let parameterProductTemplate as Payments.ParameterProductTemplate:
            return PaymentsProductTemplateView.ViewModel(model, parameter: parameterProductTemplate)
            
        case let parameterAmount as Payments.ParameterAmount:
            return PaymentsAmountView.ViewModel(with: parameterAmount, model: model)
            
        case let parameterCode as Payments.ParameterCode:
            return PaymentsCodeView.ViewModel(with: parameterCode)
            
        case let parameterHeader as Payments.ParameterHeader:
            return PaymentsHeaderViewComponent(source: parameterHeader)
            
        case let parameterMessage as Payments.ParameterMessage:
            return PaymentsMessageView.ViewModel(with: parameterMessage)
            
        case let parameterSubscriber as Payments.ParameterSubscriber:
            return PaymentsSubscriberView.ViewModel(with: parameterSubscriber, model: model)
            
        case let parameterSubscribe as Payments.ParameterSubscribe:
            return PaymentsSubscribeView.ViewModel(with: parameterSubscribe)
            
        case let parameterButton as Payments.ParameterButton:
            return PaymentsButtonView.ViewModel(parameterButton)
            
            // success
            
        case let successStatus as Payments.ParameterSuccessStatus:
            return PaymentsSuccessStatusView.ViewModel(successStatus)
            
        case let successText as Payments.ParameterSuccessText:
            return PaymentsSuccessTextView.ViewModel(successText)
            
        case let successIcon as Payments.ParameterSuccessIcon:
            return PaymentsSuccessIconView.ViewModel(successIcon)
            
        case let successOptionButtons as Payments.ParameterSuccessOptionButtons:
            return PaymentsSuccessOptionButtonsView.ViewModel(model, source: successOptionButtons)
            
        case let successLink as Payments.ParameterSuccessLink:
            return PaymentsSuccessLinkView.ViewModel(successLink)
            
        case let successAdditionalButtons as Payments.ParameterSuccessAdditionalButtons:
            return PaymentsSuccessAdditionalButtonsView.ViewModel(successAdditionalButtons)
            
        case let successTransferNumber as Payments.ParameterSuccessTransferNumber:
            return PaymentsSuccessTransferNumberView.ViewModel(successTransferNumber)
            
        case let successLogo as Payments.ParameterSuccessLogo:
            return try? PaymentsSuccessLogoView.ViewModel(successLogo)
            
        case let successOptions as Payments.ParameterSuccessOptions:
            return PaymentsSuccessOptionsView.ViewModel(successOptions)
            
        case let successService as Payments.ParameterSuccessService:
            return PaymentsSuccessServiceView.ViewModel(successService)
        
        default:
            return PaymentsParameterViewModel(source: parameter)
        }
    }
}

// MARK: - Action

enum PaymentsSectionViewModelAction {
    
    struct ItemValueDidChanged: Action {
        
        let value: PaymentsParameterViewModel.Value
    }
    
    enum Button {
        
        struct DidTapped: Action {
            
            let action: Payments.ParameterButton.Action
        }
        
        struct EnabledChanged: Action {
            
            let isEnabled: Bool
        }
    }

    enum PopUpSelector  {
        
        struct Show: Action {
            
            let viewModel: PaymentsPopUpSelectView.ViewModel
        }
        
        struct Close: Action {}
    }
    
    enum BankSelector  {
        
        struct Show: Action {
            
            let type: Payments.ParameterSelectBank.SelectAllOption.Kind
        }
        
        struct Close: Action {}
    }
    
    enum ContactSelector  {
        
        struct Show: Action {
            
            let viewModel: ContactsViewModel
        }
        
        struct Close: Action {}
    }
    
    enum Hint  {
        
        struct Show: Action {
            
            let viewModel: HintViewModel
        }
        
        struct Close: Action {}
    }
    
    struct ResendCode: Action {}
    
    struct OptionButtonDidTapped: Action {
        
        let option: Payments.ParameterSuccessOptionButtons.Option
    }
}
