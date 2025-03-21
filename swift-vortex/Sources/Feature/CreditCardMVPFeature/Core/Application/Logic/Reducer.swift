//
//  Reducer.swift
//
//
//  Created by Igor Malyarov on 21.03.2025.
//

import StateMachines

public final class Reducer<ApplicationPayload, ApplicationSuccess, OTP> {
    
    private let isValid: IsValid
    private let makeApplicationPayload: MakeApplicationPayload
    
    public init(
        isValid: @escaping IsValid,
        makeApplicationPayload: @escaping MakeApplicationPayload
    ) {
        self.isValid = isValid
        self.makeApplicationPayload = makeApplicationPayload
    }
    
    public typealias IsValid = (State) -> Bool
    public typealias MakeApplicationPayload = (State) -> ApplicationPayload?
}

public extension Reducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .applicationResult(applicationResult):
            reduce(&state, &effect, applicationResult)
            
        case .continue:
            reduceContinue(&state, &effect)
        }
        
        return (state, effect)
    }
}

public extension Reducer {
    
    typealias State = CreditCardMVPCore.State<ApplicationSuccess, OTP>
    typealias Event = CreditCardMVPCore.Event<ApplicationSuccess>
    typealias Effect = CreditCardMVPCore.Effect<ApplicationPayload, OTP>
}

private extension Reducer {
    
    func reduceContinue(
        _ state: inout State,
        _ effect: inout Effect?
    ) {
        guard isValid(state) else { return }
        
        effect = state.otp.success == nil ? .loadOTP : makeApplicationPayload(state).map { .apply($0) }
    }
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        _ applicationResult: Event.ApplicationResult
    ) {
        switch applicationResult {
        case let .failure(failure):
            switch failure.type {
            case .alert:
                state.applicationResult = .failure(.init(
                    message: failure.message,
                    type: .alert
                ))
                
            case .informer:
                state.applicationResult = .failure(.init(
                    message: failure.message,
                    type: .informer
                ))
                
            case .otp:
                effect = state.otp.success.map { .notifyOTP($0, failure.message) }
            }
            
        case let .success(success):
            state.applicationResult = .success(success)
        }
    }
}
