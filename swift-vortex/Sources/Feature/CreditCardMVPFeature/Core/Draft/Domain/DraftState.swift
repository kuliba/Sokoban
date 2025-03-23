//
//  DraftState.swift
//
//
//  Created by Igor Malyarov on 23.03.2025.
//

/// Represents the state of a draft.
///
/// This state is generic over three components:
/// - `Consent`: the type representing the consent state.
/// - `Content`: the type representing the content of the draft.
/// - `Verification`: the type representing the verification state.
public struct DraftState<Consent, Content, Verification> {
    
    /// The current consent state.
    public var consent: Consent
    /// The content of the draft.
    public let content: Content
    /// The current verification state.
    public var verification: Verification
    
    public init(
        consent: Consent,
        content: Content,
        verification: Verification
    ) {
        self.consent = consent
        self.content = content
        self.verification = verification
    }
}

extension DraftState: Equatable where Consent: Equatable, Content: Equatable, Verification: Equatable {}
