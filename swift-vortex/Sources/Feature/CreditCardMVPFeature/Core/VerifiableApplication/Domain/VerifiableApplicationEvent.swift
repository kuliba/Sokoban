//
//  VerifiableApplicationEvent.swift
//
//
//  Created by Igor Malyarov on 23.03.2025.
//

import StateMachines

public enum VerifiableApplicationEvent<VerificationEvent, Failure: Error> {
    
    case application(ApplicationEvent)
    case verification(VerificationEvent)
    
    public typealias ApplicationEvent = StateMachines.LoadEvent<VerificationEvent, Failure>
}

extension VerifiableApplicationEvent: Equatable where VerificationEvent: Equatable, Failure: Equatable {}
