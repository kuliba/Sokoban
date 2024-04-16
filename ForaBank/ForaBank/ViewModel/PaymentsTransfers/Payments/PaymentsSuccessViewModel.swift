//
//  PaymentsSuccessViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 09.10.2022.
//

import SwiftUI
import Combine
// TODO: extract AnySchedulerOfDispatchQueue into a separate module
import TextFieldModel

// TODO: remove Identifiable
final class PaymentsSuccessViewModel: ObservableObject, Identifiable {
        
    let action: PassthroughSubject<Action, Never> = .init()
    
    let id = UUID()
    @Published private(set) var sections: [PaymentsSectionViewModel]
    
    @Published private(set) var spinner: SpinnerView.ViewModel?
    @Published var alert: Alert.ViewModel?
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    @Published var informer: Informer?

    private let adapter: PaymentsSuccessViewModelAdapter
    private var bindings = Set<AnyCancellable>()
    private var sectionsBindings = Set<AnyCancellable>()
    private let scheduler: AnySchedulerOfDispatchQueue
    private var operationDetailData: OperationDetailData?

    private let operation: Payments.Operation?
    
    init(
        sections: [PaymentsSectionViewModel],
        adapter: PaymentsSuccessViewModelAdapter,
        operation: Payments.Operation?,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
            
        self.sections = sections
        self.adapter = adapter
        self.scheduler = scheduler
        self.operation = operation
        
        bind()
        sections.forEach { section in
            
            bind(section: section)
        }
        
        if let paymentOperationDetailID, documentStatus != .suspended {
            
            adapter.requestOperationDetail(with: paymentOperationDetailID)
        }
    }
    
    convenience init(
        paymentSuccess: Payments.Success,
        _ model: Model,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain(),
        mapper: @escaping (Payments.Success, Model) -> [PaymentsSectionViewModel] = PaymentsSectionViewModel.reduce(success:model:)
    ) {
        self.init(
            sections: mapper(paymentSuccess, model),
            adapter: .init(model: model, mapper: mapper, scheduler: scheduler),
            operation: paymentSuccess.operation,
            scheduler: scheduler
        )
    }
    
    private func bind() {
                
        // operation detail response
        adapter.operationDetailResponseHandler = { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case let .success(detailData):
                
                operationDetailData = detailData
             
                switch mode {
                case let .meToMe(templateId: templateId, from: productFromID, to: productToID, transferData):
                    guard let productIdFrom = productFromID,
                          let productIdTo = productToID,
                          let productFrom = adapter.product(productId: productIdFrom),
                          let productTo = adapter.product(productId: productIdTo),
                          let amount = transferData.debitAmount,
                          let paymentOperationDetailID else {
                        return
                    }
                    // FIXME: OperationDetailData received from server is incorrect? Why we have to manually create it? This code should be removed.
                    let fakeOperationDetailData = OperationDetailData.make(amount: amount, productFrom: productFrom, productTo: productTo, paymentOperationDetailId: paymentOperationDetailID, transferEnum: .conversionCardToAccount)
                    operationDetailData = fakeOperationDetailData
                    
                    // options buttons
                    if documentStatus != .suspended,
                        let optionButtonsParam = Payments.ParameterSuccessOptionButtons.buttons(
                        with: mode,
                        documentStatus: documentStatus,
                        operationDetail: fakeOperationDetailData,
                        operation: self.operation,
                        meToMePayment: .init(
                            templateId: templateId,
                            payerProductId: productIdFrom,
                            payeeProductId: productIdTo,
                            amount: amount
                        )
                    ) {
                        let updatedParameters = PaymentsParametersReducer.reduce(self.parameters, ([optionButtonsParam], mode))
                        updateSections(
                            with: self.operation,
                            parameters: updatedParameters
                        )
                    }
                    
                case let .makePaymentToDeposit(from: productFromID, to: productToID, transferData):
                    guard let productIdFrom = productFromID,
                          let productIdTo = productToID,
                          let productFrom = adapter.product(productId: productIdFrom),
                          let productTo = adapter.product(productId: productIdTo),
                          let amount = transferData.debitAmount,
                          let paymentOperationDetailID else {
                        return
                    }
                    // FIXME: OperationDetailData received from server is incorrect? Why we have to manually create it? This code should be removed.
                    let fakeOperationDetailData = OperationDetailData.make(amount: amount, productFrom: productFrom, productTo: productTo, paymentOperationDetailId: paymentOperationDetailID, transferEnum: .conversionCardToAccount)
                    operationDetailData = fakeOperationDetailData
                    
                    // options buttons
                    if documentStatus != .suspended,
                       let optionButtonsParam = Payments.ParameterSuccessOptionButtons.buttons(
                        with: mode,
                        documentStatus: documentStatus,
                        operationDetail: fakeOperationDetailData,
                        operation: self.operation,
                        meToMePayment: nil
                    ) {
                        let updatedParameters = PaymentsParametersReducer.reduce(self.parameters, ([optionButtonsParam], mode))
                        updateSections(
                            with: self.operation,
                            parameters: updatedParameters
                        )
                    }
                    
                case let .makePaymentFromDeposit(from: productFromID, to: productToID, transferData):
                    guard let productIdFrom = productFromID,
                          let productIdTo = productToID,
                          let productFrom = adapter.product(productId: productIdFrom),
                          let productTo = adapter.product(productId: productIdTo),
                          let amount = transferData.debitAmount,
                          let paymentOperationDetailID else {
                        return
                    }
                    // FIXME: OperationDetailData received from server is incorrect? Why we have to manually create it? This code should be removed.
                    let fakeOperationDetailData =  OperationDetailData.make(amount: amount, productFrom: productFrom, productTo: productTo, paymentOperationDetailId: paymentOperationDetailID, transferEnum: .conversionCardToAccount)
                    operationDetailData = fakeOperationDetailData
                    
                    // options buttons
                    if documentStatus != .suspended,
                       let optionButtonsParam = Payments.ParameterSuccessOptionButtons.buttons(
                        with: mode,
                        documentStatus: documentStatus,
                        operationDetail: fakeOperationDetailData,
                        operation: self.operation,
                        meToMePayment: nil
                    ) {
                        let updatedParameters = PaymentsParametersReducer.reduce(self.parameters, ([optionButtonsParam], mode))
                        updateSections(
                            with: self.operation,
                            parameters: updatedParameters
                        )
                    }
                    
                default:
                    guard let result = Payments.Success.parameters(
                        with: detailData,
                        amountFormatter: adapter.amountFormatted(amount:currencyCode:style:),
                        mode: mode,
                        documentStatus: documentStatus,
                        operation: self.operation
                    ) else {
                        break
                    }
                    
                    let updatedParameters = PaymentsParametersReducer.reduce(self.parameters, (result.parameters, result.transferType))
                    updateSections(
                        with: self.operation,
                        parameters: updatedParameters
                    )
                }
                  
            case let .failure(error):
                // MARK: Informer Detail Error
                adapter.showInformer(.init(message: "Ошибка получения данных", icon: .close))
                
                LoggerAgent.shared.log(level: .error, category: .ui, message: "ModelAction.Operation.Detail.Response error: \(error)")
            }
        }
        
        // subscription response
        adapter.subscriptionResponseHandler = { [weak self] result in
            
            guard let self = self else { return }
            
            self.spinner = nil
            
            switch result {
            case let .success(success):
                let successViewModel = adapter.makePaymentSuccessViewModel(with: success)
                self.fullScreenCover = .init(type: .success(successViewModel))
                bind(successViewModel)
                
            case let .failure(error):
                alert = .init(title: "Ошибка", message: error.localizedDescription, primary: .init(type: .default, title: "Ok", action: {}))
            }
        }
        
        // MARK: - PaymentsSuccessViewModel Actions
        
        // PaymentsSuccessAction.Button.Close
        action
            .compactMap { $0 as? PaymentsSuccessAction.Button.Close }
            .receive(on: scheduler)
            .sink { [weak self] _ in
                
                self?.adapter.updateProducts()
                
            }.store(in: &bindings)
        
        // PaymentsSuccessAction.ShowOperationDetailInfo
        action
            .compactMap { $0 as? PaymentsSuccessAction.ShowOperationDetailInfo }
            .map(\.viewModel)
            .receive(on: scheduler)
            .sink { [weak self] detailInfoViewModel in
                
                self?.sheet = .init(type: .detailInfo(detailInfoViewModel))
                
            }.store(in: &bindings)
        
        // MARK: - Other Actions
        
        // DelayWrappedAction
        action
            .compactMap { $0 as? DelayWrappedAction }
            .flatMap { [weak self] in
                
                struct NoSelfError: Error {}
                
                guard let self
                else {
                    return Fail(outputType: Action.self, failure: NoSelfError() as Error)
                        .eraseToAnyPublisher()
                }
                
                return Just($0.action)
                    .setFailureType(to: Error.self)
                    .delay(for: .milliseconds($0.delayMS), scheduler: self.scheduler)
                    .eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in
                    
                    self?.action.send($0)
                }
            ).store(in: &bindings)
        
        transferNumberInformer()?.assign(to: &$informer)
    }
    
    // FIXME: figure out how to get rid of second Success View
    private func bind(_ successViewModel: PaymentsSuccessViewModel) {
        
        successViewModel.action
            .compactMap { $0 as? PaymentsSuccessAction.Button.Close }
            .receive(on: scheduler)
            .sink { [weak self] _ in
                
                self?.action.send(PaymentsSuccessAction.Button.Close())
            }
            .store(in: &bindings)
    }
    
    private func bind(section: PaymentsSectionViewModel) {
        
        section.action
            .compactMap { $0 as? PaymentsSectionViewModelAction.Button.DidTapped }
            .map(\.action)
            .receive(on: scheduler)
            .sink { [weak self] action in
                
                guard let self else { return }
                
                switch action {
                case .main:
                    self.action.send(PaymentsSuccessAction.Button.Close())
                    withAnimation {
                        NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
                    }
                case .save:
                    self.spinner = .init()
                    adapter.requestSubscription(parameters: parameters, action: .link)
                    
                case .update:
                    self.spinner = .init()
                    adapter.requestSubscription(parameters: parameters, action: .update)
                    
                case .cancelSubscribe:
                    self.spinner = .init()
                    adapter.requestSubscription(parameters: parameters, action: .cancel)
                    
                case .cancel:
                    self.spinner = .init()
                    adapter.requestSubscription(parameters: parameters, action: .deny)
                    
                case .repeat:
                    self.action.send(PaymentsSuccessAction.Button.Repeat())
                    
                case .additionalChange:
                    guard let source = makeChangeSource(from: operationDetailData)
                    else { return }
                    
                    let action = PaymentsSuccessAction.Payment(source: source)
                    self.action.send(action)
                    
                case .additionalReturn:
                    guard let source = makeReturnSource(from: operationDetailData)
                    else { return }
                    
                    let action = PaymentsSuccessAction.Payment(source: source)
                    self.action.send(action)
                    
                case .close:
                    self.action.send(PaymentsSuccessAction.Button.Ready())

                default:
                    break
                }
                
            }.store(in: &sectionsBindings)
        
        section.action
            .compactMap { $0 as? PaymentsSectionViewModelAction.OptionButtonDidTapped }
            .map(\.option)
            .receive(on: scheduler)
            .sink { [weak self] option in
                
                guard let self else { return }
                
                switch option {
                case .document:
                    
                    switch mode {
                    case .normal, .meToMe, .closeDeposit, .makePaymentToDeposit, .makePaymentFromDeposit, .change, .refund, .sberQR:
                        guard
                            let operationDetailData,
                            let paymentOperationDetailID
                        else {
                            return
                        }
                        
                        let printFormViewModel = adapter.makePrintFormViewModel(type: .operation(paymentOperationDetailId: paymentOperationDetailID, printFormType: operationDetailData.printFormType))
                        
                        self.sheet = .init(type: .printForm(printFormViewModel))
                        
                    case let .closeAccount(productDataId, _, balance: _, _):
                        guard let paymentOperationDetailID else {
                            return
                        }
                        let printFormViewModel = adapter.makePrintFormViewModel(type: .closeAccount(id: productDataId, paymentOperationDetailId: paymentOperationDetailID))
                        
                        self.sheet = .init(type: .printForm(printFormViewModel))
                        
                    case let .closeAccountEmpty(productId, _, balance: _, _):
                        let printFormViewModel = adapter.makePrintFormViewModel(type: .closeAccountEmpty(id: productId))
                        
                        self.sheet = .init(type: .printForm(printFormViewModel))
                        
                    case .changePin:
                        return
                    }
                    
                case .details:
                    guard let operationDetailData else {
                        return
                    }
                    
                    let viewModel = adapter.makeOperationDetailInfoViewModel(operationDetailData: operationDetailData) { [weak self] in
                        
                        self?.sheet = nil
                    }
                    
                    self.sheet = .init(type: .detailInfo(viewModel))
                    
                default:
                    break
                }
            }
            .store(in: &sectionsBindings)
    }
    
    func updateSections(
        with operation: Payments.Operation?,
        parameters: [PaymentsParameterRepresentable]
    ) {
        let success = Payments.Success(
            operation: operation,
            parameters: parameters
        )
        let updatedSections = adapter.makeSections(success)
        sectionsBindings = Set<AnyCancellable>()
        updatedSections.forEach { section in
            bind(section: section)
        }
        withAnimation { [weak self] in
            
            self?.sections = updatedSections
        }
        transferNumberInformer()?.assign(to: &$informer)
    }
}

extension PaymentsSuccessViewModel {
    
    func makeChangeSource(
        from operationDetailData: OperationDetailData?
    ) -> Payments.Operation.Source? {
        
        guard let operationDetailData,
              let name = operationDetailData.payeeFullName,
              let number = operationDetailData.transferReference
        else { return nil }
        
        let operationID = operationDetailData.paymentOperationDetailId.description
        
        return .change(
            operationId: operationID,
            transferNumber: number,
            name: name
        )
    }
    
    func makeReturnSource(
        from operationDetailData: OperationDetailData?
    ) -> Payments.Operation.Source? {
        
        guard let operationDetailData,
              let number = operationDetailData.transferReference
        else { return nil }
        
        let amountValue = operationDetailData.payerAmount - operationDetailData.payerFee
        let currency = operationDetailData.payerCurrency
        guard let amount = adapter.amountFormatted(amount: amountValue, currencyCode: currency, style: .fraction)
        else { return nil }
        
        let operationID = operationDetailData.paymentOperationDetailId
        let productID = operationDetailData.payerCardId?.description ?? operationDetailData.payerAccountId.description
        
        return .return(
            operationId: operationID,
            transferNumber: number,
            amount: amount,
            productId: productID
        )
    }
}

// MARK: - Computed Properties

extension PaymentsSuccessViewModel {
    
    var feed: [PaymentsGroupViewModel] {
        
        sections
            .filter { $0.placement == .feed }
            .flatMap(\.groups)
    }
    
    var bottom: [PaymentsGroupViewModel] {
        
        sections
            .filter { $0.placement == .bottom }
            .flatMap(\.groups)
    }
    
    var parameters: [PaymentsParameterRepresentable] {
        
        sections
            .flatMap(\.groups)
            .flatMap(\.items)
            .map { $0.source.updated(value: $0.value.current) }
    }
    
    var items: [PaymentsParameterViewModel] {
        
        sections
            .flatMap(\.groups)
            .flatMap(\.items)
    }
    
    var mode: Mode {
        
        guard let param = try? parameters.parameter(forIdentifier: .successMode, as: Payments.ParameterSuccessMode.self)
        else { return .normal }
        
        return param.mode
    }
    
    var paymentOperationDetailID: Int? {
        
        guard let param = try? parameters.parameter(forIdentifier: .successOperationDetailID),
              let stringValue = param.value,
              let intValue = Int(stringValue)
        else { return nil }
        
        return intValue
    }
    
    var documentStatus: TransferResponseBaseData.DocumentStatus {
        
        guard let param = try? parameters.parameter(forIdentifier: .successStatus, as: Payments.ParameterSuccessStatus.self)
        else { return .unknown }
        
        return param.documentStatus
    }
}

// MARK: - Types

extension PaymentsSuccessViewModel {
    
    enum Mode: Equatable {
        
        case normal
        case meToMe(templateId: Int?, from: ProductData.ID?, to: ProductData.ID?, TransferResponseData)
        case closeDeposit(Currency, balance: Double, CloseProductTransferData)
        case closeAccount(ProductData.ID, Currency, balance: Double, CloseProductTransferData)
        case closeAccountEmpty(ProductData.ID, Currency, balance: Double, CloseProductTransferData)
        case makePaymentToDeposit(from: ProductData.ID?, to: ProductData.ID?, TransferResponseData)
        case makePaymentFromDeposit(from: ProductData.ID?, to: ProductData.ID?, TransferResponseData)
        case changePin
        case change, refund
        case sberQR
    }
    
    struct FullScreenCover: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case abroad(PaymentsViewModel)
            case success(PaymentsSuccessViewModel)
        }
    }
    
    struct Informer: Identifiable & Hashable {
        
        let message: String
        
        init(_ message: String) {
            
            self.message = message
        }
        
        var id: String { message }
    }

    struct Sheet: Identifiable {
        
        let id = UUID()
        let type: Kind
        
        enum Kind {
            
            case printForm(PrintFormView.ViewModel)
            case detailInfo(OperationDetailInfoViewModel)
        }
    }
}

private extension PaymentsSuccessTransferNumberView.ViewModel.State {
    
    var informer: PaymentsSuccessViewModel.Informer? {
        
        switch self {
        case .check: return .init("Номер скопирован")
        case .copy: return nil
        }
    }
}

private extension PaymentsSuccessTransferNumberView.ViewModel {
    
    var informer: AnyPublisher<PaymentsSuccessViewModel.Informer?, Never> {
        
        $state
            .map(\.informer)
            .eraseToAnyPublisher()
    }
}

private extension PaymentsSuccessViewModel {
    
    func parameterViewModel(
        with id: Payments.Parameter.ID
    ) -> PaymentsParameterViewModel? {
        
        sections.flatMap(\.items).first(where: { $0.id == id })
    }
    
    func transferNumberViewModel(
    ) -> PaymentsSuccessTransferNumberView.ViewModel? {
        
        let id = Payments.Parameter.Identifier.successTransferNumber.rawValue
        let viewModel = parameterViewModel(with: id)
        
        return viewModel as? PaymentsSuccessTransferNumberView.ViewModel
    }
    
    func transferNumberInformer() -> AnyPublisher<PaymentsSuccessViewModel.Informer?, Never>? {
        
        transferNumberViewModel()?
            .$state
            .map(\.informer)
            .eraseToAnyPublisher()
    }
}

// MARK: - Action

enum PaymentsSuccessAction {
    
    enum Button {
        
        struct Close: Action {}
        struct Repeat: Action {}
        struct Ready: Action {}
    }
    
    struct Payment: Action {
        
        let source: Payments.Operation.Source
    }
    
    struct ShowOperationDetailInfo: Action {
        
        let viewModel: OperationDetailInfoViewModel
    }
}
