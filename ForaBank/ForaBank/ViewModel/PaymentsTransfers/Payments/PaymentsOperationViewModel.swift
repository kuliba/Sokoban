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
    @Published var top: [PaymentsGroupViewModel]?
    @Published var feed: [PaymentsGroupViewModel]
    @Published var bottom: [PaymentsGroupViewModel]?
    
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
    
    init(navigationBar: NavigationBarView.ViewModel, top: [PaymentsGroupViewModel]?, feed: [PaymentsGroupViewModel], bottom: [PaymentsGroupViewModel]?, link: Link? = nil, bottomSheet: BottomSheet? = nil, operation: Payments.Operation = .emptyMock, model: Model = .emptyMock, closeAction: @escaping () -> Void) {
        
        self.navigationBar = navigationBar
        self.top = top
        self.feed = feed
        self.bottom = bottom
        self.link = link
        self.bottomSheet = bottomSheet
        self.operation = .init(operation)
        self.model = model
        self.closeAction = closeAction
    }
    
    convenience init(navigationBar: NavigationBarView.ViewModel = .init(), operation: Payments.Operation, model: Model, closeAction: @escaping () -> Void) {

        self.init(navigationBar: navigationBar, top: nil, feed: [], bottom: nil, link: nil, bottomSheet: nil, operation: operation, model: model, closeAction: closeAction)
        
        bind()
    }

    // MARK: Bind
    
    internal func bind() {
        
        bindOperation()
        bindModel()
        bindAction()
        bindNavBar()
    }
    
    internal func bindOperation() {
        
        operation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] operation in
                
                guard let self else { return }
                
                sections.value = PaymentsSectionViewModel.reduce(operation: operation, model: model)
                bind(sections: sections.value)
            }
            .store(in: &bindings)
        
        sections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                
                guard let self else { return }
                
                withAnimation(.easeOut(duration: 0.3)) { [weak self] in
                    
                    self?.top = Self.reduceTopGroups(sections: sections)
                    self?.feed = Self.reduceFeedGroups(sections: sections)
                    self?.bottom = Self.reduceBottomGroups(sections: sections)
                }
                
                // update dependend items
                Self.reduce(operation: operation.value, items: items, dependenceReducer: model.paymentsProcessDependencyReducer(operation:parameterId:parameters:))
                
                navigationBar = .init(with: items.map{ $0.source }, closeAction: closeAction)
                bindNavBar()
                
                // update bottom section continue button
                updateBottomSection(isContinueEnabled: isItemsValuesValid)
                
                // update parameter value callback for each item
                updateParameterValueCallback(items: items)
            }
            .store(in: &bindings)
    }
    
    internal func bindModel() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self else { return }
                
                switch action {
                case let payload as ModelAction.Payment.Process.Response:
                    
                    self.action.send(PaymentsOperationViewModelAction.Spinner.Hide())
                    
                    switch payload.result {
                    case .step(let operation):
                        self.operation.value = operation
                        
                    case .confirm(let operation):
                        let confirmViewModel = PaymentsConfirmViewModel(operation: operation, model: model, closeAction: { [weak self] in
                            
                            self?.link = nil
                        })
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
            }
            .store(in: &bindings)
    }
    
    internal func bindAction() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self else { return }
                
                switch action {
                case let payload as PaymentsOperationViewModelAction.ItemDidUpdated:
                    
                    // update operation with parameters
                    let updatedOperation = Self.reduce(operation: operation.value, items: items)
                    
                    // check if rollback required
                    if let rollbackStep = model.paymentsIsRollbackRequired(operation: updatedOperation, updated: payload.parameterId) {
                        
                        do {
                            
                            let rolledBackOperation = try updatedOperation.rollback(to: rollbackStep)
                            
                            if model.paymentsIsAutoContinueRequired(operation: rolledBackOperation, updated: payload.parameterId) {
                                
                                // update stage
                                let updatedStageOperation = updatedOperation.updatedCurrentStepStage(reducer: model.paymentsProcessCurrentStepStageReducer(service:parameters:stepIndex:stepStage:))
                                
                                LoggerAgent.shared.log(level: .debug, category: .ui, message: "Continue operation: \(updatedStageOperation)")
                                
                                // auto continue operation
                                model.action.send(ModelAction.Payment.Process.Request(operation: updatedStageOperation))
                                self.action.send(PaymentsOperationViewModelAction.Spinner.Show())
                            }
                           
                            operation.value = rolledBackOperation
                            
                        } catch {
                            
                            LoggerAgent.shared.log(level: .error, category: .ui, message: "Unable rollback operation with error: \(error)")
                            rootActions?.alert("Unable rollback operation with error: \(error)")
                        }
                        
                    } else {
                        
                        // update dependend items
                        Self.reduce(operation: operation.value, items: items, dependenceReducer: model.paymentsProcessDependencyReducer(operation:parameterId:parameters:))
                        
                        navigationBar = .init(with: items.map{ $0.source }, closeAction: closeAction)
                        bindNavBar()

                        withAnimation(.easeOut(duration: 0.3)) { [weak self] in
                            
                            guard let self else { return }
                            
                            top = Self.reduceTopGroups(sections: sections.value)
                            feed = Self.reduceFeedGroups(sections: sections.value)
                            bottom = Self.reduceBottomGroups(sections: sections.value)
                        }

                        // update bottom section continue button
                        updateBottomSection(isContinueEnabled: isItemsValuesValid)
                        
                        // updates warnins for parameters with invalid values
                        updateParametersValidationWarnings(parameterId: payload.parameterId)
                    }
                    
                case _ as PaymentsOperationViewModelAction.Continue:
                    // update operation with parameters
                    let updatedOperation = Self.reduce(operation: operation.value, items: items)
                    
                    // update stage
                    let updatedStageOperation = updatedOperation.updatedCurrentStepStage(reducer: model.paymentsProcessCurrentStepStageReducer(service:parameters:stepIndex:stepStage:))
                    
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "Continue operation: \(updatedStageOperation)")
                    
                    //update collapsable group
                    collapseContactGroups(groups: self.feed)
                    
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
                    withAnimation { [weak self] in
                        
                        self?.spinner = .init()
                    }
                    
                case _ as PaymentsOperationViewModelAction.Spinner.Hide:
                    withAnimation { [weak self] in
                        
                        self?.spinner = nil
                    }
                    
                case let changeName as PaymentsOperationViewModelAction.ChangeName:
                    bottomSheet = .init(type: .changeName(changeName.viewModel))
                    bindRename(rename: changeName.viewModel)
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    // MARK: Bind Sections
    
    internal func bind(sections: [PaymentsSectionViewModel]) {
        
        for section in sections {
            
            section.action
                .receive(on: DispatchQueue.main)
                .sink { [weak self] action in
                    
                    guard let self else { return }
                    
                    switch action {
                    case let payload as PaymentsSectionViewModelAction.ItemValueDidChanged:
                        guard payload.value.isChanged || payload.value.currencyIsChanged else {
                            return
                        }
                        self.action.send(PaymentsOperationViewModelAction.ItemDidUpdated(parameterId: payload.value.id))
                        
                    case let payload as PaymentsSectionViewModelAction.Button.DidTapped:
                        switch payload.action {
                        case .continue:
                            self.action.send(PaymentsOperationViewModelAction.Continue())
                            
                        default:
                            //TODO: implement other actions if required
                            break
                        }
                        
                    case let payload as PaymentsSectionViewModelAction.PopUpSelector.Show:
                        bottomSheet = .init(type: .popUp(payload.viewModel))
                        // hide keyboard
                        UIApplication.shared.endEditing()
                        
                    case _ as PaymentsSectionViewModelAction.PopUpSelector.Close:
                        withAnimation { [weak self] in
                            
                            self?.bottomSheet = nil
                        }
                        
                    case let payload as PaymentsSectionViewModelAction.BankSelector.Show:
         
                        let contactsViewModel: ContactsViewModel = {
                            
                            switch payload.type {
                            case .banks:
                                let itemPhone = self.items.first(where: { $0.id == Payments.Parameter.Identifier.sfpPhone.rawValue })
                                return self.model.makeContactsViewModel(forMode: .select(.banks(phone: itemPhone?.value.current)))
                                
                            case .banksFullInfo:
                                return self.model.makeContactsViewModel(forMode: .select(.banksFullInfo))
                            }
                            
                        }()
                        
                        bind(contactsViewModel: contactsViewModel)
                        
                        sheet = .init(type: .contacts(contactsViewModel))
                        
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
                        
                        // MARK: Hint
                    case let payload as PaymentsSectionViewModelAction.Hint.Show:
                        bottomSheet = .init(type: .hint(payload.viewModel))
                        
                    case _ as PaymentsSectionViewModelAction.Hint.Close:
                        bottomSheet = nil
                        
                    case _ as PaymentsSectionViewModelAction.ResendCode:
                        self.model.action.send(ModelAction.Transfers.ResendCode.Request())
                        
                    default:
                        break
                    }
                }
                .store(in: &bindings)
        }
    }
    
    // MARK: Bind Navigation Bar
    private func bindNavBar() {
        
        navigationBar.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self else { return }
                
                switch action {
                case _ as NavigationBarViewModelAction.ScanQrCode:
                    self.action.send(PaymentsViewModelAction.ScanQrCode())
                    
                case let editName as NavigationBarViewModelAction.EditName:
                    self.action.send(PaymentsOperationViewModelAction.ChangeName(viewModel: editName.viewModel))
                    
                default: break
                }
            }
            .store(in: &bindings)
    }
    
    private func bindRename(
        rename: TemplatesListViewModel.RenameTemplateItemViewModel
    ) {
        
        rename.action
            .compactMap { $0 as? TemplatesListViewModelAction.RenameSheetAction.SaveNewName }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] payload in
                
                guard let self else { return }
                
                bottomSheet = nil
                
                navigationBar.title = payload.newName
                model.action.send(ModelAction.PaymentTemplate.Update.Requested
                    .init(name: payload.newName,
                          parameterList: nil,
                          paymentTemplateId: payload.itemId))
                model.action.send(ModelAction.PaymentTemplate.List.Requested())
                
            }
            .store(in: &bindings)
    }
    
    private func bind(confirmViewModel: PaymentsConfirmViewModel) {
        
        confirmViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self else { return }
                
                switch action {
                case let payload as PaymentsConfirmViewModelAction.CancelOperation:
                    self.action.send(PaymentsOperationViewModelAction.CancelOperation(
                        amount: payload.amount,
                        reason: payload.reason
                    ))
                    
                case let payload as PaymentsOperationViewModelAction.CancelOperation:
                    
                    switch payload.reason {
                    case .cancel, .none:
                        //TODO: move to convenience init
                        let success = Payments.Success(
                            operation: operation.value,
                            parameters: [
                                Payments.ParameterSuccessStatus(status: .accepted),
                                Payments.ParameterSuccessText(value: "Перевод отменен!", style: .warning),
                                Payments.ParameterSuccessText(value: String(payload.amount.dropFirst()), style: .amount),
                                Payments.ParameterButton.actionButtonMain()
                            ])
                        
                        self.link = .success(.init(paymentSuccess: success, model))
                        
                    case .timeOut:
                        //TODO: move to convenience init
                        let success = Payments.Success(
                            operation: operation.value,
                            parameters: [
                                Payments.ParameterSuccessStatus(status: .accepted),
                                Payments.ParameterSuccessText(value: "Перевод отменен!", style: .warning),
                                Payments.ParameterSuccessText(value: "Время на подтверждение перевода вышло", style: .title),
                                Payments.ParameterSuccessText(value: String(payload.amount.dropFirst()), style: .amount),
                                Payments.ParameterButton.actionButtonMain()
                            ])
                        
                        self.link = .success(.init(paymentSuccess: success, model))
                    }
                    
                case _ as PaymentsOperationViewModelAction.ItemDidUpdated:
                    updateBottomSection(isContinueEnabled: isItemsValuesValid)
                    
                default:
                    break
                }
            }
            .store(in: &bindings)
    }
    
    private func bind(contactsViewModel: ContactsViewModel) {
            
            contactsViewModel.action
                .compactMap({$0 as? ContactsViewModelAction.BankSelected })
                .map(\.bankId)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] bankId in
                    
                    self?.sheet = nil
                    
                    let bankItem = self?.items.compactMap({ $0 as? PaymentsSelectBankView.ViewModel }).first
                    bankItem?.action.send(PaymentsParameterViewModelAction.SelectBank.List.BankItemTapped(id: bankId))
                    
                }.store(in: &bindings)
        }
}

// MARK: - Sections Reducers

extension PaymentsOperationViewModel {
    
    static func reduceTopGroups(sections: [PaymentsSectionViewModel]) -> [PaymentsGroupViewModel]? {
        
        guard let topSection = sections.first(where: { $0.placement == .top }) else {
            return nil
        }
        
        return topSection.groups
    }
    
    static func reduceFeedGroups(sections: [PaymentsSectionViewModel]) -> [PaymentsGroupViewModel] {
        
        guard let feedSection = sections.first(where: { $0.placement == .feed }) else {
            return []
        }
        
        let groups = feedSection.groups.filter { $0.items.allSatisfy(\.isNotHidden) }
        
        return groups
    }
    
    static func reduceBottomGroups(sections: [PaymentsSectionViewModel]) -> [PaymentsGroupViewModel]? {
        
        guard let bottomSection = sections.first(where: { $0.placement == .bottom }) else {
            return nil
        }
        
        return bottomSection.groups
    }
}

// MARK: - Reducers

extension PaymentsOperationViewModel {
    
    static func reduce(operation: Payments.Operation, items: [PaymentsParameterViewModel]) -> Payments.Operation {
        
        let parameters = items.map{ $0.result }
        let updatedOperation = operation.updated(with: parameters)
        return updatedOperation
    }
    
    static func reduce(operation: Payments.Operation, items: [PaymentsParameterViewModel], dependenceReducer: (Payments.Operation, Payments.Parameter.ID, [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable?) {
        
        let parameters = items.map{ $0.source.updated(value: $0.value.current) }
        for item in items {
            
            guard let updatedParameter = dependenceReducer(operation, item.source.id, parameters) else {
                continue
            }
            
            item.update(source: updatedParameter)
        }
    }
}

// MARK: - Helpers

extension PaymentsOperationViewModel {
        
    func updateBottomSection(isContinueEnabled: Bool) {
        
        guard let bottomSection = sections.value.first(where: { $0.placement == .bottom }) else {
            return
        }
        
        bottomSection.action.send(PaymentsSectionViewModelAction.Button.EnabledChanged(isEnabled: isContinueEnabled))
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
    
    func updateParametersValidationWarnings(parameterId: Payments.Parameter.ID) {
        
        guard let item = items.first(where: { $0.source.id == parameterId }), item.isValidationChecker == true else {
            return
        }
        
        for item in items {
            
            item.updateValidationWarnings()
        }
    }
    
    func collapseContactGroups(groups: [PaymentsGroupViewModel]) {

        groups.forEach { group in

          if let group = group as? PaymentsContactGroupViewModel {
                    
             group.setCollapsed()
          }
        }
    }

}

// MARK: - Types

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
        
        case success(PaymentsSuccessViewModel)
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
            case changeName(TemplatesListViewModel.RenameTemplateItemViewModel)
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

// MARK: - Action

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
        
        typealias Reason = PaymentsConfirmViewModelAction.CancelOperation.Reason?
        
        let amount: String
        let reason: Reason
    }
    
    struct ShowWarning: Action {
        
        let parameterId: Payments.Parameter.ID
        let message: String
    }
    
    struct ChangeName: Action {
        
        let viewModel: TemplatesListViewModel.RenameTemplateItemViewModel
    }
}
