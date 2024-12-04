//
//  FlowState.swift
//  
//
//  Created by Andryusina Nataly on 04.12.2024.
//

import Foundation

public struct FlowState<Destination, InformerPayload> {
    
    public var isLoading: Bool
    public var status: Status?

    public init(
        isLoading: Bool = false,
        status: Status? = nil
    ) {
        self.isLoading = isLoading
        self.status = status
    }
}

public extension FlowState {
    
    enum Status {
        
        case alert(AlertFailure)
        case destination(Destination)
        case informer(InformerPayload)
        case outside(Outside)
        
        public enum Outside: Equatable {
            case main
            case order
        }
    }
}

extension FlowState.Status: Equatable where Destination: Equatable, InformerPayload: Equatable {}

extension FlowState: Equatable where Destination: Equatable, InformerPayload: Equatable {}
