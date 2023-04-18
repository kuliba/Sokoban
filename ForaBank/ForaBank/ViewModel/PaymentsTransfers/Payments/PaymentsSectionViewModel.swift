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
    
    init(placement: Payments.Parameter.Placement, groups: [PaymentsGroupViewModel]) {
        
        self.placement = placement
        self.groups = groups
    }
    
    convenience init(placement: Payments.Parameter.Placement, items: [PaymentsParameterViewModel]) {
        
        self.init(placement: placement, groups: Self.reduce(items: items))
        
        bind()
    }
    
    internal func bind() {
        
        action
            .compactMap{ $0 as? PaymentsSectionViewModelAction.Continue.EnabledChanged }
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] payload in
                
                for item in items {
                    
                    switch item {
                    case let continuableItem as PaymentsParameterViewModelContinuable:
                        continuableItem.update(isContinueEnabled: payload.isEnabled)
                        
                    default:
                        continue
                    }
                }
            
            }.store(in: &bindings)
        
        for item in items {
            
            item.$value
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] value in
                    
                    action.send(PaymentsSectionViewModelAction.ItemValueDidChanged(value: value))
                    
                }.store(in: &bindings)
            
            item.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                        
                    //MARK: SelectSimpleComponent
                    case let payload as PaymentsParameterViewModelAction.SelectSimple.PopUpSelector.Show:
                        self.action.send(PaymentsSectionViewModelAction.PopUpSelector.Show(viewModel: payload.viewModel))
                        
                    case _ as PaymentsParameterViewModelAction.SelectSimple.PopUpSelector.Close:
                        self.action.send(PaymentsSectionViewModelAction.PopUpSelector.Close())
                        
                    //MARK: CodeComponent
                    case _ as PaymentsParameterViewModelAction.Code.ResendButtonDidTapped:
                        self.action.send(PaymentsSectionViewModelAction.ResendCode())
                    
                    //MARK: InputPhoneComponent
                    case let payload as PaymentsParameterViewModelAction.InputPhone.ContactSelector.Show:
                        self.action.send(PaymentsSectionViewModelAction.ContactSelector.Show(viewModel: payload.viewModel))
                        
                    case _ as PaymentsParameterViewModelAction.InputPhone.ContactSelector.Close:
                        self.action.send(PaymentsSectionViewModelAction.ContactSelector.Close())
                    
                    case let payload as PaymentsParameterViewModelAction.Hint.Show:
                        self.action.send(PaymentsSectionViewModelAction.Hint.Show(viewModel: payload.viewModel))
                        
                    case _ as PaymentsParameterViewModelAction.Hint.Close:
                        self.action.send(PaymentsSectionViewModelAction.Hint.Close())
                        
                    //MARK: Bank List Component
                    case let payload as PaymentsParameterViewModelAction.BankList.ContactSelector.Show:
                        self.action.send(PaymentsSectionViewModelAction.BankSelector.Show(viewModel: payload.viewModel))
                        
                    case _ as PaymentsParameterViewModelAction.BankList.ContactSelector.Close:
                        self.action.send(PaymentsSectionViewModelAction.ContactSelector.Close())

                        //MARK: Bottom
                        
                    case _ as PaymentsParameterViewModelAction.Amount.ContinueDidTapped:
                        self.action.send(PaymentsSectionViewModelAction.Continue.DidTapped())
                        
                    case _ as PaymentsParameterViewModelAction.ContinueButton.DidTapped:
                        self.action.send(PaymentsSectionViewModelAction.Continue.DidTapped())
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

//MARK: - Reducers

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
                groups.append(PaymentsContactGroupViewModel(items: items))

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
                    let continueParameter = Payments.ParameterContinue(title: "Продолжить")
                    let continueButtonItem = PaymentsContinueButtonView.ViewModel(continueParameter: continueParameter)
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
            return PaymentsInfoView.ViewModel(with: parameterInfo)
            
        case let parameterInput as Payments.ParameterInput:
            return PaymentsInputView.ViewModel(with: parameterInput)
            
        case let parameterInputPhone as Payments.ParameterInputPhone:
            return PaymentsInputPhoneView.ViewModel(with: parameterInputPhone, model: model)
            
        case let paremeterName as Payments.ParameterName:
            return PaymentsNameView.ViewModel(with: paremeterName)
            
        case let parameterDropDownList as Payments.ParameterSelectDropDownList:
            return PaymentSelectDropDownView.ViewModel(with: parameterDropDownList)

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
        
            // for tests only
        case let parameterHidden as Payments.ParameterHidden:
            return PaymentsParameterViewModel(source: parameterHidden)

        case let parameterMock as Payments.ParameterMock:
            return PaymentsParameterViewModel(source: parameterMock)
            
        default:
            return nil
        }
    }
}

//MARK: - Action

enum PaymentsSectionViewModelAction {
    
    struct ItemValueDidChanged: Action {
        
        let value: PaymentsParameterViewModel.Value
    }
    
    enum Continue {
        
        struct DidTapped: Action {}
        
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
            
            let viewModel: ContactsViewModel
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
}
