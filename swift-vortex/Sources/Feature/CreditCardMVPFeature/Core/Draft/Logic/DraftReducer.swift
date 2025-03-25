//
//  DraftReducer.swift
//  
//
//  Created by Igor Malyarov on 23.03.2025.
//

/// A reducer that processes events for a draft and updates its state accordingly.
///
/// The reducer uses two collaborator functions:
/// - A consent reducer to handle consent events.
/// - A verification reducer to handle verification events.
///
/// - Parameters:
///   - Consent: the type representing the consent state.
///   - ConsentEvent: the type representing events related to consent.
///   - Content: the type representing the content of the draft.
///   - Verification: the type representing the verification state.
///   - VerificationEvent: the type representing events related to verification.
///   - VerificationEffect: the type representing side effects triggered by verification events.
public final class DraftReducer<Consent, ConsentEvent, Content, Verification, VerificationEvent, VerificationEffect> {
    
    private let consentReduce: ConsentReduce
    private let verificationReduce: VerificationReduce
    
    /// Initializes a new instance of `DraftReducer`.
    ///
    /// - Parameters:
    ///   - consentReduce: A function that takes the current consent state and a consent event, and returns the updated consent state.
    ///   - verificationReduce: A function that takes the current verification state and a verification event, and returns the updated verification state along with an optional effect.
    public init(
        consentReduce: @escaping ConsentReduce,
        verificationReduce: @escaping VerificationReduce
    ) {
        self.consentReduce = consentReduce
        self.verificationReduce = verificationReduce
    }
    
    /// A function that reduces a consent state given a consent event.
    ///
    /// - Parameters:
    ///   - Consent: the current consent state.
    ///   - ConsentEvent: the event affecting the consent.
    /// - Returns: A tuple containing the updated consent state and a placeholder for effect (always `nil` in this case).
    public typealias ConsentReduce = (Consent, ConsentEvent) -> (Consent, Never?)
    
    /// A function that reduces a verification state given a verification event.
    ///
    /// - Parameters:
    ///   - Verification: the current verification state.
    ///   - VerificationEvent: the event affecting the verification.
    /// - Returns: A tuple containing the updated verification state and an optional verification effect.
    public typealias VerificationReduce = (Verification, VerificationEvent) -> (Verification, VerificationEffect?)
}

public extension DraftReducer {
    
    /// Processes an incoming event to update the draft state and deliver an optional effect.
    ///
    /// This function dispatches the event to either the consent or verification reducer.
    ///
    /// - Parameters:
    ///   - state: The current state of the draft.
    ///   - event: The event to be processed.
    /// - Returns: A tuple with the updated state and an optional effect.
    @inlinable
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .consent(consentEvent):
            reduce(&state, &effect, with: consentEvent)
            
        case let .verification(verificationEvent):
            reduce(&state, &effect, with: verificationEvent)
        }
        
        return (state, effect)
    }
}

public extension DraftReducer {
    
    /// Typealias for the draft state.
    typealias State = DraftState<Consent, Content, Verification>
    /// Typealias for the events that can be processed.
    typealias Event = DraftEvent<ConsentEvent, VerificationEvent>
    /// Typealias for the effect delivered after processing an event.
    typealias Effect = DraftEffect<VerificationEffect>
}

extension DraftReducer {
    
    /// Reduces the state by applying a consent event.
    ///
    /// This method updates the consent part of the state using the provided consent reducer.
    ///
    /// - Parameters:
    ///   - state: The draft state to be updated.
    ///   - effect: The effect reference (unused for consent events).
    ///   - consentEvent: The consent event to process.
    @usableFromInline
    func reduce(
        _ state: inout State,
        _ effect: inout Effect?,
        with consentEvent: ConsentEvent
    ) {
        state.consent = consentReduce(state.consent, consentEvent).0
    }
    
    /// Reduces the state by applying a verification event.
    ///
    /// This method updates the verification part of the state using the provided verification reducer.
    /// It also maps any verification effect into a `DraftEffect`.
    ///
    /// - Parameters:
    ///   - state: The draft state to be updated.
    ///   - effect: The effect reference to be populated if a verification effect is produced.
    ///   - verificationEvent: The verification event to process.
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
