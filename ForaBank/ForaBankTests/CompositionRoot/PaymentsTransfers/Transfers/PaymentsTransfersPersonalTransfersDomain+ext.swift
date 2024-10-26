//
//  PaymentsTransfersPersonalTransfersDomain+ext.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 26.10.2024.
//

@testable import ForaBank

// MARK: - Equatable

extension PaymentsTransfersPersonalTransfersDomain.FlowEvent {
    
    var equatable: EquatableEvent {
        
        switch self {
        case .dismiss:
            return .dismiss
            
        case let .receive(receive):
            return .receive(receive.equatable)
            
        case let .select(select):
            return .select(select)
        }
    }
    
    enum EquatableEvent: Equatable {
        
        case dismiss
        case receive(PaymentsTransfersPersonalTransfersDomain.EquatableNavigationResult)
        case select(PaymentsTransfersPersonalTransfersDomain.Element)
    }
}

extension PaymentsTransfersPersonalTransfersDomain.NavigationResult {
    
    var equatable: PaymentsTransfersPersonalTransfersDomain.EquatableNavigationResult {
        
        switch self {
        case let .failure(failure):
            return .failure(failure.equatable)
            
        case let .success(navigation):
            return .success(navigation.equatable)
        }
    }
}

extension PaymentsTransfersPersonalTransfersDomain.Navigation {
    
    var equatable: PaymentsTransfersPersonalTransfersDomain.EquatableNavigation {
        
        switch self {
        case let .successMeToMe(successMeToMe):
            return .successMeToMe(.init(successMeToMe.model))
            
        default:
            return unimplemented("\(self) is not mapped to Equatable.")
        }
    }
}

extension PaymentsTransfersPersonalTransfersDomain.NavigationFailure {
    
    var equatable: PaymentsTransfersPersonalTransfersDomain.EquatableNavigationFailure {
        
        switch self {
        case let .alert(alert):
            return .alert(alert)
            
        default:
            return unimplemented("\(self) is not mapped to Equitable.")
        }
    }
}

extension PaymentsTransfersPersonalTransfersDomain {
    
    typealias EquatableNavigationResult = Result<EquatableNavigation, EquatableNavigationFailure>
    
    enum EquatableNavigation: Equatable {
        
        case successMeToMe(ObjectIdentifier)
    }
    
    enum EquatableNavigationFailure: Error, Equatable {
        
        case alert(String)
    }
}

extension CallSpy
where Payload == PaymentsTransfersPersonalTransfersDomain.FlowEvent {
    
    typealias EquatablePayload = PaymentsTransfersPersonalTransfersDomain.FlowEvent.EquatableEvent
    
    var equatablePayloads: [EquatablePayload] {
        
        return payloads.map(\.equatable)
    }
}
