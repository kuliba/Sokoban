//
//  DraftEffect.swift
//  
//
//  Created by Igor Malyarov on 23.03.2025.
//

/// Represents an effect triggered by processing a verification event.
///
/// - Parameter VerificationEffect: the type of effect produced by verification events.
public enum DraftEffect<VerificationEffect> {
    
    /// A verification-related effect.
    case verification(VerificationEffect)
}

extension DraftEffect: Equatable where VerificationEffect: Equatable {}
