//
//  VerifiableApplicationReducer.swift
//
//
//  Created by Igor Malyarov on 23.03.2025.
//

/// A reducer that processes events for a verifiable application process,
/// updating both the application state and the verification data accordingly.
public final class VerifiableApplicationReducer<ApplicationStatus, Verification, VerificationEvent, VerificationEffect, Failure: Error> {
    
    private let applicationReduce: ApplicationReduce
    private let verificationReduce: VerificationReduce
    
    /// Initializes a new reducer with the provided reduction closures.
    ///
    /// - Parameters:
    ///   - applicationReduce: A closure that reduces an application event into a new application state and optional effect.
    ///   - verificationReduce: A closure that reduces a verification event into updated verification data and an optional effect.
    public init(
        applicationReduce: @escaping ApplicationReduce,
        verificationReduce: @escaping VerificationReduce
    ) {
        self.applicationReduce = applicationReduce
        self.verificationReduce = verificationReduce
    }
    
    /// A typealias for the application reduction closure.
    /// It takes the current application state and an application event,
    /// and returns an updated application state along with an optional effect.
    public typealias ApplicationReduce = (State.ApplicationState, Event.ApplicationEvent) -> (State.ApplicationState, Effect.ApplicationEffect?)
    
    /// A typealias for the verification reduction closure.
    /// It takes the current verification data and a verification event,
    /// and returns updated verification data along with an optional effect.
    public typealias VerificationReduce = (Verification, VerificationEvent) -> (Verification, VerificationEffect?)
}

public extension VerifiableApplicationReducer {
    /// Processes the given event by reducing it into an updated state and an optional effect.
    ///
    /// - Parameters:
    ///   - state: The current verifiable application state.
    ///   - event: The event to process (either an application or verification event).
    /// - Returns: A tuple containing the updated state and an optional effect.
    @inlinable
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
    
    /// Convenience typealiases for the reducer's state, event, and effect.
    typealias State = VerifiableApplicationState<ApplicationStatus, Verification, Failure>
    
    /// The event type used by the reducer.
    typealias Event = VerifiableApplicationEvent<ApplicationStatus, VerificationEvent, Failure>
    
    /// The effect type produced by the reducer.
    typealias Effect = VerifiableApplicationEffect<VerificationEffect>
}

extension VerifiableApplicationReducer {
    
    /// Reduces an application event by updating the application state and mapping the produced effect.
    ///
    /// - Parameters:
    ///   - state: The current state, passed as inout.
    ///   - effect: The optional effect to be updated.
    ///   - applicationEvent: The application event to reduce.
    @usableFromInline
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with applicationEvent: Event.ApplicationEvent
    ) {
        let (application, applicationEffect) = applicationReduce(state.applicationState, applicationEvent)
        state.applicationState = application
        effect = applicationEffect.map { .application($0) }
    }
    
    /// Reduces a verification event by updating the verification data and mapping the produced effect.
    ///
    /// - Parameters:
    ///   - state: The current state, passed as inout.
    ///   - effect: The optional effect to be updated.
    ///   - verificationEvent: The verification event to reduce.
    @usableFromInline
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
