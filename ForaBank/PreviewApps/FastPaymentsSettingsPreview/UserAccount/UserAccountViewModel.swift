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
import UIPrimitives

final class UserAccountViewModel: ObservableObject {
    
    @Published private(set) var state: State
    
#warning("informer should be a part of the state, its auto-dismiss should be handled by effect")
    let informer: InformerViewModel
    
    private let prepareSetBankDefault: PrepareSetBankDefault
    private let factory: Factory
    
    private let stateSubject = PassthroughSubject<State, Never>()
    private let scheduler: AnySchedulerOfDispatchQueue
    private var destinationCancellable: AnyCancellable?
    private var fpsDestinationCancellable: AnyCancellable?
    
    init(
        route: State = .init(),
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
        
        fpsViewModel?.event(_:)
    }
    
    private var fpsViewModel: FastPaymentsSettingsViewModel? {
        
        guard case let .fastPaymentsSettings(viewModel, _) = state.destination
        else { return nil }
        
        return viewModel
    }
}

// MARK: - Fast Payments Settings

extension UserAccountViewModel {
    
#warning("move to `reduce`")
    func openFastPaymentsSettings() {
        
        let fpsViewModel = factory.makeFastPaymentsSettingsViewModel(scheduler)
        let cancellable = fpsViewModel.$state
            .removeDuplicates()
            .map(Event.FastPaymentsSettings.updated)
            .receive(on: scheduler)
            .sink { [weak self] in self?.event(.fps($0)) }
        
        state.destination = .fastPaymentsSettings(fpsViewModel, cancellable)
#warning("and change to effect (??) when moved to `reduce`")
        fpsViewModel.event(.appear)
    }
}

// MARK: - to be injected

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
            state.fpsDestination = nil
            
        case .dismissDestination:
            state.destination = nil
            
        case .dismissRoute:
            state = .init()
            
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
}

private extension UserAccountViewModel {
    
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
            state.alert = message.map { .fpsAlert(.error(
                message: $0,
                event: .closeAlert
            )) }
            
        case (.success(.missingContract), nil):
            state.isLoading = false
            state.alert = .fpsAlert(.missingContract(event: .closeAlert))
            
        case let (.success, .some(status)):
            state = update(state, with: status)
            
        case let (.failure(failure), _):
            // final => dismissRoute
            switch failure {
            case let .serverError(message):
                state.isLoading = false
                state.alert = .fpsAlert(.error(
                    message: message,
                    event: .dismissRoute
                ))
                
            case .connectivityError:
                state.isLoading = false
                state.alert = .fpsAlert(.tryAgainFPSAlert(.dismissRoute))
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
            state.fpsDestination = .c2BSub(getC2BSubResponse, nil)
            
        case .connectivityError:
            state.isLoading = false
            // non-final => closeAlert
            state.alert = .fpsAlert(.tryAgainFPSAlert(.closeAlert))
            
        case let .serverError(message):
            state.isLoading = false
            // non-final => closeAlert
            state.alert = .fpsAlert(.ok(
                message: message,
                event: .closeAlert
            ))
            
        case .missingProduct:
            state.isLoading = false
            state.alert = .fpsAlert(.missingProduct(event: .dismissRoute))
            
        case .confirmSetBankDefault:
            // state.fpsDestination = .confirmSetBankDefault
            // effect = .fps(.resetStatus)
            fatalError("what should happen here?")
            
        case .setBankDefault:
            state.alert = .fpsAlert(.setBankDefault(
                primaryEvent: .otp(.prepareSetBankDefault),
                secondaryEvent: .closeAlert
            ))
            
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
            let otpInputViewModel = factory.makeTimedOTPInputViewModel(scheduler)
            let cancellable = otpInputViewModel.$state
                .compactMap(\.projection)
                .removeDuplicates()
                .map(Event.OTP.otpInput)
                .receive(on: scheduler)
                .sink { [weak self] in self?.event(.otp($0))}
            
            state.fpsDestination = .confirmSetBankDefault(otpInputViewModel, cancellable)
            
        case .connectivityError:
            state.fpsDestination = nil
#warning("direct change of state that is outside of reducer")
            self.informer.set(text: "Ошибка изменения настроек СБП.\nПопробуйте позже.")
            
        case let .serverError(message):
            state.alert = .fpsAlert(.error(
                message: message,
                event: .closeAlert
            ))
        }
        
        return (state, effect)
    }

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
                state.alert = .alert(.error(event: .closeAlert))
                
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
}

// MARK: - Effect Handling

private extension UserAccountViewModel {
    
    // MARK: - OTP Effect Handling
    
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
    
    // MARK: - Demo Effect Handling
    
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
}

private extension AlertModel
where PrimaryEvent == UserAccountViewModel.Event,
      SecondaryEvent == UserAccountViewModel.Event {
    
    static func `default`(
        title: String,
        message: String,
        primaryEvent: PrimaryEvent,
        secondaryEvent: SecondaryEvent
    ) -> Self {
        
        .init(
            title: title,
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: primaryEvent
            ),
            secondaryButton: .init(
                type: .cancel,
                title: "Отмена",
                event: secondaryEvent
            )
        )
    }
    
    static func error(
        message: String? = nil,
        event: PrimaryEvent
    ) -> Self {
        
        .ok(
            title: "Ошибка",
            message: message,
            event: event
        )
    }
    
    static func ok(
        title: String = "",
        message: String? = nil,
        event: PrimaryEvent
    ) -> Self {
        
        self.init(
            title: title,
            message: message,
            primaryButton: .init(
                type: .default,
                title: "OK",
                event: event
            )
        )
    }
    
    static func missingContract(
        event: PrimaryEvent
    ) -> Self {
        
        .ok(
            title: "Не найден договор СБП",
            message: "Договор будет создан автоматически, если Вы включите переводы через СБП",
            event: event
        )
    }
    
    static func missingProduct(
        event: PrimaryEvent
    ) -> Self {
        
        .ok(
            title: "Сервис не доступен",
            message: "Для подключения договора СБП у Вас должен быть подходящий продукт",
            event: event
        )
    }
    
    static func setBankDefault(
        primaryEvent: PrimaryEvent,
        secondaryEvent: SecondaryEvent
    ) -> Self {
        
        .default(
            title: "Внимание",
            message: "Фора-банк будет выбран банком по умолчанию",
            primaryEvent: primaryEvent,
            secondaryEvent: secondaryEvent
        )
    }
    
    static func tryAgainFPSAlert(
        _ event: PrimaryEvent
    ) -> Self {
        
        let message = "Превышено время ожидания. Попробуйте позже"
        
        return .error(message: message, event: event)
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

extension UserAccountViewModel {
    
    struct State: Equatable {
        
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
            
            case fastPaymentsSettings(FastPaymentsSettingsViewModel, AnyCancellable)
        }
        
        enum FPSDestination: Equatable {
            
            case confirmSetBankDefault(TimedOTPInputViewModel, AnyCancellable)//(phoneNumberMask: String)
#warning("change `AnyCancellable?` to `AnyCancellable` after replacing `GetC2BSubResponse` to view model as associated type")
            case c2BSub(GetC2BSubResponse, AnyCancellable?)
        }
        
        enum Alert: Equatable {
            
            case alert(AlertModelOf<Event>)
            case fpsAlert(AlertModelOf<Event>)
            
            var alert: AlertModelOf<Event>? {
                
                if case let .alert(alert) = self {
                    return alert
                } else {
                    return nil
                }
            }
            
            var fpsAlert: AlertModelOf<Event>? {
                
                if case let .fpsAlert(fpsAlert) = self {
                    return fpsAlert
                } else {
                    return nil
                }
            }
        }
    }
}

extension UserAccountViewModel.State.Destination: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        
        switch (lhs, rhs) {
        case let (.fastPaymentsSettings(lhs, _), .fastPaymentsSettings(rhs, _)):
            ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .fastPaymentsSettings(viewModel, _):
            hasher.combine(ObjectIdentifier(viewModel))
        }
    }
}

extension UserAccountViewModel.State.FPSDestination: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        
        switch (lhs, rhs) {
        case let (.confirmSetBankDefault(lhs, _), .confirmSetBankDefault(rhs, _)):
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
            
        case let (.c2BSub(lhs, _), .c2BSub(rhs, _)):
            return lhs == rhs
            
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .confirmSetBankDefault(viewModel, _):
            hasher.combine(ObjectIdentifier(viewModel))
            
        case let .c2BSub(getC2BSubResponse, _):
            hasher.combine(getC2BSubResponse)
        }
    }
}

extension GetC2BSubResponse: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        
        hasher.combine(self)
    }
}
