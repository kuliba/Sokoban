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
    private let handleOTPEffect: HandleOTPEffect
    private let makeFastPaymentsSettingsViewModel: MakeFastPaymentsSettingsViewModel
    
    private let stateSubject = PassthroughSubject<State, Never>()
    private let scheduler: AnySchedulerOfDispatchQueue
    
    init(
        initialState: State = .init(),
        informer: InformerViewModel = .init(),
        reduce: @escaping Reduce,
        handleOTPEffect: @escaping HandleOTPEffect,
        makeFastPaymentsSettingsViewModel: @escaping MakeFastPaymentsSettingsViewModel,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
        self.informer = informer
        self.reduce = reduce
        self.handleOTPEffect = handleOTPEffect
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
            handleOTPEffect(otpEffect) { [weak self] in self?.event(.otp($0)) }
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
    typealias Event = UserAccountNavigation.Event
    typealias Effect = UserAccountNavigation.Effect
    
    typealias Inform = (String) -> Void
    typealias Dispatch = (Event) -> Void
    
    typealias Reduce = (State, Event, @escaping Inform, @escaping Dispatch) -> (State, Effect?)
    
    typealias OTPDispatch = (Event.OTP) -> Void
    typealias HandleOTPEffect = (Effect.OTP, @escaping OTPDispatch) -> Void
    
    typealias MakeFastPaymentsSettingsViewModel = (AnySchedulerOfDispatchQueue) -> FastPaymentsSettingsViewModel
}
