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
import OTPInputComponent

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
    private var fpsDestinationCancellable: AnyCancellable?
    
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
            handleEffect(otpEffect) { [weak self] in self?.event(.otp($0)) }
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
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
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
            unbindFPSDestination()
            state.fpsDestination = nil
            
        case .dismissDestination:
            unbindDestination()
            state.destination = nil
            
        case .dismissRoute:
            state = .init()
            unbindFPSDestination()
            unbindDestination()
            
        case let .demo(demoEvent):
            let (demoState, demoEffect) = reduce(state, demoEvent)
            state = demoState
            effect = demoEffect.map(Effect.demo)
            
        case let .fps(.updated(fpsState)):
            state = reduce(state, with: fpsState)
            
        case let .otp(otp):
            (state, effect) = reduce(state, with: otp)
        }
        
        return (state, effect)
    }
    
    func update(
        _ state: State,
        with response: Event.OTP.PrepareSetBankDefaultResponse
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        state.isLoading = false
        effect = .fps(.resetStatus)
        
        switch response {
        case .success:
#warning("using factory and the need to subscribe to state changes prevents from making this injectable pure function")
            let otpInputViewModel = factory.makeTimedOTPInputViewModel(scheduler)
            state.fpsDestination = .confirmSetBankDefault(otpInputViewModel)
            bind(fpsDestination: state.fpsDestination)
            
        case .connectivityError:
            state.fpsDestination = nil
#warning("direct change of state that is outside of reducer")
            self.informer.set(text: "Ошибка изменения настроек СБП.\nПопробуйте позже.")
            
        case let .serverError(message):
            state.alert = .fpsAlert(.ok(
                title: "Ошибка",
                message: message,
                action: { [weak self] in self?.event(.closeAlert) }
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
                    action: { [weak self] in self?.event(.closeAlert) }
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
        _ state: State,
        with settings: FastPaymentsSettingsState
    ) -> State {
        
        var state = state
        
        switch (settings.settingsResult, settings.status) {
        case (_, .inflight):
            state.isLoading = true
            
        case (nil, _):
            break
            
        case let (.success(.contracted(contracted)), nil):
            state.isLoading = false
            let message = contracted.bankDefaultResponse.requestLimitMessage
            state.alert = message.map(defaultBankRequestsLimitFPSAlert)
            
        case (.success(.missingContract), nil):
            state.isLoading = false
            state.alert = missingContractFPSAlert()
            
        case let (.success, .some(status)):
            state = update(state, with: status)
            
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
        
        return state
    }
    
    func update(
        _ state: State,
        with status: FastPaymentsSettingsState.Status
    ) -> State {
        
        var state = state
        
        switch status {
        case .inflight:
            state.isLoading = true
            
        case let .getC2BSubResponse(getC2BSubResponse):
            state.isLoading = false
            state.fpsDestination = .c2BSub(getC2BSubResponse)
            
        case .connectivityError:
            state.isLoading = false
            // non-final => closeAlert
            state.alert = tryAgainFPSAlert(.closeAlert)
            
        case let .serverError(message):
            state.isLoading = false
            // non-final => closeAlert
            state.alert = serverErrorFPSAlert(message, .closeAlert)
            
        case .missingProduct:
            state.isLoading = false
            state.alert = missingProductFPSAlert()
            
        case .confirmSetBankDefault:
            // state.fpsDestination = .confirmSetBankDefault
            // effect = .fps(.resetStatus)
            fatalError("what should happen here?")
            
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
        
        return state
    }
    
    func serverErrorFPSAlert(
        _ message: String,
        _ event: Event
    ) -> State.Alert {
        
        .fpsAlert(.ok(
            message: message,
            action: { [weak self] in self?.event(event) }
        ))
    }
    
    func tryAgainFPSAlert(
        _ event: Event
    ) -> State.Alert {
        
        let message = "Превышено время ожидания. Попробуйте позже"
        
        return .fpsAlert(.ok(
            message: message,
            action: { [weak self] in self?.event(event) }
        ))
    }
    
    func defaultBankRequestsLimitFPSAlert(
        _ message: String
    ) -> State.Alert {
        
        
#warning("extract helper as `static AlertViewModel.missingContract(action:)`")
        return         .fpsAlert(.ok(
            title: "Ошибка",
            message: message,
            action: { [weak self] in self?.event(.closeAlert) }
        ))
    }
    
    func missingContractFPSAlert() -> State.Alert {
        
        .fpsAlert(.missingContract(
            action: { [weak self] in self?.event(.closeAlert) }
        ))
    }
    
    func missingProductFPSAlert() -> State.Alert {
        
        .fpsAlert(.missingProduct(
            action: { [weak self] in self?.event(.dismissRoute) }
        ))
    }
    
    func setBankDefaultFPSAlert() -> State.Alert {
        
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
    
    func reduce(
        _ state: State,
        with otp: UserAccountViewModel.Event.OTP
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch otp {
        case let .otpInput(otpInput):
#warning("move nullification to reducer where fps state is reduced")
            unbindFPSDestination()
            state.fpsDestination = nil
            
            switch otpInput {
            case let .failure(failure):
                switch failure {
                case .connectivityError:
                    effect = .fps(.bankDefault(.setBankDefaultPrepared(.connectivityError)))
                    
#warning("should handle with informer not alert `serverError` with message Введен некорректный код. Попробуйте еще раз")
                case let .serverError(message):
                    effect = .fps(.bankDefault(.setBankDefaultPrepared(.serverError(message))))
                }
            case .validOTP:
                effect = .fps(.bankDefault(.setBankDefaultPrepared(nil)))
            }
            
        case .prepareSetBankDefault:
            state.alert = nil
            state.isLoading = true
            effect = .otp(.prepareSetBankDefault)
            
        case let .prepareSetBankDefaultResponse(response):
            (state, effect) = update(state, with: response)
        }
        
        return (state, effect)
    }
    
    func handleEffect(
        _ otpEffect: Effect.OTP,
        _ dispatch: @escaping (Event.OTP) -> Void
    ) {
        switch otpEffect {
        case .prepareSetBankDefault:
            prepareSetBankDefault { result in
                
                switch result {
                case .success(()):
                    dispatch(.prepareSetBankDefaultResponse(.success))
                    
                case .failure(.connectivityError):
                    dispatch(.prepareSetBankDefaultResponse(.connectivityError))
                    
                case let .failure(.serverError(message)):
                    dispatch(.prepareSetBankDefaultResponse(.serverError(message)))
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
            action: action
        )
    }
    
    static func missingProduct(
        action: @escaping () -> Void
    ) -> Self {
        
        .ok(
            title: "Сервис не доступен",
            message: "Для подключения договора СБП у Вас должен быть подходящий продукт",
            action: action
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
            
            case updated(FastPaymentsSettingsState)
        }
        
        enum OTP: Equatable {
            
            case otpInput(OTPInputStateProjection)
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
                    action: { [weak self] in self?.event(.closeFPSAlert) }
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
    
#warning("move to `reduce`")
    func openFastPaymentsSettings() {
        
        let fpsViewModel = factory.makeFastPaymentsSettingsViewModel(scheduler)
        state.destination = .fastPaymentsSettings(fpsViewModel)
        bind(state.destination)
#warning("and change to effect (??) when moved to `reduce`")
        fpsViewModel.event(.appear)
    }
}

// MARK: - Bind Destinations

private extension UserAccountViewModel {
    
    func bind(
        _ destination: State.Destination? = nil,
        fpsDestination: State.FPSDestination? = nil
    ) {
        switch destination {
        case .none:
            break
            
        case let .fastPaymentsSettings(fastPaymentsSettings):
            destinationCancellable = fastPaymentsSettings.$state
                .removeDuplicates()
                .map(Event.FastPaymentsSettings.updated)
                .receive(on: scheduler)
                .sink { [weak self] in self?.event(.fps($0)) }
        }
        
        switch fpsDestination {
        case .none:
            break
            
        case let .c2BSub(c2BSub):
            break
            
        case let .confirmSetBankDefault(confirmSetBankDefault):
            fpsDestinationCancellable = confirmSetBankDefault.$state
                .compactMap(\.projection)
                .removeDuplicates()
                .map(Event.OTP.otpInput)
                .receive(on: scheduler)
                .sink { [weak self] in self?.event(.otp($0))}
        }
    }
    
    func unbindDestination() {
        
        destinationCancellable?.cancel()
        destinationCancellable = nil
    }
    
    func unbindFPSDestination() {
        
        fpsDestinationCancellable?.cancel()
        fpsDestinationCancellable = nil
    }
}

// MARK: - OTP for Fast Payments Settings

enum OTPInputStateProjection: Equatable {
    
    case failure(OTPInputComponent.ServiceFailure)
    case validOTP
}

extension OTPInputState {
    
    var projection: OTPInputStateProjection? {
        
        switch self {
        case let .failure(otpFieldFailure):
            switch otpFieldFailure {
            case .connectivityError:
                return .failure(.connectivityError)
                
            case let .serverError(message):
                return .failure(.serverError(message))
            }
            
        case .input:
            return nil
            
        case .validOTP:
            return .validOTP
        }
    }
}

private extension AlertViewModel {
    
    static func ok(
        title: String = "",
        message: String? = nil,
        action: @escaping () -> Void
    ) -> Self {
        
        self.init(
            title: title,
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                action: action
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
            
            case confirmSetBankDefault(TimedOTPInputViewModel)//(phoneNumberMask: String)
            case c2BSub(GetC2BSubResponse)
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

extension UserAccountViewModel.Route.FPSDestination: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        
        switch (lhs, rhs) {
        case let (.confirmSetBankDefault(lhs), .confirmSetBankDefault(rhs)):
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
            
        case let (.c2BSub(lhs), .c2BSub(rhs)):
            return lhs == rhs
            
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .confirmSetBankDefault(viewModel):
            hasher.combine(ObjectIdentifier(viewModel))
            
        case let .c2BSub(getC2BSubResponse):
            hasher.combine(getC2BSubResponse)
        }
    }
}

extension GetC2BSubResponse: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        
        hasher.combine(self)
    }
}
