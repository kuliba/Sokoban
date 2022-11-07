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
    @Published var top: [PaymentsParameterViewModel]?
    @Published var content: [PaymentsParameterViewModel]
    @Published var bottom: [PaymentsParameterViewModel]?
    
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var bottomSheet: BottomSheet?
        
    internal let operation: CurrentValueSubject<Payments.Operation, Never>
    internal let sections: CurrentValueSubject<[PaymentsSectionViewModel], Never> = .init([])
    internal let model: Model
    internal var bindings = Set<AnyCancellable>()
    
    var rootActions: PaymentsViewModel.RootActions?
    
    var items: [PaymentsParameterViewModel] { sections.value.flatMap{ $0.items } }
    var isItemsValuesValid: Bool { items.filter({ $0.isValid == false }).isEmpty }
    
    init(header: HeaderViewModel, top: [PaymentsParameterViewModel]?, content: [PaymentsParameterViewModel], bottom: [PaymentsParameterViewModel]?, link: Link?, bottomSheet: BottomSheet?, operation: Payments.Operation, model: Model) {
        
        self.header = header
        self.top = top
        self.content = content
        self.bottom = bottom
        self.link = link
        self.bottomSheet = bottomSheet
        self.operation = .init(operation)
        self.model = model
    }
    
    convenience init(operation: Payments.Operation, model: Model) {
        
        let header = HeaderViewModel(title: operation.service.name)

        self.init(header: header, top: [], content: [], bottom: [], link: nil, bottomSheet: nil, operation: operation, model: model)
        
        bind()
    }

    //MARK: Bind
    
    internal func bind() {
        
        bindOperation()
        bindModel()
        bindAction()
    }
    
    internal func bindOperation() {
        
        operation
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] operation in
                
                sections.value = PaymentsSectionViewModel.reduce(operation: operation, model: model)
                bind(sections: sections.value)
                
            }.store(in: &bindings)
        
        sections
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] sections in
                
                top = Self.reduceTopItems(sections: sections)
                content = Self.reduceContentItems(sections: sections)
                bottom = Self.reduceBottomItems(sections: sections)
                
                // update bottom section continue button
                updateBottomSection(isContinueEnabled: isItemsValuesValid)
                
            }.store(in: &bindings)
    }
    
    internal func bindModel() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Payment.Process.Response:
                    rootActions?.spinner.hide()
                    switch payload.result {
                    case .step(let operation):
                        self.operation.value = operation
                        
                    case .confirm(let operation):
                        let confirmViewModel = PaymentsConfirmViewModel(operation: operation, model: model)
                        confirmViewModel.rootActions = rootActions
                        link = .confirm(confirmViewModel)
                        
                        // complete and failed handled on PaymentsViewModel side
                    default:
                        break
                    }

                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    internal func bindAction() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as PaymentsOperationViewModelAction.ItemDidUpdated:
                    // update operation with parameters
                    let updatedOperation = Self.reduce(operation: operation.value, items: items)
                    
                    // check if auto continue required
                    if model.paymentsIsAutoContinueRequired(operation: updatedOperation, updated: payload.parameterId) == true {
                        
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "Continue operation: \(updatedOperation)")
                        
                        // auto continue operation
                        model.action.send(ModelAction.Payment.Process.Request(operation: updatedOperation))
                        rootActions?.spinner.show()
                        
                    } else {
                        
                        // update dependend items
                        Self.reduce(items: items, dependenceReducer: model.paymentsProcessDependencyReducer(parameterId:parameters:))
                        
                        top = Self.reduceTopItems(sections: sections.value)
                        content = Self.reduceContentItems(sections: sections.value)
                        bottom = Self.reduceBottomItems(sections: sections.value)
                        
                        // update bottom section continue button
                        updateBottomSection(isContinueEnabled: isItemsValuesValid)
                    }
                    
                case _ as PaymentsOperationViewModelAction.Continue:
                    // update operation with parameters
                    let updatedOperation = Self.reduce(operation: operation.value, items: items)
                    
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "Continue operation: \(updatedOperation)")
                    
                    // continue operation
                    model.action.send(ModelAction.Payment.Process.Request(operation: updatedOperation))
                    rootActions?.spinner.show()
                    
                case _ as PaymentsOperationViewModelAction.CloseLink:
                    link = nil
                    
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
                        guard payload.value.isChanged == true else {
                            return
                        }
                        self.action.send(PaymentsOperationViewModelAction.ItemDidUpdated(parameterId: payload.value.id))
                        
                    case _ as PaymentsSectionViewModelAction.Continue:
                        self.action.send(PaymentsOperationViewModelAction.Continue())
 
                    case let payload as PaymentsSectionViewModelAction.PopUpSelector.Show:
                        bottomSheet = .init(type: .popUp(payload.viewModel))
                        
                    case _ as PaymentsSectionViewModelAction.PopUpSelector.Close:
                        withAnimation {
                            bottomSheet = nil
                        }
                        
                    case _ as PaymentsSectionViewModelAction.SpoilerDidUpdated:
                        content = Self.reduceContentItems(sections: sections)
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

//MARK: - Sections Reducers

extension PaymentsOperationViewModel {
    
    static func reduceTopItems(sections: [PaymentsSectionViewModel]) -> [PaymentsParameterViewModel]? {
        
        guard let topSection = sections.first(where: { $0.placement == .top }) else {
            return nil
        }
        
        return topSection.visibleItems
    }
    
    static func reduceContentItems(sections: [PaymentsSectionViewModel]) -> [PaymentsParameterViewModel] {

        if let fullScreenItem = reduceFullScreenItem(sections: sections) {
            
            return [fullScreenItem]
            
        } else {
            
            let contentSections = sections.filter({ $0.placement == .feed || $0.placement == .spoiler })
            
            return contentSections.flatMap{ $0.visibleItems }
        }
    }
    
    static func reduceBottomItems(sections: [PaymentsSectionViewModel]) -> [PaymentsParameterViewModel]? {
        
        guard reduceFullScreenItem(sections: sections) == nil else {
            return nil
        }
        
        guard let bottomSection = sections.first(where: { $0.placement == .bottom }) else {
            return nil
        }
        
        return bottomSection.visibleItems
    }
    
    static func reduceFullScreenItem(sections: [PaymentsSectionViewModel]) -> PaymentsParameterViewModel? {
        
        let feedSections = sections.filter({ $0.placement == .feed })
        guard let fullScreenItem = feedSections.compactMap({ $0.fullScreenItem }).first else {
            return nil
        }
        
        return fullScreenItem
    }
}

//MARK: - Reducers

extension PaymentsOperationViewModel {
    
    static func reduce(operation: Payments.Operation, items: [PaymentsParameterViewModel]) -> Payments.Operation {
        
        let parameters = items.map{ $0.result }
        let updatedOperation = operation.updated(with: parameters)
        
        return updatedOperation
    }
    
    static func reduce(items: [PaymentsParameterViewModel], dependenceReducer: (Payments.Parameter.ID, [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable?) {
        
        let parameters = items.map{ $0.source }
        for item in items {
            
            guard let updatedParameter = dependenceReducer(item.id, parameters) else {
                continue
            }
            
            item.update(source: updatedParameter)
        }
    }
}

//MARK: - Helpers

extension PaymentsOperationViewModel {
        
    func updateBottomSection(isContinueEnabled: Bool) {
        
        guard let bottomSection = sections.value.first(where: { $0.placement == .bottom }) as? PaymentsBottomSectionViewModel else {
            return
        }
        
        bottomSection.isContinueEnabled.value = isContinueEnabled
    }
}

//MARK: - Types

extension PaymentsOperationViewModel {
    
    struct HeaderViewModel {
        
        let title: String
        let backButtonIcon = Image("back_button")
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
    
    struct ItemDidUpdated: Action {
        
        let parameterId: Payments.Parameter.ID
    }
    
    struct Continue: Action {}
    
    struct ShowPopUpSelectView: Action {
        
        let viewModel: PaymentsPopUpSelectView.ViewModel
    }
    
    struct CloseLink: Action {}
}
