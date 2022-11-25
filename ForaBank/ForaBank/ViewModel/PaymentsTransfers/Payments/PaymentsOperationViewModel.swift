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
    @Published var sheet: Sheet?
        
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
        
        let header = HeaderViewModel(with: operation)

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
                
                // update parameter value callback for each item
                updateParameterValueCallback(items: items)
                
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
                        Self.reduce(service: operation.value.service, items: items, dependenceReducer: model.paymentsProcessDependencyReducer(service:parameterId:parameters:))
                        
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
                    
                case _ as PaymentsOperationViewModelAction.IcorrectCodeEnterred:
                    guard case .confirm(let confirmViewModel) = link else {
                        return
                    }
                    confirmViewModel.action.send(PaymentsConfirmViewModelAction.IcorrectCodeEnterred())
                    
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
                        guard payload.value.isChanged == true || payload.value.id == Payments.Parameter.Identifier.product.rawValue else {
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
                        
                    case let payload as PaymentsSectionViewModelAction.BankSelector.Show:
                        sheet = .init(type: .contacts(payload.viewModel))
                        
                    case _ as PaymentsSectionViewModelAction.BankSelector.Close:
                        sheet = nil
                        
                    case let payload as PaymentsSectionViewModelAction.ContactSelector.Show:
                        sheet = .init(type: .contacts(payload.viewModel))
                        
                    case _ as PaymentsSectionViewModelAction.ContactSelector.Close:
                        sheet = nil
                        
                    case _ as PaymentsSectionViewModelAction.SpoilerDidUpdated:
                        content = Self.reduceContentItems(sections: sections)
                        
                    case _ as PaymentsSectionViewModelAction.ResendCode:
                        self.model.action.send(ModelAction.Transfers.ResendCode.Request())
                        
                    case let payload as PaymentsSectionViewModelAction.InputActionButtonDidTapped:
                        print("InputActionButtonDidTapped type: \(payload.type)")
                        
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
    
    static func reduce(service: Payments.Service, items: [PaymentsParameterViewModel], dependenceReducer: (Payments.Service, Payments.Parameter.ID, [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable?) {
        
        let parameters = items.map{ $0.source.updated(value: $0.value.current) }
        for item in items {
            
            guard let updatedParameter = dependenceReducer(service, item.id, parameters) else {
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
    
    func updateParameterValueCallback(items: [PaymentsParameterViewModel]) {
        
        let results = items.map{ $0.result }
        for item in items {
            
            item.parameterValue = {  parameterId in
                
                results.first(where: { $0.id == parameterId })?.value
            }
        }
    }
}

//MARK: - Types

extension PaymentsOperationViewModel {
    
    struct HeaderViewModel {

        let title: String
        let icon: Image?
        let backButtonIcon = Image("back_button")
        
        init(title: String, icon: Image? = nil) {
            
            self.title = title
            self.icon = icon
        }
        
        init(with operation: Payments.Operation) {
            
            if let headerParameter = operation.parameters.first(where: { $0.id == Payments.Parameter.Identifier.header.rawValue}) as? Payments.ParameterHeader,
               let icon = headerParameter.icon {
                
                switch icon {
                case let .image(imageData):
                    self.init(title: headerParameter.title, icon: imageData.image)
                    
                case let .name(imageName):
                    self.init(title: headerParameter.title, icon: Image(imageName))
                }
                
            } else {
                
                self.init(title: "", icon: nil)
            }
        }
    }
        
    enum Link {
        
        case confirm(PaymentsConfirmViewModel)
    }
    
    struct BottomSheet: Identifiable, BottomSheetCustomizable {

        let id = UUID()
        let type: BottomSheetType

        enum BottomSheetType {

            case popUp(PaymentsPopUpSelectView.ViewModel)
        }
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case contacts(ContactsViewModel)
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
    
    struct IcorrectCodeEnterred: Action {}
}
