//
//  PaymentsViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 14.03.2022.
//

import Combine
import Foundation
import ServerAgent
import SwiftUI

class PaymentsViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    @Published var content: ContentType
    @Published var successViewModel: PaymentsSuccessViewModel?
    @Published var spinner: SpinnerView.ViewModel?
    @Published var alert: Alert.ViewModel?
    
    let closeAction: () -> Void
    
    private let model: Model
    private var source: Payments.Operation.Source?
    private var bindings = Set<AnyCancellable>()

    enum ContentType {
        
        case loading
        case service(PaymentsServiceViewModel)
        case operation(PaymentsOperationViewModel)
        case linkNotActive(PaymentsSuccessViewModel)
    }
    
    init(content: ContentType, model: Model, closeAction: @escaping () -> Void) {
        
        self.content = content
        self.model = model
        self.closeAction = closeAction
    }
        
    convenience init(category: Payments.Category, model: Model, closeAction: @escaping () -> Void) {
        
        self.init(content: .loading, model: model, closeAction: closeAction)
        bind()

        Task {
            
            do {
                
                let result = try await model.paymentsService(for: category)
                switch result {
                case let .select(selectServiceParameter):
                    // multiple services for category
                    let serviceViewModel = PaymentsServiceViewModel(
                        category: category,
                        parameters: [selectServiceParameter],
                        model: model,
                        closeAction: closeAction
                    )
                    serviceViewModel.rootActions = rootActions
                    
                    await MainActor.run {
                        
                        withAnimation {
                            content = .service(serviceViewModel)
                        }
                    }
                    
                case let .selected(service):
                    // single service for category
                    let operation = try await model.paymentsOperation(with: service)
                    let operationViewModel = PaymentsOperationViewModel(operation: operation, model: model, closeAction: closeAction)
                    operationViewModel.rootActions = rootActions
                    bind(operationViewModel: operationViewModel)
                    
                    await MainActor.run {
                        
                        withAnimation {
                            content = .operation(operationViewModel)
                        }
                    }
                }
                
            } catch {
                
                LoggerAgent.shared.log(level: .error, category: .ui, message: "Payment with category: \(category) start failed with error: \(error)")
                
                self.action.send(PaymentsViewModelAction.CriticalAlert(title: "Ошибка", message: "\(error.localizedDescription)"))
            }
        }
    }
    
    convenience init(source: Payments.Operation.Source, model: Model, closeAction: @escaping () -> Void) {
        
        self.init(content: .loading, model: model, closeAction: closeAction)
        self.source = source
        bind()
        
        sourceOperation(model, source, closeAction)
    }
    
    convenience init(_ model: Model, service: Payments.Service, closeAction: @escaping () -> Void) {
        
        self.init(content: .loading, model: model, closeAction: closeAction)
        
        bind()
        
        Task {
            
            do {
                
                let operation = try await model.paymentsOperation(with: service)
                let operationViewModel = PaymentsOperationViewModel(operation: operation, model: model, closeAction: closeAction)
                operationViewModel.rootActions = rootActions
                bind(operationViewModel: operationViewModel)
                
                await MainActor.run {
                    
                    withAnimation {
                        content = .operation(operationViewModel)
                    }
                }
                
            } catch {
                
                LoggerAgent.shared.log(level: .error, category: .ui, message: "Payment with service: \(service) start failed with error: \(error)")
                
                self.action.send(PaymentsViewModelAction.CriticalAlert(title: "Ошибка", message: "\(error.localizedDescription)"))
            }
        }
    }
    
    private func bind() {
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self else { return }
                
                switch action {
                case let payload as ModelAction.Payment.Process.Response:
                    self.action.send(PaymentsViewModelAction.Spinner.Hide())
                    
                    switch payload.result {
                    case let .complete(paymentSuccess):
                        let successViewModel = PaymentsSuccessViewModel(paymentSuccess: paymentSuccess, model)
                        self.successViewModel = successViewModel
                        bind(successViewModel: successViewModel)
                        // update products balances
                        model.action.send(ModelAction.Products.Update.Total.All())
                        // update latest operations list
                        model.action.send(ModelAction.LatestPayments.List.Requested())
                        
                    case let .failure(error):
                        switch error {
                        case let paymentsError as Payments.Error:
                            switch paymentsError {
                            case let .action(action):
                                switch action {
                                case let .warning(parameterId: parameterId, message: message):
                                    
                                    if case .operation(let operationViewModel) = content {
                                        
                                        operationViewModel.action.send(PaymentsOperationViewModelAction.ShowWarning(parameterId: parameterId, message: message))
                                        
                                    } else {
                                        
                                        self.action.send(PaymentsViewModelAction.CriticalAlert(title: "Ошибка", message: error.localizedDescription))
                                    }
                                    
                                case let .alert(title: title, message: message):
                                    self.action.send(PaymentsViewModelAction.CriticalAlert(title: title, message: message))
                                }
                                
                            default:
                                self.action.send(PaymentsViewModelAction.CriticalAlert(title: "Ошибка", message: error.localizedDescription))
                            }
                        case let serverError as ServerAgentError:
                            switch serverError {
                            case let .serverStatus(.serverError, errorMessage: message):
                                guard let message = message else {
                                    return
                                }
                                
                                if message.contains("Введен некорректный код") {
                                    
                                    guard case .operation(let operationViewModel) = content else {
                                        return
                                    }
                                    
                                    operationViewModel.action.send(PaymentsOperationViewModelAction.IcorrectCodeEnterred())
                                    
                                } else if message.contains("Вы исчерпали") {
                                    
                                    self.action.send(PaymentsViewModelAction.CriticalAlert(title: "Ошибка", message: message))
                                    
                                } else {
                                    
                                    self.action.send(PaymentsViewModelAction.CriticalAlert(title: "Ошибка", message: message))
                                }
                                
                            default:
                                self.action.send(PaymentsViewModelAction.CriticalAlert(title: "Ошибка", message: error.localizedDescription))
                            }
                            
                        default:
                            self.action.send(PaymentsViewModelAction.CriticalAlert(title: "Ошибка", message: error.localizedDescription))
                        }
                        
                    default:
                        break
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self else { return }
                
                switch action {
                    
                case _ as PaymentsViewModelAction.Dismiss:
                    withAnimation {
                        
                        NotificationCenter.default.post(name: .dismissAllViewAndSwitchToMainTab, object: nil)
                    }
                    
                case _ as PaymentsViewModelAction.Spinner.Show:
                    withAnimation { [weak self] in
                        
                        self?.spinner = .init()
                    }
                    
                case _ as PaymentsViewModelAction.Spinner.Hide:
                    withAnimation { [weak self] in
                        
                        self?.spinner = nil
                    }
                    
                case _ as PaymentsViewModelAction.CloseSuccessView:
                    withAnimation {
                        
                        self.successViewModel = nil
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        action
            .compactMap({ $0 as? PaymentsViewModelAction.CriticalAlert })
            .delay(for: .milliseconds(700), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] payload in
                
                guard let self else { return }
                
                alert = .init(
                    title: payload.title,
                    message: payload.message,
                    primary: .init(type: .cancel, title: "Ок", action: closeAction))
                
            }.store(in: &bindings)
    }
    
    private func bind(successViewModel: PaymentsSuccessViewModel) {
        
        successViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self else { return }
                
                switch action {
                case _ as PaymentsSuccessAction.Button.Close:
                    self.action.send(PaymentsViewModelAction.Dismiss())
                    
                case let payload as PaymentsSuccessAction.Payment:
                    self.action.send(PaymentsViewModelAction.ContactAbroad(source: payload.source))
                    self.action.send(PaymentsViewModelAction.CloseSuccessView())
                    
                case _ as PaymentsSuccessAction.Button.Repeat:
                    //TODO: correct implementation required                    
                    switch content {
                        
                    case .linkNotActive:
                        if let source {
                            sourceOperation(
                                model,
                                source,
                                closeAction)
                        }
                        else { self.action.send(PaymentsViewModelAction.Dismiss()) }
                        
                    default:
                        self.action.send(PaymentsViewModelAction.Dismiss())
                    }
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
    }
    
    private func bind(operationViewModel: PaymentsOperationViewModel) {
        
        operationViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self else { return }
                
                switch action {
                    
                case _ as PaymentsViewModelAction.ScanQrCode:
                    self.action.send(PaymentsViewModelAction.ScanQrCode())
                    
                case _ as PaymentsViewModelAction.EditName:
                    break
                    //TODO: setup open edit name sheet action
                
                case _ as PaymentsSuccessAction.Button.Repeat:
                    self.content = .operation(operationViewModel)

                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

//MARK: - Types

extension PaymentsViewModel {
    
    struct RootActions {
        
        let dismiss: () -> Void
        let spinner: Spinner
        let alert: (String) -> Void
        
        struct Spinner {
            
            let show: () -> Void
            let hide: () -> Void
        }
    }
    
    var rootActions: RootActions {
        
        return .init(dismiss: { [weak self] in self?.action.send(PaymentsViewModelAction.Dismiss()) },
                     spinner:
                .init(show: { [weak self] in
                    self?.action.send(PaymentsViewModelAction.Spinner.Show()) },
                      hide: { [weak self] in self?.action.send(PaymentsViewModelAction.Spinner.Hide()) }),
                     alert: { [weak self] message in self?.action.send(PaymentsViewModelAction.CriticalAlert(title: "Ошибка", message: message)) })
    }
}

//MARK: - Action

enum PaymentsViewModelAction {
    
    struct Dismiss: Action {}
    
    enum Spinner {
        
        struct Show: Action {}
        struct Hide: Action {}
    }
    
    struct CriticalAlert: Action {
        
        let title: String
        let message: String
    }
    
    struct CloseSuccessView: Action {}
    
    struct ScanQrCode: Action {}
    
    struct EditName: Action {}
    
    struct ContactAbroad: Action {
        
        let source: Payments.Operation.Source
    }
}

extension PaymentsViewModel {
    
    enum Error: LocalizedError {
        case unableRecognizeCategoryForService(Payments.Service)
    }
}

extension PaymentsViewModel {
    
    func notActiveLink(
    ) async {
        
        let viewModel: PaymentsSuccessViewModel = .init(
            paymentSuccess: .init(
                operation: nil,
                parameters: [
                    Payments.ParameterSuccessStatus(status: .error),
                    Payments.ParameterSuccessText(
                        value: "Оплата не активирована",
                        style: .title
                    ),
                    Payments.ParameterSuccessText(
                        value: "Убедитесь, что сотрудник магазина активировал оплату и нажмите “Обновить”",
                        style: .subtitle
                    ),
                    Payments.ParameterButton.init(
                        title: "Обновить",
                        style: .primary,
                        acton: .repeat,
                        placement: .bottom
                    ),
                    Payments.ParameterButton.init(
                        title: "На главный",
                        style: .secondary,
                        acton: .main,
                        placement: .bottom
                    ),
                    Payments.ParameterSuccessIcon(
                        icon: .name("ic72Sbp"),
                        size: .normal,
                        placement: .bottom
                    )
                ]),
            .emptyMock)
        
        bind(successViewModel: viewModel)

        await MainActor.run {
            
            withAnimation {
                content = .linkNotActive(viewModel)
            }
        }
    }
        
    func sourceOperation(
        _ model: Model,
        _ source: Payments.Operation.Source,
        _ closeAction: @escaping () -> Void
    ) {
        Task {
            await MainActor.run { content = .loading }
            do {
                
                let operation = try await model.paymentsOperation(with: source)
                let operationViewModel = PaymentsOperationViewModel(
                    operation: operation,
                    model: model,
                    closeAction: closeAction
                )
                operationViewModel.rootActions = rootActions
                bind(operationViewModel: operationViewModel)
                
                await MainActor.run {
                    
                    withAnimation {
                        content = .operation(operationViewModel)
                    }
                }
            } catch {
                
                LoggerAgent.shared.log(level: .error, category: .ui, message: "Payment with source: \(source) start failed with error: \(error)")
                
                await showErrorAlert(error)
            }
        }
    }
    
    @MainActor
    func showErrorAlert(_ error: Swift.Error) async {
        
        if let mapperError = error as? QrDataMapper.MapperError {
            
            switch mapperError {
                
            case let .mapError(message):
                self.action.send(PaymentsViewModelAction.CriticalAlert(title: "Ошибка", message: "\(message)"))
                
            case .status3122:
                await notActiveLink()
            }
        } else {
            self.action.send(PaymentsViewModelAction.CriticalAlert(title: "Ошибка", message: "\(error.localizedDescription)"))
        }
    }
}
