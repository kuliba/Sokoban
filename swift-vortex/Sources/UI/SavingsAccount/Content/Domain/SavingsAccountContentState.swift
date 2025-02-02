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
        navTitle: SavingsAccountNavTitle = .empty
    ) {
        self.status = status
        self.navTitle = navTitle
    }
}

extension SavingsAccountContentState: Equatable where Landing: Equatable, InformerPayload: Equatable {}

public enum SavingsAccountContentStatus<Landing, InformerPayload> {
    
    case initiate
    case inflight(Landing?)
    case loaded(Landing)
    case failure(Failure, Landing?)
    case selection(Selection?, Landing?)

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
        case .initiate, .failure, .loaded, .selection:
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
            
        case .initiate:
            return nil
            
        case let .selection(_, landing):
            return landing
        }
    }

    public enum Failure {
        
        case alert(String)
        case informer(InformerPayload)
    }
}

extension SavingsAccountContentStatus: Equatable where Landing: Equatable, InformerPayload: Equatable {}

extension SavingsAccountContentStatus.Failure: Equatable where InformerPayload: Equatable {}
