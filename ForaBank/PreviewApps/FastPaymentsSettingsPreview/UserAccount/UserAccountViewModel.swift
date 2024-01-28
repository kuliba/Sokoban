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
        
        guard case let .fastPaymentsSettings(route) = state.destination
        else { return nil }
        
        return route.viewModel
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
        
        state.destination = .fastPaymentsSettings(.init(fpsViewModel, cancellable))
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
    
    typealias State = Route
    
    typealias Inform = (String) -> Void
    typealias Dispatch = (Event) -> Void
    typealias Reduce = (State, Event, @escaping Inform, @escaping Dispatch) -> (State, Effect?)
    typealias PrepareSetBankDefault = FastPaymentsSettingsEffectHandler.PrepareSetBankDefault
    typealias MakeFastPaymentsSettingsViewModel = (AnySchedulerOfDispatchQueue) -> FastPaymentsSettingsViewModel
}

// MARK: - Effect

extension UserAccountViewModel {
    
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
    
    struct Route: Equatable {
        
        var destination: Destination?
        var alert: Alert?
        var isLoading: Bool
        
        init(
            destination: Destination? = nil,
            modal: Alert? = nil,
            isLoading: Bool = false
        ) {
            self.destination = destination
            self.alert = modal
            self.isLoading = isLoading
        }
    }
}

extension UserAccountViewModel.Route {
    
    typealias Event = UserAccountViewModel.Event
    
    enum Destination: Equatable {
        
        case fastPaymentsSettings(FPSRoute)
    }
    
    enum Alert: Equatable {
        
        case alert(AlertModelOf<Event>)
    }
}

// MARK: - Helpers

extension UserAccountViewModel.State {
    
    var fpsRoute: UserAccountViewModel.State.Destination.FPSRoute? {
        
        get {
            guard case let .fastPaymentsSettings(fpsRoute) = destination
            else { return nil }
            
            return fpsRoute
        }
        
        set(newValue) {
            guard case .fastPaymentsSettings = destination
            else { return }
            
            self.destination = newValue.map(Destination.fastPaymentsSettings)
        }
    }
}

extension UserAccountViewModel.State.Destination {
    
    typealias FPSRoute = GenericRoute<FastPaymentsSettingsViewModel, UserAccountViewModel.State.Destination.FPSDestination, Never, AlertModelOf<UserAccountViewModel.Event>>
    
    enum FPSDestination: Equatable {
        
        case confirmSetBankDefault(TimedOTPInputViewModel, AnyCancellable)//(phoneNumberMask: String)
#warning("change `AnyCancellable?` to `AnyCancellable` after replacing `GetC2BSubResponse` to view model as associated type")
        case c2BSub(GetC2BSubResponse, AnyCancellable?)
    }
}

extension AlertModel: Hashable
where PrimaryEvent: Equatable,
      SecondaryEvent: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension UserAccountViewModel.State.Destination: Hashable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        
        switch (lhs, rhs) {
        case let (.fastPaymentsSettings(lhs), .fastPaymentsSettings(rhs)):
            lhs.hashValue == rhs.hashValue
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .fastPaymentsSettings(route):
            hasher.combine(route.hashValue)
        }
    }
}

extension UserAccountViewModel.State.Destination.FPSDestination: Hashable {
    
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
