//
//  VerifiableApplicationState.swift
//
//
//  Created by Igor Malyarov on 23.03.2025.
//

import StateMachines

public struct VerifiableApplicationState<ApplicationStatus, Verification, Failure: Error> {
    
    public var applicationState: ApplicationState = .pending
    public var verification: Verification
    
    public init(
        applicationState: ApplicationState,
        verification: Verification
    ) {
        self.applicationState = applicationState
        self.verification = verification
    }
    
    public typealias ApplicationState = StateMachines.LoadState<ApplicationStatus, Failure>
}

extension VerifiableApplicationState: Equatable where ApplicationStatus: Equatable, Verification: Equatable, Failure: Equatable {}
