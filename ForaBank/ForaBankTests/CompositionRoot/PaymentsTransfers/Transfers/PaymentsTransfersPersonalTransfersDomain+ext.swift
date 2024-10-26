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
            return .failure(failure)
            
        case let .success(navigation):
            return .success(navigation.equatable)
        }
    }
}

extension PaymentsTransfersPersonalTransfersDomain.Navigation {
    
    var equatable: PaymentsTransfersPersonalTransfersDomain.EquatableNavigation {
        
        switch self {
        case let .contacts(node):
            return .contacts(.init(node.model))
            
        case let .meToMe(node):
            return .meToMe(.init(node.model))
            
        case let .payments(node):
            return .payments(.init(node.model))
            
        case let .paymentsViewModel(node):
            return .paymentsViewModel(.init(node.model))
            
        case let .successMeToMe(node):
            return .successMeToMe(.init(node.model))
            
        case let .scanQR(node):
            return .scanQR(.init(node.model))
        }
    }
}

extension PaymentsTransfersPersonalTransfersDomain {
    
    typealias EquatableNavigationResult = Result<EquatableNavigation, NavigationFailure>
    
    enum EquatableNavigation: Equatable {
        
        case contacts(ObjectIdentifier)
        case meToMe(ObjectIdentifier)
        case payments(ObjectIdentifier)
        case paymentsViewModel(ObjectIdentifier)
        case successMeToMe(ObjectIdentifier)
        case scanQR(ObjectIdentifier)
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
