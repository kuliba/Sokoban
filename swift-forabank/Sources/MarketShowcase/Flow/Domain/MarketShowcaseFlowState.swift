//
//  MarketShowcaseFlowState.swift
//  
//
//  Created by Andryusina Nataly on 25.09.2024.
//

public struct MarketShowcaseFlowState< Destination, InformerPayload> {
    
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

public extension MarketShowcaseFlowState {
    
    enum Status {
        
        case alert(String)
        case destination(Destination)
        case informer(InformerPayload)
        case outside(Outside)
        
        public enum Outside: Equatable {
            case main
            case openURL(String)
        }
    }
}

extension MarketShowcaseFlowState.Status: Equatable where Destination: Equatable, InformerPayload: Equatable {}

extension MarketShowcaseFlowState: Equatable where Destination: Equatable, InformerPayload: Equatable {}
