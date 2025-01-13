//
//  SavingsAccountContentState.swift
//  
//
//  Created by Andryusina Nataly on 03.12.2024.
//

import Foundation

public struct SavingsAccountContentState<Landing, InformerPayload> {
    
    public var selection: Selection?
    public var status: SavingsAccountContentStatus<Landing, InformerPayload>

    public init(
        selection: Selection? = nil,
        status: SavingsAccountContentStatus<Landing, InformerPayload>
    ) {
        self.selection = selection
        self.status = status
    }
}

public extension SavingsAccountContentState {
    
    enum Selection: Equatable {
        
        case order
    }
}

extension SavingsAccountContentState: Equatable where Landing: Equatable, InformerPayload: Equatable {}

public enum SavingsAccountContentStatus<Landing, InformerPayload> {
    
    case initiate
    case inflight(Landing?)
    case loaded(Landing)
    case failure(Failure, Landing?)
    
    var isLoading: Bool {
        
        switch self {
        case .inflight:
            return true
        case .initiate, .failure, .loaded:
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
        }
    }

    public enum Failure {
        
        case alert(String)
        case informer(InformerPayload)
    }
}

extension SavingsAccountContentStatus: Equatable where Landing: Equatable, InformerPayload: Equatable {}

extension SavingsAccountContentStatus.Failure: Equatable where InformerPayload: Equatable {}
