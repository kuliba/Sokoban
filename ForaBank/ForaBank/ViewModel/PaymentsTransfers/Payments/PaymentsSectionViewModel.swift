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
    
    var placement: Payments.Parameter.Placement { fatalError("Implement in subclass") }
    var items: [PaymentsParameterViewModel]
    var visibleItems: [PaymentsParameterViewModel] { items }
    var fullScreenItem: PaymentsParameterViewModel? { nil }
    
    internal var bindings = Set<AnyCancellable>()
    
    init(items: [PaymentsParameterViewModel]) {
        
        self.items = items
        
        bind()
    }
    
    internal func bind() {
        
        for item in items {
            
            item.$value
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] value in
                    
                    action.send(PaymentsSectionViewModelAction.ItemValueDidChanged(value: value))
                    
                }.store(in: &bindings)
        }
    }
}

class PaymentsTopSectionViewModel: PaymentsSectionViewModel {
    
    override var placement: Payments.Parameter.Placement { .top }
}

class PaymentsFeedSectionViewModel: PaymentsSectionViewModel {
    
    override var placement: Payments.Parameter.Placement { .feed }
        
    override var fullScreenItem: PaymentsParameterViewModel? {
        
        items.first(where: { $0.isFullContent == true })
    }
    
    override func bind() {
        
        super.bind()
        
        for item in items {
            
            item.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as PaymentsParameterViewModelAction.Select.OptionExternal:
                        self.action.send(PaymentsSectionViewModelAction.ShowPopUpSelectView(viewModel: payload.viewModel))
                        
                    case let payload as PaymentsParameterViewModelAction.SelectSimple.OptionExternal:
                        self.action.send(PaymentsSectionViewModelAction.ShowPopUpSelectView(viewModel: payload.viewModel))
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

class PaymentsSpoilerSectionViewModel: PaymentsSectionViewModel {
    
    override var placement: Payments.Parameter.Placement { .spoiler }
    var isCollapsed: Bool
    override var visibleItems: [PaymentsParameterViewModel] {
        
        if isCollapsed == true {
            
            guard let buttonItem = items.first(where: { $0 is PaymentsButtonAdditionalView.ViewModel }) else {
                return []
            }
            
            return [buttonItem]
            
        } else {
            
            return items
        }
    }
    
    init(items: [PaymentsParameterViewModel], isCollapsed: Bool) {
        
        self.isCollapsed = isCollapsed
        
        var itemsUpdated = items
        itemsUpdated.append(PaymentsButtonAdditionalView.ViewModel(title: "Дополнительные данные", isSelected: isCollapsed))
        super.init(items: itemsUpdated)
    }
    
    override func bind() {
        
        super.bind()
        
        for item in items {
            
            item.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as PaymentsParameterViewModelAction.SpoilerButton.DidUpdated:
                        isCollapsed = payload.isCollapsed
                        
                    default:
                        break
                    }
    
                }.store(in: &bindings)
        }
    }
}

class PaymentsBottomSectionViewModel: PaymentsSectionViewModel, ObservableObject {
    
    override var placement: Payments.Parameter.Placement { .bottom }
    let isContinueEnabled: CurrentValueSubject<Bool, Never> = .init(false)

    override func bind() {
        
        super.bind()
        
        isContinueEnabled
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isContinueEnabled in
                
                for item in items {
                    
                    switch item {
                    case let continuableItem as PaymentsParameterViewModelContinuable:
                        continuableItem.update(isContinueEnabled: isContinueEnabled)
                        
                    default:
                        continue
                    }
                }
            }.store(in: &bindings)
        
        for item in items {
            
            item.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as PaymentsParameterViewModelAction.Amount.ContinueDidTapped:
                        self.action.send(PaymentsSectionViewModelAction.Continue())
                        
                    case _ as PaymentsParameterViewModelAction.ContinueButton.DidTapped:
                        self.action.send(PaymentsSectionViewModelAction.Continue())
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

//MARK: - Reducers

extension PaymentsSectionViewModel {
    
    static func reduce(operation: Payments.Operation, model: Model) -> [PaymentsSectionViewModel] {
        
        var result = [PaymentsSectionViewModel]()
        
        for placement in Payments.Parameter.Placement.allCases {
            
            let items = Self.reduce(parameters: operation.parameters, placement: placement, visible: operation.visibleParametersIds, model: model)
            
            switch placement {
            case .top:
                guard items.isEmpty == false else {
                    continue
                }
                result.append(PaymentsTopSectionViewModel(items: items))
                
            case .spoiler:
                if items.isEmpty == false,
                   let lastSpoilerItem = items.last,
                   let lastIndex = operation.parameters.firstIndex(where: { $0.id == lastSpoilerItem.id }) {
                    
                    // feed section before spoiler
                    let prevParameters = Array(operation.parameters.prefix(lastIndex))
                    let prevFeedItems = Self.reduce(parameters: prevParameters, placement: .feed, visible: operation.visibleParametersIds, model: model)
                    if prevFeedItems.isEmpty == false {
                        
                        result.append(PaymentsFeedSectionViewModel(items: prevFeedItems))
                    }
                    
                    // spoiler section
                    result.append(PaymentsSpoilerSectionViewModel(items: items, isCollapsed: true))
                    
                    // feed section after spoiler
                    let postParameters = Array(operation.parameters.suffix(operation.parameters.count - lastIndex))
                    let postFeedItems = Self.reduce(parameters: postParameters, placement: .feed, visible: operation.visibleParametersIds, model: model)
                    if postFeedItems.isEmpty == false {
                        
                        result.append(PaymentsFeedSectionViewModel(items: postFeedItems))
                    }
                    
                } else {
                    
                    // feed section
                    let feedItems = Self.reduce(parameters: operation.parameters, placement: .feed, visible: operation.visibleParametersIds, model: model)
                    result.append(PaymentsFeedSectionViewModel(items: feedItems))
                }
                
            case .bottom:
                if items.isEmpty == false {
                    
                    result.append(PaymentsBottomSectionViewModel(items: items))
                    
                } else {
                    
                    let continueButtonItem = PaymentsContinueButtonView.ViewModel(title: "Продолжить")
                    result.append(PaymentsBottomSectionViewModel(items: [continueButtonItem]))
                }
                
            default:
                continue
            }
        }
        
        return result
    }
    
    static func reduce(parameters: [PaymentsParameterRepresentable], placement: Payments.Parameter.Placement, visible: [Payments.Parameter.ID], model: Model) -> [PaymentsParameterViewModel] {
        
        var result = [PaymentsParameterViewModel]()
        
        for parameter in parameters {
            
            guard parameter.placement == placement,
                  visible.contains(parameter.id),
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
            
        case let parameterSwitch as Payments.ParameterSelectSwitch:
            return PaymentsSwitchView.ViewModel(with: parameterSwitch)
            
        case let parameterInfo as Payments.ParameterInfo:
            return PaymentsInfoView.ViewModel(with: parameterInfo)
            
        case let parameterInput as Payments.ParameterInput:
            return PaymentsInputView.ViewModel(with: parameterInput)
            
        case let paremetrName as Payments.ParameterName:
            return PaymentsNameView.ViewModel(with: paremetrName)
            
        case let parameterSelectSimple as Payments.ParameterSelectSimple:
            return PaymentsSelectSimpleView.ViewModel(with: parameterSelectSimple)
            
        case let parameterProduct as Payments.ParameterProduct:
            return PaymentsProductView.ViewModel(parameterProduct: parameterProduct, model: model)
            
        case let parameterAmount as Payments.ParameterAmount:
            return PaymentsAmountView.ViewModel(with: parameterAmount, actionTitle: "Продолжить")
        
            // for tests only
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
    
    struct Continue: Action {}
    
    struct ShowPopUpSelectView: Action {
        
        let viewModel: PaymentsPopUpSelectView.ViewModel
    }
}
