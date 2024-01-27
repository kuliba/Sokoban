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
    
    private let reduce: Reduce
    private let prepareSetBankDefault: PrepareSetBankDefault
    private let makeFastPaymentsSettingsViewModel: MakeFastPaymentsSettingsViewModel
    
    private let stateSubject = PassthroughSubject<State, Never>()
    private let scheduler: AnySchedulerOfDispatchQueue
    private var destinationCancellable: AnyCancellable?
    private var fpsDestinationCancellable: AnyCancellable?
    
    init(
        initialState: State = .init(),
        informer: InformerViewModel = .init(),
        reduce: @escaping Reduce,
        prepareSetBankDefault: @escaping PrepareSetBankDefault,
        makeFastPaymentsSettingsViewModel: @escaping MakeFastPaymentsSettingsViewModel,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
        self.informer = informer
        self.reduce = reduce
        self.prepareSetBankDefault = prepareSetBankDefault
        self.makeFastPaymentsSettingsViewModel = makeFastPaymentsSettingsViewModel
        self.scheduler = scheduler
        
        stateSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

extension UserAccountViewModel {
    
    func event(_ event: Event) {
        
        let (state, effect) = reduce(state, event, informer.set(text:), self.event(_:))
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
        
        let fpsViewModel = makeFastPaymentsSettingsViewModel(scheduler)
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

// MARK: - Types

extension UserAccountViewModel {
    
    typealias Inform = (String) -> Void
    typealias Dispatch = (Event) -> Void
    typealias Reduce = (State, Event, @escaping Inform, @escaping Dispatch) -> (State, Effect?)
    typealias PrepareSetBankDefault = FastPaymentsSettingsEffectHandler.PrepareSetBankDefault
    typealias MakeFastPaymentsSettingsViewModel = (AnySchedulerOfDispatchQueue) -> FastPaymentsSettingsViewModel
}

// MARK: - Event

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

// MARK: - State

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
