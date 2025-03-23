//
//  VerifiableApplicationEffect.swift
//
//
//  Created by Igor Malyarov on 23.03.2025.
//

import StateMachines

/// An effect produced by a verifiable application process.
/// It distinguishes between effects from the application and verification parts.
public enum VerifiableApplicationEffect<VerificationEffect> {
    
    /// An effect produced by the application part of the process.
    case application(ApplicationEffect)
    
    /// An effect produced by the verification part of the process.
    case verification(VerificationEffect)
    
    /// Typealias for the application effect, based on `StateMachines.LoadEffect`.
    public typealias ApplicationEffect = StateMachines.LoadEffect
}

extension VerifiableApplicationEffect: Equatable where VerificationEffect: Equatable {}
