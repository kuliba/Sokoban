//
//  DraftEvent.swift
//  
//
//  Created by Igor Malyarov on 23.03.2025.
//

/// Represents an event that can affect a draft.
///
/// The event is either a consent-related event or a verification-related event.
/// - Parameters:
///   - ConsentEvent: the type of consent events.
///   - VerificationEvent: the type of verification events.
public enum DraftEvent<ConsentEvent, VerificationEvent> {
    
    /// An event related to consent changes.
    case consent(ConsentEvent)
    
    /// An event related to verification changes.
    case verification(VerificationEvent)
}

extension DraftEvent: Equatable where ConsentEvent: Equatable, VerificationEvent: Equatable {}
