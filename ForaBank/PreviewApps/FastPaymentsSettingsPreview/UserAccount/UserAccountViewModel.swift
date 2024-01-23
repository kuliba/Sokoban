//
//  UserAccountViewModel.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Combine
import CombineSchedulers
import FastPaymentsSettings
import Foundation

final class UserAccountViewModel: ObservableObject {
    
    @Published private(set) var state: State
    @Published private(set) var route: Route
    
    let informer: InformerViewModel
    
    private let routeSubject = PassthroughSubject<Route, Never>()
    private let stateSubject = PassthroughSubject<State, Never>()
    private let factory: Factory
    private var cancellables = Set<AnyCancellable>()
    
    init(
        state: State = .init(),
        route: Route = .init(),
        informer: InformerViewModel = .init(),
        factory: Factory,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = state
        self.route = route
        self.informer = informer
        self.factory = factory
        
        routeSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$route)
        
        stateSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

extension UserAccountViewModel {
        
    func event(_ event: Event) {
        
        let (modelState, effect) = reduce((route, state), event)
        routeSubject.send(modelState.route)
        stateSubject.send(modelState.state)
        
        if let effect {
            
            handleEffect(effect) { [weak self] in self?.event($0) }
        }
    }

    typealias ModelState = (route: Route, state: State)
    
    private func reduce(
        _ modelState: ModelState,
        _ event: Event
    ) -> (ModelState, Effect?) {
        
        var modelState = modelState
        var modelEffect: Effect?
        
        let (state, effect) = reduce(modelState.state, event)
        
        switch state.status {
        case .none:
            modelState.route.modal = nil
            modelState.route.isLoading = false
            
        case .showingAlert:
            modelState.route.modal = .alert(.ok(
                title: "Demo alert",
                message: "Long alert message here.",
                primaryAction: { [weak self] in self?.event(.closeAlert) }
            ))
            modelState.route.isLoading = false
            
        case .showingInformer:
            modelState.route.modal = nil
            modelState.route.isLoading = false
            informer.set(text: "Demo Informer Text.")
            
        case .showingLoader:
            modelState.route.isLoading = true
        }
        
        modelEffect = effect
        
        return (modelState, modelEffect)
    }
}

private extension UserAccountViewModel {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .demo(demo):
            let (status, demoEffect) = reduce(state.status, demo)
            state.status = status
            effect = demoEffect.map(Effect.demo)
            
        case .closeAlert:
            state.status = nil
        }
        
        return (state, effect)
    }
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping (Event) -> Void
    ) {
        switch effect {
        case let .demo(demoEffect):
            handleEffect(demoEffect) { dispatch(.demo($0)) }
        }
    }
}

// MARK: - to be injected

private extension UserAccountViewModel {
    
    // demo domain
    func reduce(
        _ status: State.Status?,
        _ event: Event.Demo
    ) -> (State.Status?, Effect.Demo?) {
        
        var status = status
        var effect: Effect.Demo?
        
        switch event {
        case let .loaded(loaded):
            switch loaded {
            case .alert:
                status = .showingAlert
                
            case .informer:
                status = .showingInformer
                
            case .loader:
                status = nil
            }
            
        case let .show(show):
            switch show {
            case .alert:
                status = .showingLoader
                effect = .loadAlert
                
            case .informer:
                status = .showingLoader
                effect = .loadInformer
                
            case .loader:
                status = .showingLoader
                effect = .loader
            }
        }
        
        return (status, effect)
    }

    // demo domain
    func handleEffect(
        _ effect: Effect.Demo,
        _ dispatch: @escaping (Event.Demo) -> Void
    ) {
        switch effect {
        case .loadAlert:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                dispatch(.loaded(.alert))
            }
            
        case .loadInformer:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                dispatch(.loaded(.informer))
            }

        case .loader:
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                dispatch(.loaded(.loader))
            }
        }
    }
}

extension UserAccountViewModel {
    
    struct State: Equatable {
        
        var status: Status?
        
        enum Status: Equatable {
            
            case showingAlert
            case showingInformer
            case showingLoader
        }
    }
    
    enum Event: Equatable {
        
        case closeAlert
        case demo(Demo)
        
        enum Demo: Equatable {
            
            case loaded(Show)
            case show(Show)
            
            enum Show: Equatable {
                case alert
                case informer
                case loader
            }
        }
    }
    
    enum Effect: Equatable {
        
        case demo(Demo)
        
        enum Demo: Equatable {
            
            case loadAlert
            case loadInformer
            case loader
        }
    }
}

// MARK: - Demo Functionality

extension UserAccountViewModel {
    
    func showDemoAlert() {
        
        event(.demo(.show(.alert)))
    }
    
    func showDemoInformer() {
        
        event(.demo(.show(.informer)))
    }
    
    func showDemoLoader() {
        
        event(.demo(.show(.loader)))
    }
}

// MARK: - Confirm with OTP

extension UserAccountViewModel {
    
    func handleOTPResult(
        _ result: ConfirmWithOTPResult
    ) {
        dismissFPSDestination()
        fpsViewModel?.event(.resetStatus)
        
        switch result {
        case .success:
            informer.set(text: "Банк по умолчанию установлен")
            fpsViewModel?.event(.bankDefault(.setBankDefaultPrepared(nil)))
            
        case .incorrectCode:
            informer.set(text: "Банк по умолчанию не установлен")
            
        case let .serverError(message):
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                
                self?.route.modal = .fpsAlert(.ok(
                    title: "Ошибка",
                    message: message,
                    primaryAction: { [weak self] in self?.dismissModal() }
                ))
            }
            
        case .connectivityError:
            informer.set(text: "Ошибка изменения настроек СБП.\nПопробуйте позже.")
        }
    }
}

private extension UserAccountViewModel {
    
    var fpsViewModel: FastPaymentsSettingsViewModel? {
        
        switch route.destination {
        case let .fastPaymentsSettings(fpsViewModel):
            return fpsViewModel
            
        default:
            return nil
        }
    }
}

// MARK: - Fast Payments Settings

extension UserAccountViewModel {
    
    func openFastPaymentsSettings() {
        
        let viewModel = factory.makeFastPaymentsSettingsViewModel()
        bind(viewModel)
        route.destination = .fastPaymentsSettings(viewModel)
    }
    
    private func bind(_ viewModel: FastPaymentsSettingsViewModel) {
        
#warning("combine multiple pipelines into one, extract composed sink into helpers")
        
        viewModel.$state
            .map(\.isInflight)
            .sink { [weak self] in self?.route.isLoading = $0 }
            .store(in: &cancellables)
        
        viewModel.$state
            .compactMap(\.alertMessage)
            .sink { [weak self] in
                
                self?.route.modal = .fpsAlert(.ok(
                    message: $0,
                    primaryAction: {
                        
                        self?.dismissModal()
                        viewModel.event(.resetStatus)
                    }
                ))
            }
            .store(in: &cancellables)
        
        viewModel.$state
            .compactMap(\.finalAlertMessage)
            .sink { [weak self] in
                
                self?.route.modal = .fpsAlert(.ok(
                    message: $0,
                    primaryAction: {
                        
                        self?.resetRoute()
#warning("resetStatus is needed?")
                        // viewModel.event(.resetStatus)
                    }
                ))
            }
            .store(in: &cancellables)
        
        viewModel.$state
            .compactMap(\.informer)
            .sink { [weak self] informer in
                
                self?.informer.set(text: "Ошибка изменения настроек СБП.\nПопробуйте позже.")
#warning("resetStatus is needed?")
                // viewModel.event(.resetStatus)
            }
            .store(in: &cancellables)
        
        viewModel.$state
            .compactMap(\.missingProduct)
            .sink { [weak self] in
                
                self?.route.modal = .fpsAlert(.ok(
                    title: "Сервис не доступен",
                    message: "Для подключения договора СБП у Вас должен быть подходящий продукт",
                    primaryAction: {
                        
                        self?.resetRoute()
                        viewModel.event(.resetStatus)
                    }
                ))
            }
            .store(in: &cancellables)
        
        viewModel.$state
            .compactMap(\.setBankDefault)
            .sink { [weak self] in
                
                self?.route.modal = .fpsAlert(.init(
                    title: "Внимание",
                    message: "Фора-банк будет выбран банком по умолчанию",
                    primaryButton: .init(
                        type: .default,
                        title: "OK",
                        action: {
                            
                            self?.dismissModal()
                            viewModel.event(.resetStatus)
                            viewModel.event(.bankDefault(.prepareSetBankDefault))
                        }),
                    secondaryButton: .init(
                        type: .cancel,
                        title: "Отмена",
                        action: {
                            
                            self?.dismissModal()
                            viewModel.event(.resetStatus)
                        }
                    )
                ))
            }
            .store(in: &cancellables)
        
        viewModel.$state
            .compactMap(\.confirmSetBankDefault)
            .sink { [weak self] in
                
                viewModel.event(.resetStatus)
                self?.route.fpsDestination = .confirmSetBankDefault
            }
            .store(in: &cancellables)
    }
}

private extension AlertViewModel {
    
    static func ok(
        title: String = "",
        message: String? = nil,
        primaryAction: @escaping () -> Void
    ) -> Self {
        
        self.init(
            title: title,
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                action: primaryAction
            )
        )
    }
}

private extension FastPaymentsSettingsState {
    
    var alertMessage: String? {
        
        switch status {
        case let .serverError(message):
            return message
            
        case .connectivityError:
            return "Превышено время ожидания. Попробуйте позже"
            
        default:
            return nil
        }
    }
    
    var finalAlertMessage: String? {
        
        switch userPaymentSettings {
        case let .failure(.serverError(message)):
            return message
            
        case .failure(.connectivityError):
            return "Превышено время ожидания. Попробуйте позже"
            
        default:
            return nil
        }
    }
    
    var informer: Void? {
        
        switch status {
        case .updateContractFailure:
            return ()
            
        default:
            return nil
        }
    }
    
    var isInflight: Bool { status == .inflight }
    
    var missingProduct: Void? {
        
        switch status {
        case .missingProduct:
            return ()
            
        default:
            return nil
        }
    }
    
    var setBankDefault: Void? {
        
        switch status {
        case .setBankDefault:
            return ()
            
        default:
            return nil
        }
    }
    
    var confirmSetBankDefault: Void? {
        
        switch status {
        case .confirmSetBankDefault:
#warning("need `phoneNumberMask` from contract!")
            return ()
            
        default:
            return nil
        }
    }
}

extension UserAccountViewModel {
    
    func resetRoute() {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.route = .init()
        }
    }
    
    func dismissDestination() {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.route.destination = nil
        }
    }
    
    func dismissFPSDestination() {
        
        //        DispatchQueue.main.async { [weak self] in
        
        /*self?.*/route.fpsDestination = nil
        //        }
    }
    
    func dismissModal() {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.route.modal = nil
        }
    }
}

extension UserAccountViewModel {
    
    struct Route: Equatable {
        
        var destination: Destination?
        var fpsDestination: FPSDestination?
        var modal: Modal?
        var isLoading = false
        
        init(
            destination: Destination? = nil,
            modal: Modal? = nil
        ) {
            self.destination = destination
            self.modal = modal
        }
        
        enum Destination: Equatable {
            
            case fastPaymentsSettings(FastPaymentsSettingsViewModel)
        }
        
        enum FPSDestination: Equatable {
            
            case confirmSetBankDefault//(phoneNumberMask: String)
        }
        
        enum Modal: Equatable {
            
            case alert(AlertViewModel)
            case fpsAlert(AlertViewModel)
            
            var alert: AlertViewModel? {
                
                if case let .alert(alert) = self {
                    return alert
                } else {
                    return nil
                }
            }
            
            var fpsAlert: AlertViewModel? {
                
                if case let .fpsAlert(fpsAlert) = self {
                    return fpsAlert
                } else {
                    return nil
                }
            }
        }
    }
}

extension UserAccountViewModel.Route.Destination: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        
        switch (lhs, rhs) {
        case let (.fastPaymentsSettings(lhs), .fastPaymentsSettings(rhs)):
            ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .fastPaymentsSettings(viewModel):
            hasher.combine(ObjectIdentifier(viewModel))
        }
    }
}
