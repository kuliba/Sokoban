//
//  VerifiableApplicationState.swift
//
//
//  Created by Igor Malyarov on 23.03.2025.
//

import StateMachines

/// Represents the state of a verifiable application process.
/// It encapsulates both the asynchronous application state and its verification data.
public struct VerifiableApplicationState<ApplicationStatus, Verification, Failure: Error> {
    
    /// The current state of the application process.
    public var applicationState: ApplicationState = .pending
    
    /// The verification data associated with the application.
    public var verification: Verification
    
    /// Initializes a new verifiable application state.
    ///
    /// - Parameters:
    ///   - applicationState: The current load state of the application.
    ///   - verification: The verification data.
    public init(
        applicationState: ApplicationState,
        verification: Verification
    ) {
        self.applicationState = applicationState
        self.verification = verification
    }
    
    /// Typealias for the asynchronous load state of the application.
    public typealias ApplicationState = StateMachines.LoadState<ApplicationStatus, Failure>
}

extension VerifiableApplicationState: Equatable where ApplicationStatus: Equatable, Verification: Equatable, Failure: Equatable {}
