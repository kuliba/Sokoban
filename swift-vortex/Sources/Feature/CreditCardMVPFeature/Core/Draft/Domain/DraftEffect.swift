//
//  DraftEffect.swift
//
//
//  Created by Igor Malyarov on 23.03.2025.
//

/// Represents an effect triggered by processing a draft event.
///
/// - Parameter ConsentEffect: the type of effect produced by consent events.
/// - Parameter VerificationEffect: the type of effect produced by verification events.
public enum DraftEffect<ConsentEffect, VerificationEffect> {
    
    /// A consent-related effect.
    case consent(ConsentEffect)
    
    /// A verification-related effect.
    case verification(VerificationEffect)
}

extension DraftEffect: Equatable where ConsentEffect: Equatable, VerificationEffect: Equatable {}
