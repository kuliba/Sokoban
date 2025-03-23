//
//  VerifiableApplicationReducer.swift
//
//
//  Created by Igor Malyarov on 23.03.2025.
//

public final class VerifiableApplicationReducer<ApplicationStatus, Verification, VerificationEvent, VerificationEffect, Failure: Error> {
    
    private let applicationReduce: ApplicationReduce
    private let verificationReduce: VerificationReduce
    
    public init(
        applicationReduce: @escaping ApplicationReduce,
        verificationReduce: @escaping VerificationReduce
    ) {
        self.applicationReduce = applicationReduce
        self.verificationReduce = verificationReduce
    }
    
    public typealias ApplicationReduce = (State.ApplicationState, Event.ApplicationEvent) -> (State.ApplicationState, Effect.ApplicationEffect?)
    public typealias VerificationReduce = (Verification, VerificationEvent) -> (Verification, VerificationEffect?)
}

public extension VerifiableApplicationReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .application(applicationEvent):
            reduce(&state, &effect, with: applicationEvent)
            
        case let .verification(verificationEvent):
            reduce(&state, &effect, with: verificationEvent)
        }
        
        return (state, effect)
    }
}

public extension VerifiableApplicationReducer {
    
    typealias State = VerifiableApplicationState<ApplicationStatus, Verification, Failure>
    typealias Event = VerifiableApplicationEvent<VerificationEvent, Failure>
    typealias Effect = VerifiableApplicationEffect<VerificationEffect>
}

private extension VerifiableApplicationReducer {
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with applicationEvent: Event.ApplicationEvent
    ) {
        let (application, applicationEffect) = applicationReduce(state.applicationState, applicationEvent)
        state.applicationState = application
        effect = applicationEffect.map { .application($0) }
    }
    
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with verificationEvent: VerificationEvent
    ) {
        let (verification, verificationEffect) = verificationReduce(state.verification, verificationEvent)
        state.verification = verification
        effect = verificationEffect.map { .verification($0) }
    }
}
