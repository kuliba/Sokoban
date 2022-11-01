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
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.Payment.Process.Response:
                    self.action.send(PaymentsOperationViewModelAction.Spinner.Hide())
                    switch payload.result {
                    case .step(let operation):
                        self.operation.value = operation
                        
                    case .confirm(let operation):
                        //TODO: confirm view model
                        break
                        
                        // complete and failed handled on PaymentsViewModel side
                    default:
                        break
                    }
                    
                case let payload as ModelAction.Auth.VerificationCode.PushRecieved:
                    updateFeedSection(code: payload.code)

                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as PaymentsOperationViewModelAction.ItemDidUpdated:
                    // update operation with parameters
                    let updatedOperation = Self.reduce(operation: operation.value, items: items)
                    
                    // check if auto continue required
                    if updatedOperation.isAutoContinueRequired == true {
                        
                        // auto continue operation
                        model.action.send(ModelAction.Payment.Process.Request(operation: updatedOperation))
                        
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
                    
                    // continue operation
                    model.action.send(ModelAction.Payment.Process.Request(operation: updatedOperation))
                    
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
                        self.action.send(PaymentsOperationViewModelAction.ItemDidUpdated())
                        
                    case _ as PaymentsSectionViewModelAction.Continue:
                        self.action.send(PaymentsOperationViewModelAction.Continue())
 
                    case let payload as PaymentsSectionViewModelAction.ShowPopUpSelectView:
                        bottomSheet = .init(type: .popUp(payload.viewModel))
                       
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
            return []
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
    
    func updateFeedSection(code: String) {
        
        guard let codeParameter = items.first(where: { $0.id == Payments.Parameter.Identifier.code.rawValue }) as? PaymentsInputView.ViewModel else {
            return
        }
        
        codeParameter.content = code
    }
    
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
    
    struct ItemDidUpdated: Action {}
    
    struct Continue: Action {}
    
    struct ShowPopUpSelectView: Action {
        
        let viewModel: PaymentsPopUpSelectView.ViewModel
    }
    
    struct CloseLink: Action {}
    
    struct Dismiss: Action {}
    
    enum Spinner {
        
        struct Show: Action {}
        struct Hide: Action {}
    }
    
    struct Alert: Action {
        
        let message: String
    }
}
