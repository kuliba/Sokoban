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
    
    private let prepareSetBankDefault: PrepareSetBankDefault
    private let factory: Factory
    
    private let routeSubject = PassthroughSubject<Route, Never>()
    private let stateSubject = PassthroughSubject<State, Never>()
    private let scheduler: AnySchedulerOfDispatchQueue
    private var cancellables = Set<AnyCancellable>()
    
    init(
        state: State = .init(),
        route: Route = .init(),
        informer: InformerViewModel = .init(),
        prepareSetBankDefault: @escaping PrepareSetBankDefault,
        factory: Factory,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = state
        self.prepareSetBankDefault = prepareSetBankDefault
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
    
    typealias PrepareSetBankDefault = FastPaymentsSettingsEffectHandler.PrepareSetBankDefault
}

extension UserAccountViewModel {
    
    func event(_ event: Event) {
        
        let (modelState, effect) = reduce((route, state), event)
        routeSubject.send(modelState.route)
        stateSubject.send(modelState.state)
        
        if let effect {
            
            handleEffect(effect)
        }
    }
    
    func handleEffect(_ effect: Effect) {
        
        switch effect {
        case let .demo(demoEffect):
            handleEffect(demoEffect) { [weak self] in self?.event(.demo($0)) }
            
        case let .fps(fpsEvent):
            fpsDispatch?(fpsEvent)
            
        case let .otp(otpEffect):
            handleEffect(otpEffect) { [weak self] in self?.event($0) }
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
        
        var state = modelState
        var eEffect: Effect?
        
        switch event {
        case .closeAlert:
            state.route.alert = nil
            eEffect = .fps(.resetStatus)
            
        case .closeFPSAlert:
            state.route.alert = nil
            eEffect = .fps(.resetStatus)
            
        case .dismissFPSDestination:
//            state.route.fpsDestination = nil
            eEffect = .fps(.resetStatus)
            
        case .dismissDestination:
            state.route.destination = nil
            eEffect = .fps(.resetStatus)
            
        case .dismissRoute:
            state.route = .init()
            eEffect = .fps(.resetStatus)
            
        case let .demo(demoEvent):
            let (status, demoEffect) = reduce(state.state.status, demoEvent)
            state.state.status = status
            eEffect = demoEffect.map(Effect.demo)
            
        case let .fps(.updated(fpsState)):
            (state, eEffect) = reduce(state, with: fpsState)
            
        case let .otp(otp):
            switch otp {
            case .prepareSetBankDefault:
                state.route.alert = nil
                state.route.isLoading = true
                eEffect = .otp(.prepareSetBankDefault)
                
            case let .prepareSetBankDefaultResponse(response):
                (state, eEffect) = update(state, with: response)
            }
        }
        
        return (state, eEffect)
    }
    
    func update(
        _ state: ModelState,
        with response: Event.OTP.PrepareSetBankDefaultResponse
    ) -> (ModelState, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.route.isLoading = false
        effect = .fps(.resetStatus)
        
        switch response {
        case .success:
            state.route.fpsDestination = .confirmSetBankDefault
            
        case .connectivityError:
            state.route.fpsDestination = nil
#warning("direct change of state that is outside of reducer")
            self.informer.set(text: "Ошибка изменения настроек СБП.\nПопробуйте позже.")
            
        case let .serverError(message):
            state.route.alert = .fpsAlert(.ok(
                title: "Ошибка",
                message: message,
                primaryAction: { [weak self] in self?.event(.closeAlert) }
            ))
        }
        
        return (state, effect)
    }
}

// MARK: - to be injected

private extension UserAccountViewModel {
    
    // MARK: - Demo Domain
    
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
        case .none:
            break
            
        case .contracted:
            #warning("looks like status should be part of contracted???")
            (modelState, effect) = update(modelState, with: fpsState.status)
            
        case let .failure(failure):
            // final => dismissRoute
            switch failure {
            case let .serverError(message):
                modelState.route.isLoading = false
                modelState.route.alert = serverErrorFPSAlert(message, .dismissRoute)
                
            case .connectivityError:
                modelState.route.isLoading = false
                modelState.route.alert = tryAgainFPSAlert(.dismissRoute)
            }
            
        case .missingContract:
            modelState.route.isLoading = false
            modelState.route.alert = missingContractFPSAlert()
        }
        
        return (modelState, effect)
    }
    
    func update(
        _ modelState: ModelState,
        with status: FastPaymentsSettingsState.Status?
    ) -> (ModelState, Effect?) {
        
        var modelState = modelState
        var effect: Effect?
        
        switch status {
        case .none:
            modelState.state.status = nil
            modelState.route.fpsDestination = nil
            modelState.route.alert = nil
            modelState.route.isLoading = false
            
        case .inflight:
            modelState.route.isLoading = true
            
        case let .serverError(message):
            modelState.route.isLoading = false
            // non-final => closeAlert
            modelState.route.alert = serverErrorFPSAlert(message, .closeAlert)
            
        case .connectivityError:
            modelState.route.isLoading = false
            // non-final => closeAlert
            modelState.route.alert = tryAgainFPSAlert(.closeAlert)
            
        case .missingProduct:
            modelState.route.isLoading = false
            modelState.route.alert = missingProductFPSAlert()
            
        case .updateContractFailure:
            modelState.route.isLoading = false
#warning("direct change of state that is outside of reducer")
            self.informer.set(text: "Ошибка изменения настроек СБП.\nПопробуйте позже.")
            modelState.route = .init()
            
        case .setBankDefault:
            modelState.route.alert = setBankDefaultFPSAlert()
            
        case .setBankDefaultSuccess:
            modelState.route.isLoading = false
#warning("direct change of state that is outside of reducer")
            self.informer.set(text: "Банк по умолчанию установлен.")
            
        case .confirmSetBankDefault:
            route.fpsDestination = .confirmSetBankDefault
            effect = .fps(.resetStatus)
        }
        
        return (modelState, effect)
    }
    
    func serverErrorFPSAlert(
        _ message: String,
        _ event: Event
    ) -> Route.Alert {
        
        .fpsAlert(.ok(
            message: message,
            primaryAction: { [weak self] in self?.event(event) }
        ))
    }
    
    func tryAgainFPSAlert(
        _ event: Event
    ) -> Route.Alert {
        
        let message = "Превышено время ожидания. Попробуйте позже"
        
        return .fpsAlert(.ok(
            message: message,
            primaryAction: { [weak self] in self?.event(event) }
        ))
    }
    
    func missingContractFPSAlert() -> Route.Alert {
        
        .fpsAlert(.missingContract(
            action: { [weak self] in self?.event(.closeAlert) }
        ))
    }
    
    func missingProductFPSAlert() -> Route.Alert {
        
        .fpsAlert(.missingProduct(
            action: { [weak self] in self?.event(.dismissRoute) }
        ))
    }
    
    func setBankDefaultFPSAlert() -> Route.Alert {
        
        .fpsAlert(.setBankDefault(
            primaryAction: { [weak self] in
                
                self?.event(.otp(.prepareSetBankDefault))
            },
            secondaryAction: { [weak self] in
                
                self?.event(.closeAlert)
            }
        ))
    }
    
    // MARK: - OTP Domain
    
    func handleEffect(
        _ otpEffect: Effect.OTP,
        _ dispatch: @escaping (Event) -> Void
    ) {
        switch otpEffect {
        case .prepareSetBankDefault:
            prepareSetBankDefault { result in
                
                switch result {
                case .success(()):
                    dispatch(.otp(.prepareSetBankDefaultResponse(.success)))
                    
                case .failure(.connectivityError):
                    dispatch(.otp(.prepareSetBankDefaultResponse(.connectivityError)))
                    
                case let .failure(.serverError(message)):
                    dispatch(.otp(.prepareSetBankDefaultResponse(.serverError(message))))
                }
            }
        }
    }
}

private extension AlertViewModel {
    
    static func missingContract(
        action: @escaping () -> Void
    ) -> Self {
        
        .ok(
            title: "Не найден договор СБП",
            message: "Договор будет создан автоматически, если Вы включите переводы через СБП",
            primaryAction: action
        )
    }
    
    static func missingProduct(
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
        case closeFPSAlert
        case dismissFPSDestination
        case dismissDestination
        case dismissRoute
        
        case demo(Demo)
        
        case fps(FastPaymentsSettings)
        
        case otp(OTP)
        
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
            
            case updated(FastPaymentsSettingsState)
        }
        
        enum OTP: Equatable {
            
            case prepareSetBankDefault
            case prepareSetBankDefaultResponse(PrepareSetBankDefaultResponse)
            
            enum PrepareSetBankDefaultResponse: Equatable {
                
                case success
                case connectivityError
                case serverError(String)
            }
        }
    }
    
    enum Effect: Equatable {
        
        case demo(Demo)
        case fps(FastPaymentsSettingsEvent)
        case otp(OTP)
        
        enum Demo: Equatable {
            
            case loadAlert
            case loadInformer
            case loader
        }
        
        enum OTP: Equatable {
            
            case prepareSetBankDefault
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
        event(.dismissFPSDestination)
        fpsViewModel?.event(.resetStatus)
        
        switch result {
        case .success:
            informer.set(text: "Банк по умолчанию установлен")
            fpsViewModel?.event(.bankDefault(.setBankDefaultPrepared(nil)))
            
        case .incorrectCode:
            informer.set(text: "Банк по умолчанию не установлен")
            
        case let .serverError(message):
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                
                self?.route.alert = .fpsAlert(.ok(
                    title: "Ошибка",
                    message: message,
                    primaryAction: { [weak self] in self?.event(.closeFPSAlert) }
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
    
    struct Route: Equatable {
        
        var destination: Destination?
        var fpsDestination: FPSDestination?
        var alert: Alert?
        var isLoading = false
        
        init(
            destination: Destination? = nil,
            modal: Alert? = nil
        ) {
            self.destination = destination
            self.alert = modal
        }
        
        enum Destination: Equatable {
            
            case fastPaymentsSettings(FastPaymentsSettingsViewModel)
        }
        
        enum FPSDestination: Equatable {
            
            case confirmSetBankDefault//(phoneNumberMask: String)
        }
        
        enum Alert: Equatable {
            
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
