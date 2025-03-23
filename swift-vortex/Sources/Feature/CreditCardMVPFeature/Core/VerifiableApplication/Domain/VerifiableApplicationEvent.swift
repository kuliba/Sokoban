//
//  VerifiableApplicationEvent.swift
//
//
//  Created by Igor Malyarov on 23.03.2025.
//

import StateMachines

/// An event in a verifiable application process.
/// This event can be either an application event or a verification event.
public enum VerifiableApplicationEvent<VerificationEvent, Failure: Error> {
    
    /// An application event, wrapping a `StateMachines.LoadEvent`.
    case application(ApplicationEvent)
    
    /// A verification event.
    case verification(VerificationEvent)
    
    /// Typealias for the application event.
    public typealias ApplicationEvent = StateMachines.LoadEvent<VerificationEvent, Failure>
}

extension VerifiableApplicationEvent: Equatable where VerificationEvent: Equatable, Failure: Equatable {}
