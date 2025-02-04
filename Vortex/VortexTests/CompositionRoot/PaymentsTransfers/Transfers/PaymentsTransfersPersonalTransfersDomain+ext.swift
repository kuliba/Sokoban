//
//  PaymentsTransfersPersonalTransfersDomain+ext.swift
//  VortexTests
//
//  Created by Igor Malyarov on 26.10.2024.
//

@testable import Vortex
import FlowCore
import PayHub

// MARK: - Equatable

extension PaymentsTransfersPersonalTransfersDomain.FlowEvent {
    
    var equatable: EquatableEvent {
        
        switch self {
        case .dismiss:
            return .dismiss
            
        case let .isLoading(isLoading):
            return .isLoading(isLoading)

        case let .navigation(navigation):
            return .navigation(navigation.equatable)
            
        case let .select(select):
            return .select(select.equatable)
        }
    }
    
    enum EquatableEvent: Equatable {
        
        case dismiss
        case isLoading(Bool)
        case navigation(PaymentsTransfersPersonalTransfersDomain.EquatableNavigationResult)
        case select(PaymentsTransfersPersonalTransfersDomain.EquatableSelect)
    }
}

extension PaymentsTransfersPersonalTransfersDomain.Navigation {
    
    var equatable: PaymentsTransfersPersonalTransfersDomain.EquatableNavigationResult {
        
        switch self {
        case let .failure(failure):
            return .failure(failure)
            
        case let .success(navigation):
            return .success(navigation.equatable)
        }
    }
}

extension PaymentsTransfersPersonalTransfersDomain.NavigationSuccess {
    
    var equatable: PaymentsTransfersPersonalTransfersDomain.EquatableNavigation {
        
        switch self {
        case let .contacts(node):
            return .contacts(.init(node.model))
            
        case let .meToMe(node):
            return .meToMe(.init(node.model))
            
        case let .payments(node):
            return .payments(.init(node.model))
            
        case let .successMeToMe(node):
            return .successMeToMe(.init(node.model))
            
        case .scanQR:
            return .scanQR
        }
    }
}

extension PaymentsTransfersPersonalTransfersDomain.Select {
    
    var equatable: PaymentsTransfersPersonalTransfersDomain.EquatableSelect {
        
        switch self {
        case let .alert(message):
            return .alert(message)
            
        case let .buttonType(buttonType):
            return .buttonType(buttonType)
            
        case let .contactAbroad(contactAbroad):
            return .contactAbroad(contactAbroad)
            
        case let .contacts(contacts):
            return .contacts(contacts)
            
        case let .countries(countries):
            return .countries(countries)
            
        case let .latest(latest):
            return .latest(latest)
            
        case .scanQR:
            return .scanQR
            
        case let .successMeToMe(successMeToMe):
            return .successMeToMe(.init(successMeToMe.model))
        }
    }
}

extension PaymentsTransfersPersonalTransfersDomain {
    
    typealias EquatableNavigationResult = Result<EquatableNavigation, NavigationFailure>
    
    enum EquatableNavigation: Equatable {
        
        case contacts(ObjectIdentifier)
        case meToMe(ObjectIdentifier)
        case payments(ObjectIdentifier)
        case successMeToMe(ObjectIdentifier)
        case scanQR
    }
    
    enum EquatableNavigationFailure: Error, Equatable {
        
        case alert(String)
    }
    
    enum EquatableSelect: Equatable {
        
        case alert(String)
        case buttonType(ButtonType)
        case contactAbroad(Payments.Operation.Source)
        case contacts(Payments.Operation.Source)
        case countries(Payments.Operation.Source)
        case latest(LatestPaymentData.ID)
        case scanQR
        case successMeToMe(ObjectIdentifier)
    }
    
    typealias EquatableNotifyEvent = FlowCore.FlowEvent<EquatableSelect, Never>
}

extension PaymentsTransfersPersonalTransfersDomain.NotifyEvent {
    
    var equatable: PaymentsTransfersPersonalTransfersDomain.EquatableNotifyEvent {
        
        switch self {
        case .dismiss:
            return .dismiss
            
        case let .isLoading(isLoading):
            return .isLoading(isLoading)

        case let .select(select):
            return .select(select.equatable)
        }
    }
}

extension CallSpy
where Payload == PaymentsTransfersPersonalTransfersDomain.NotifyEvent {
    
    typealias EquatablePayload = PaymentsTransfersPersonalTransfersDomain.EquatableNotifyEvent
    
    var equatablePayloads: [EquatablePayload] {
        
        return payloads.map(\.equatable)
    }
}
