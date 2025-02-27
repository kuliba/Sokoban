//
//  SavingsAccountContentState.swift
//  
//
//  Created by Andryusina Nataly on 03.12.2024.
//

import Foundation

public struct SavingsAccountContentState<Landing, InformerPayload> {
    
    public var status: SavingsAccountContentStatus<Landing, InformerPayload>
    public var navTitle: SavingsAccountNavTitle
    
    public init(
        status: SavingsAccountContentStatus<Landing, InformerPayload>,
        navTitle: SavingsAccountNavTitle = .empty // TODO: move to flow
    ) {
        self.status = status
        self.navTitle = navTitle
    }
}

extension SavingsAccountContentState: Equatable where Landing: Equatable, InformerPayload: Equatable {}

public enum SavingsAccountContentStatus<Landing, InformerPayload> {
    
    case idle
    case inflight(Landing?)
    case loaded(Landing?) // TODO: remove optinal
    case failure(Failure, Landing?)

    public enum Selection: Equatable {
        
        case openSavingsAccount
    }

    public var needContinueButton: Bool {
        
        oldLanding != nil
    }

    var isLoading: Bool {
        
        switch self {
        case .inflight:
            return true
        case .idle, .failure, .loaded:
            return false
        }
    }
    
    var oldLanding: Landing? {
        
        switch self {
        case let .loaded(landing):
            return landing
            
        case let .failure(_, landing):
            return landing
            
        case let .inflight(landing):
            return landing
            
        case .idle:
            return nil
        }
    }

    public enum Failure {
        
        case alert(String)
        case informer(InformerPayload)
    }
}

extension SavingsAccountContentStatus: Equatable where Landing: Equatable, InformerPayload: Equatable {}

extension SavingsAccountContentStatus.Failure: Equatable where InformerPayload: Equatable {}
