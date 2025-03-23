//
//  VerifiableApplicationEffect.swift
//
//
//  Created by Igor Malyarov on 23.03.2025.
//

import StateMachines

public enum VerifiableApplicationEffect<VerificationEffect> {
    
    case application(ApplicationEffect)
    case verification(VerificationEffect)
    
    public typealias ApplicationEffect = StateMachines.LoadEffect
}

extension VerifiableApplicationEffect: Equatable where VerificationEffect: Equatable {}
