//
//  VerifiableApplicationEvent.swift
//
//
//  Created by Igor Malyarov on 23.03.2025.
//

import StateMachines

/// An event in a verifiable application process.
/// This event can either be an application event or a verification event.
///
/// - Parameters:
///   - ApplicationStatus: The type representing the status or result of the application process.
///   - VerificationEvent: The type representing an event specific to the verification process.
///   - Failure: The type representing an error, conforming to `Error`, which can occur during the application process.
public enum VerifiableApplicationEvent<ApplicationStatus, VerificationEvent, Failure: Error> {
    
    /// An application event.
    /// This event wraps a `StateMachines.LoadEvent` that produces an `ApplicationStatus` upon success
    /// and handles errors via the associated `Failure` type.
    case application(ApplicationEvent)
    
    /// A verification event.
    /// This event represents a distinct step in the verification process separate from the application outcome.
    case verification(VerificationEvent)
    
    /// Typealias for the application event.
    /// It is defined as a `StateMachines.LoadEvent` where the success value is of type `ApplicationStatus` and the failure is of type `Failure`.
    public typealias ApplicationEvent = StateMachines.LoadEvent<ApplicationStatus, Failure>
}

extension VerifiableApplicationEvent: Equatable where ApplicationStatus: Equatable, VerificationEvent: Equatable, Failure: Equatable {}
