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
    
    typealias State = Route
    
    @Published private(set) var state: State
    
#warning("informer should be a part of the state, its auto-dismiss should be handled by effect")
    let informer: InformerViewModel
    
    private let prepareSetBankDefault: PrepareSetBankDefault
    private let factory: Factory
    
    private let stateSubject = PassthroughSubject<Route, Never>()
    private let scheduler: AnySchedulerOfDispatchQueue
    private var destinationCancellable: AnyCancellable?
    
    init(
        route: Route = .init(),
        informer: InformerViewModel = .init(),
        prepareSetBankDefault: @escaping PrepareSetBankDefault,
        factory: Factory,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.prepareSetBankDefault = prepareSetBankDefault
        self.factory = factory
        self.state = route
        self.informer = informer
        self.scheduler = scheduler
        
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
        
        let (state, effect) = reduce(state, event)
        stateSubject.send(state)
        
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
        
        guard case let .fastPaymentsSettings(viewModel) = state.destination
        else { return nil }
        
        return viewModel
    }
}

private extension UserAccountViewModel {
    
    func reduce(
        _ state: Route,
        _ event: Event
    ) -> (Route, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .closeAlert:
            state.alert = nil
            effect = .fps(.resetStatus)
            
        case .closeFPSAlert:
            state.alert = nil
            effect = .fps(.resetStatus)
            
        case .dismissFPSDestination:
            //            state.fpsDestination = nil
            effect = .fps(.resetStatus)
            
        case .dismissDestination:
            state.destination = nil
            destinationCancellable = nil
            
        case .dismissRoute:
            state = .init()
            effect = .fps(.resetStatus)
            
        case let .demo(demoEvent):
            let (demoState, demoEffect) = reduce(state, demoEvent)
            state = demoState
            effect = demoEffect.map(Effect.demo)
            
        case let .fps(.updated(fpsStateProjection)):
            (state, effect) = reduce(state, with: fpsStateProjection)
            
        case let .otp(otp):
            switch otp {
            case .prepareSetBankDefault:
                state.alert = nil
                state.isLoading = true
                effect = .otp(.prepareSetBankDefault)
                
            case let .prepareSetBankDefaultResponse(response):
                (state, effect) = update(state, with: response)
            }
        }
        
        return (state, effect)
    }
    
    func update(
        _ state: Route,
        with response: Event.OTP.PrepareSetBankDefaultResponse
    ) -> (Route, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.isLoading = false
        effect = .fps(.resetStatus)
        
        switch response {
        case .success:
            state.fpsDestination = .confirmSetBankDefault
            
        case .connectivityError:
            state.fpsDestination = nil
#warning("direct change of state that is outside of reducer")
            self.informer.set(text: "Ошибка изменения настроек СБП.\nПопробуйте позже.")
            
        case let .serverError(message):
            state.alert = .fpsAlert(.ok(
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
        _ state: State,
        _ event: Event.Demo
    ) -> (State, Effect.Demo?) {
        
        var state = state
        var effect: Effect.Demo?
        
        switch event {
        case let .loaded(loaded):
            state.isLoading = false
            
            switch loaded {
            case .alert:
                state.alert = .alert(.ok(
                    title: "Error",
                    primaryAction: { [weak self] in self?.event(.closeAlert)
                    }
                ))
                
            case .informer:
#warning("direct change of state that is outside of reducer")
                self.informer.set(text: "Demo informer here.")
                
            case .loader:
                break
            }
            
        case let .show(show):
            state.isLoading = true
            
            switch show {
            case .alert:
                effect = .loadAlert
                
            case .informer:
                effect = .loadInformer
                
            case .loader:
                effect = .loader
            }
        }
        
        return (state, effect)
    }
    
    func handleEffect(
        _ effect: Effect.Demo,
        _ dispatch: @escaping (Event.Demo) -> Void
    ) {
        switch effect {
        case .loadAlert:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                dispatch(.loaded(.alert))
            }
            
        case .loadInformer:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                dispatch(.loaded(.informer))
            }
            
        case .loader:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                dispatch(.loaded(.loader))
            }
        }
    }
    
    // MARK: - Fast Payments Settings domain
    
    func reduce(
        _ state: Route,
        with fpsStateProjection: FPSStateProjection
    ) -> (Route, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch (fpsStateProjection.state, fpsStateProjection.status) {
        case (_, .inflight):
            state.isLoading = true
            
        case (.notLoaded, _):
            break
            
        case (.contracted, nil):
            state.isLoading = false
            
        case (.missingContract, nil):
            state.isLoading = false
            state.alert = missingContractFPSAlert()
            
        case let (.contracted, .some(status)),
            let (.missingContract, .some(status)):
            (state, effect) = update(state, with: status)
            
        case let (.failure(failure), _):
            // final => dismissRoute
            switch failure {
            case let .serverError(message):
                state.isLoading = false
                state.alert = serverErrorFPSAlert(message, .dismissRoute)
                
            case .connectivityError:
                state.isLoading = false
                state.alert = tryAgainFPSAlert(.dismissRoute)
            }
        }
        
        return (state, effect)
    }
    
    func update(
        _ state: Route,
        with status: FPSStateProjection.Status
    ) -> (Route, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch status {
        case .inflight:
            state.isLoading = true
            
        case .failure(.connectivityError):
            state.isLoading = false
            // non-final => closeAlert
            state.alert = tryAgainFPSAlert(.closeAlert)
            
        case let .failure(.serverError(message)):
            state.isLoading = false
            // non-final => closeAlert
            state.alert = serverErrorFPSAlert(message, .closeAlert)
            
        case .missingProduct:
            state.isLoading = false
            state.alert = missingProductFPSAlert()
            
        case .confirmSetBankDefault:
            state.fpsDestination = .confirmSetBankDefault
            effect = .fps(.resetStatus)
            
        case .setBankDefault:
            state.alert = setBankDefaultFPSAlert()
            
        case .setBankDefaultSuccess:
            state.isLoading = false
#warning("direct change of state that is outside of reducer")
            self.informer.set(text: "Банк по умолчанию установлен.")
            
        case .updateContractFailure:
            state.isLoading = false
#warning("direct change of state that is outside of reducer")
            self.informer.set(text: "Ошибка изменения настроек СБП.\nПопробуйте позже.")
            state = .init()
        }
        
        return (state, effect)
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
            
            case updated(FPSStateProjection)
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
                
                self?.state.alert = .fpsAlert(.ok(
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
        
        switch state.destination {
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
        state.destination = .fastPaymentsSettings(viewModel)
    }
    
    private func bind(_ viewModel: FastPaymentsSettingsViewModel) {
        
        destinationCancellable = viewModel.$state
            .map(\.projection)
            .removeDuplicates()
            .map(Event.FastPaymentsSettings.updated)
            .receive(on: scheduler)
            .sink { [weak self] in self?.event(.fps($0))}
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
