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
    
#warning("informer should be a part of the state, its auto-dismiss should be handled by effect")
    let informer: InformerViewModel
    
    private let factory: Factory
    
    private let routeSubject = PassthroughSubject<Route, Never>()
    private let stateSubject = PassthroughSubject<State, Never>()
    private let scheduler: AnySchedulerOfDispatchQueue
    private var cancellables = Set<AnyCancellable>()
    
    init(
        state: State = .init(),
        route: Route = .init(),
        informer: InformerViewModel = .init(),
        factory: Factory,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = state
        self.factory = factory
        self.route = route
        self.informer = informer
        self.scheduler = scheduler
        
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
            
            switch effect {
            case let .fps(fpsEvent):
                fpsDispatch?(fpsEvent)
                
            case let .demo(demoEffect):
                handleEffect(demoEffect) { [weak self] in self?.event(.demo($0)) }
            }
        }
    }
    
    private var fpsDispatch: ((FastPaymentsSettingsEvent) -> Void)? {
        
        fastPaymentsSettingsViewModel?.event(_:)
    }
    
    private var fastPaymentsSettingsViewModel: FastPaymentsSettingsViewModel? {
        
        guard case let .fastPaymentsSettings(viewModel) = route.destination
        else { return nil }
        
        return viewModel
    }
}

private extension UserAccountViewModel {
    
    typealias ModelState = (route: Route, state: State)
    
    func reduce(
        _ modelState: ModelState,
        _ event: Event
    ) -> (ModelState, Effect?) {
        
        var modelState = modelState
        var modelEffect: Effect?
        
        switch event {
        case .closeAlert:
            modelState.route.modal = nil
            modelEffect = .fps(.resetStatus)
            
        case .dismissRoute:
            modelState.route = .init()
            modelEffect = .fps(.resetStatus)
            
        case let .demo(demoEvent):
            let (status, demoEffect) = reduce(modelState.state.status, demoEvent)
            modelState.state.status = status
            modelEffect = demoEffect.map(Effect.demo)
            
        case let .fps(fps):
            switch fps {
            case .prepareSetBankDefault:
                modelEffect = .fps(.bankDefault(.prepareSetBankDefault))
                
            case let .updated(fpsState):
                (modelState, modelEffect) = reduce(modelState, with: fpsState)
            }
        }
        
        return (modelState, modelEffect)
    }
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping (Event) -> Void
    ) {
        switch effect {
        case let .fps(fpsEvent):
#warning("duplication?")
            fpsDispatch?(fpsEvent)
            
        case let .demo(demoEffect):
            handleEffect(demoEffect) { dispatch(.demo($0)) }
        }
    }
}

// MARK: - to be injected

private extension UserAccountViewModel {
    
    // MARK: - demo domain
    
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
    
    // MARK: - Fast Payments Settings domain
    
    func reduce(
        _ modelState: ModelState,
        with fpsState: FastPaymentsSettingsState
    ) -> (ModelState, Effect?) {
        
        var modelState = modelState
        var effect: Effect?
        
        switch fpsState.userPaymentSettings {
            
        case let .failure(failure):
#warning("extract to helper")
            // final
            switch failure {
            case let .serverError(message):
                modelState.route.isLoading = false
                modelState.route.modal = .fpsAlert(.ok(
                    message: message,
                    primaryAction: { [weak self] in
                        
                        self?.event(.dismissRoute)
                    }
                ))
                
            case .connectivityError:
                modelState.route.isLoading = false
                let message = "Превышено время ожидания. Попробуйте позже"
                modelState.route.modal = .fpsAlert(.ok(
                    message: message,
                    primaryAction: { [weak self] in
                        
                        self?.event(.dismissRoute)
                    }
                ))
            }
            
        case .missingContract:
            modelState.route.isLoading = false
            modelState.route.modal = .fpsAlert(.ok(
                title: "Не найден договор СБП",
                message: "Договор будет создан автоматически, если Вы включите переводы через СБП",
                primaryAction: { [weak self] in
                    
                    self?.event(.closeAlert)
                }
            ))
            
        default:
            switch fpsState.status {
            case .none:
                modelState.state.status = nil
                modelState.route.isLoading = false
                
            case .inflight:
                modelState.route.isLoading = true
                
#warning("there is final & non-final alerts, see file at sha d476879f0ddd56b9ddb7103b87941ff0e00a8695")
            case let .serverError(message):
                modelState.route.isLoading = false
                modelState.route.modal = serverError(message)
                
            case .connectivityError:
                modelState.route.isLoading = false
                modelState.route.modal = tryAgain()
                
            case .missingProduct:
                modelState.route.isLoading = false
                modelState.route.modal = missingDefaultBank()
                
            case .updateContractFailure:
#warning("direct change of state that is outside of reducer")
                self.informer.set(text: "Ошибка изменения настроек СБП.\nПопробуйте позже.")
                modelState.route = .init()
                
            case .setBankDefault:
                modelState.route.modal = setBankDefault()
                
            case .setBankDefaultSuccess:
#warning("direct change of state that is outside of reducer")
                self.informer.set(text: "Банк по умолчанию установлен.")
                
            case .confirmSetBankDefault:
                route.fpsDestination = .confirmSetBankDefault
                effect = .fps(.resetStatus)
            }
        }
        
        return (modelState, effect)
    }
    
    func serverError(
        _ message: String
    ) -> Route.Modal {
        
        .fpsAlert(.ok(
            message: message,
            primaryAction: { [weak self] in
                
                self?.event(.closeAlert)
            }
        ))
    }
    
    func tryAgain() -> Route.Modal {
        
        let message = "Превышено время ожидания. Попробуйте позже"
        
        return .fpsAlert(.ok(
            message: message,
            primaryAction: { [weak self] in
                
                self?.event(.closeAlert)
            }
        ))
    }
    
    func missingDefaultBank() -> Route.Modal {
        
        .fpsAlert(.missingDefaultBank(
            action: { [weak self] in
                
                self?.event(.dismissRoute)
            }
        ))
    }
    
    func setBankDefault() -> Route.Modal {
        
        .fpsAlert(.setBankDefault(
            primaryAction: { [weak self] in
                
                self?.event(.fps(.prepareSetBankDefault))
            },
            secondaryAction: { [weak self] in
                
                self?.event(.closeAlert)
            }
        ))
    }
}

private extension AlertViewModel {
    
    static func missingDefaultBank(
        action: @escaping () -> Void
    ) -> Self {
        
        .ok(
            title: "Сервис не доступен",
            message: "Для подключения договора СБП у Вас должен быть подходящий продукт",
            primaryAction: action
        )
    }
    
    static func setBankDefault(
        primaryAction: @escaping () -> Void,
        secondaryAction: @escaping () -> Void
    ) -> Self {
        
        .init(
            title: "Внимание",
            message: "Фора-банк будет выбран банком по умолчанию",
            primaryButton: .init(
                type: .default,
                title: "OK",
                action: primaryAction),
            secondaryButton: .init(
                type: .cancel,
                title: "Отмена",
                action: secondaryAction
            )
        )
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
        case dismissRoute
        
        case demo(Demo)
        
        case fps(FastPaymentsSettings)
        
        enum Demo: Equatable {
            
            case loaded(Show)
            case show(Show)
            
            enum Show: Equatable {
                case alert
                case informer
                case loader
            }
        }
        
        enum FastPaymentsSettings: Equatable {
            
            case prepareSetBankDefault
            case updated(FastPaymentsSettingsState)
        }
    }
    
    enum Effect: Equatable {
        
        case demo(Demo)
        case fps(FastPaymentsSettingsEvent)
        
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
        
        viewModel.$state
            .map(Event.FastPaymentsSettings.updated)
            .receive(on: scheduler)
            .sink { [weak self] in self?.event(.fps($0))}
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

extension UserAccountViewModel {
    
    func resetRoute() {
        
        routeSubject.send(.init())
    }
    
    func dismissDestination() {
        
        var route = route
        route.destination = nil
        routeSubject.send(route)
    }
    
    func dismissFPSDestination() {
        
        var route = route
        route.fpsDestination = nil
        routeSubject.send(route)
    }
    
    func dismissModal() {
        
        var route = route
        route.modal = nil
        routeSubject.send(route)
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
