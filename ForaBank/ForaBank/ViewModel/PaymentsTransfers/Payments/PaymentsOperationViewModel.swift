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

    @Published var navigationBar: NavigationBarView.ViewModel
    @Published var top: [PaymentsParameterViewModel]?
    @Published var content: [PaymentsParameterViewModel]
    @Published var bottom: [PaymentsParameterViewModel]?
    
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    @Published var isLinkActive: Bool = false
    @Published var bottomSheet: BottomSheet?
    @Published var sheet: Sheet?
    @Published var spinner: SpinnerView.ViewModel?
        
    internal let closeAction: () -> Void
    internal let operation: CurrentValueSubject<Payments.Operation, Never>
    internal let sections: CurrentValueSubject<[PaymentsSectionViewModel], Never> = .init([])
    internal let model: Model
    internal var bindings = Set<AnyCancellable>()
    
    var rootActions: PaymentsViewModel.RootActions?
    
    var items: [PaymentsParameterViewModel] { sections.value.flatMap{ $0.items } }
    var isItemsValuesValid: Bool { items.filter({ $0.isValid == false }).isEmpty }
    
    init(navigationBar: NavigationBarView.ViewModel, top: [PaymentsParameterViewModel]?, content: [PaymentsParameterViewModel], bottom: [PaymentsParameterViewModel]?, link: Link?, bottomSheet: BottomSheet?, operation: Payments.Operation, model: Model, closeAction: @escaping () -> Void) {
        
        self.navigationBar = navigationBar
        self.top = top
        self.content = content
        self.bottom = bottom
        self.link = link
        self.bottomSheet = bottomSheet
        self.operation = .init(operation)
        self.model = model
        self.closeAction = closeAction
    }
    
    convenience init(navigationBar: NavigationBarView.ViewModel = .init(), operation: Payments.Operation, model: Model, closeAction: @escaping () -> Void) {

        self.init(navigationBar: navigationBar, top: [], content: [], bottom: [], link: nil, bottomSheet: nil, operation: operation, model: model, closeAction: closeAction)
        
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
                
                // update dependend items
                Self.reduce(service: operation.value.service, items: items, dependenceReducer: model.paymentsProcessDependencyReducer(service:parameterId:parameters:))
                
                navigationBar = .init(with: items.map{ $0.source }, closeAction: closeAction)
                
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
                    
                    self.action.send(PaymentsOperationViewModelAction.Spinner.Hide())
                   
                    switch payload.result {
                    case .step(let operation):
                        self.operation.value = operation
                        
                    case .confirm(let operation):
                        let confirmViewModel = PaymentsConfirmViewModel(operation: operation, model: model) { [weak self] in
                            
                            self?.link = nil
                        }
                        confirmViewModel.rootActions = rootActions
                        bind(confirmViewModel: confirmViewModel)
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
                    if isParameterValueValid(parameterId: payload.parameterId),
                       model.paymentsIsAutoContinueRequired(operation: updatedOperation, updated: payload.parameterId) == true {
                        
                        // update stage
                        let updatedStageOperation = updatedOperation.updatedCurrentStepStage(reducer: model.paymentsProcessCurrentStepStageReducer(service:parameters:stepIndex:stepStage:))
                        
                        LoggerAgent.shared.log(level: .debug, category: .ui, message: "Continue operation: \(updatedStageOperation)")
                        
                        // auto continue operation
                        model.action.send(ModelAction.Payment.Process.Request(operation: updatedStageOperation))
                        self.action.send(PaymentsOperationViewModelAction.Spinner.Show())
                        
                    } else {
                        
                        // update dependend items
                        Self.reduce(service: operation.value.service, items: items, dependenceReducer: model.paymentsProcessDependencyReducer(service:parameterId:parameters:))
                        
                        navigationBar = .init(with: items.map{ $0.source }, closeAction: closeAction)
                        top = Self.reduceTopItems(sections: sections.value)
                        content = Self.reduceContentItems(sections: sections.value)
                        bottom = Self.reduceBottomItems(sections: sections.value)
                        
                        // update bottom section continue button
                        updateBottomSection(isContinueEnabled: isItemsValuesValid)
                    }
                    
                case _ as PaymentsOperationViewModelAction.Continue:
                    // update operation with parameters
                    let updatedOperation = Self.reduce(operation: operation.value, items: items)
                    
                    // update stage
                    let updatedStageOperation = updatedOperation.updatedCurrentStepStage(reducer: model.paymentsProcessCurrentStepStageReducer(service:parameters:stepIndex:stepStage:))
                    
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "Continue operation: \(updatedStageOperation)")
                    
                    // continue operation
                    model.action.send(ModelAction.Payment.Process.Request(operation: updatedStageOperation))
                    self.action.send(PaymentsOperationViewModelAction.Spinner.Show())
                    
                    // hide keyboard
                    UIApplication.shared.endEditing()
                    
                case _ as PaymentsOperationViewModelAction.IcorrectCodeEnterred:
                    guard case .confirm(let confirmViewModel) = link else {
                        return
                    }
                    confirmViewModel.action.send(PaymentsConfirmViewModelAction.IcorrectCodeEnterred())
                    
                case let payload as PaymentsOperationViewModelAction.ShowWarning:
                    guard let warnableItem = items.first(where: { $0.source.id == payload.parameterId }) as? PaymentsParameterViewModelWarnable else {
                        return
                    }
                    warnableItem.update(warning: payload.message)
                    
                case _ as PaymentsOperationViewModelAction.CloseLink:
                    link = nil
                    
                case _ as PaymentsOperationViewModelAction.CloseBottomSheet:
                    bottomSheet = nil

                case _ as PaymentsOperationViewModelAction.Spinner.Show:
                    withAnimation {
                        spinner = .init()
                    }
                    
                case _ as PaymentsOperationViewModelAction.Spinner.Hide:
                    withAnimation {
                        spinner = nil
                    }
                    
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
                        // hide keyboard
                        UIApplication.shared.endEditing()
                        
                    case _ as PaymentsSectionViewModelAction.PopUpSelector.Close:
                        withAnimation {
                            bottomSheet = nil
                        }
                        
                    case let payload as PaymentsSectionViewModelAction.BankSelector.Show:
                        sheet = .init(type: .contacts(payload.viewModel))
                        // hide keyboard
                        UIApplication.shared.endEditing()
                        
                    case _ as PaymentsSectionViewModelAction.BankSelector.Close:
                        sheet = nil
                        
                    case let payload as PaymentsSectionViewModelAction.ContactSelector.Show:
                        sheet = .init(type: .contacts(payload.viewModel))
                        // hide keyboard
                        UIApplication.shared.endEditing()
                        
                    case _ as PaymentsSectionViewModelAction.ContactSelector.Close:
                        sheet = nil
                        
                    //MARK: Hint
                    case let payload as PaymentsSectionViewModelAction.Hint.Show:
                        bottomSheet = .init(type: .hint(payload.viewModel))

                    case _ as PaymentsSectionViewModelAction.Hint.Close:
                        bottomSheet = nil
                        
                    case _ as PaymentsSectionViewModelAction.SpoilerDidUpdated:
                        content = Self.reduceContentItems(sections: sections)
                        
                    case _ as PaymentsSectionViewModelAction.ResendCode:
                        self.model.action.send(ModelAction.Transfers.ResendCode.Request())
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
    
    private func bind(confirmViewModel: PaymentsConfirmViewModel) {
        
        confirmViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as PaymentsConfirmViewModelAction.CancelOperation:
                    self.action.send(PaymentsOperationViewModelAction.CancelOperation(amount: payload.amount, reason: payload.reason))
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
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
            
            guard let updatedParameter = dependenceReducer(service, item.source.id, parameters) else {
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

        for item in items {
            
            item.parameterValue = { [weak self] parameterId in
                
                self?.items.first(where: { $0.result.id == parameterId })?.result.value
            }
        }
    }
    
    func isParameterValueValid(parameterId: Payments.Parameter.ID) -> Bool {
        
        guard let item = items.first(where: { $0.source.id == parameterId }) else {
            return false
        }
        
        return item.isValid
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
        
        init(with parameters: [PaymentsParameterRepresentable]) {
            
            if let headerParameter = parameters.first(where: { $0.id == Payments.Parameter.Identifier.header.rawValue}) as? Payments.ParameterHeader,
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

        let isUserInteractionEnabled: CurrentValueSubject<Bool, Never> = .init(true)
        
        enum BottomSheetType {

            case popUp(PaymentsPopUpSelectView.ViewModel)
            case antifraud(PaymentsAntifraudViewModel)
            case hint(HintViewModel)
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
    
    enum Spinner {
    
        struct Show: Action {}
        
        struct Hide: Action {}
    }
    
    struct CloseLink: Action {}
    
    struct CloseBottomSheet: Action {}
    
    struct IcorrectCodeEnterred: Action {}
    
    struct CancelOperation: Action {
        
        let amount: String
        let reason: String?
    }
    
    struct ShowWarning: Action {
        
        let parameterId: Payments.Parameter.ID
        let message: String
    }
}
