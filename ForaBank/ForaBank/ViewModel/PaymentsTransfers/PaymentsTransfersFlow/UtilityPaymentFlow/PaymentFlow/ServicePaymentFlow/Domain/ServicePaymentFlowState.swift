//
//  ServicePaymentFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

struct ServicePaymentFlowState: Equatable {
    
    var modal: Modal? = nil
}

extension ServicePaymentFlowState {
    
    enum Modal: Equatable {
        
        case alert(Alert)
        case fraud(FraudNoticePayload)
        case fullScreenCover(FullScreenCover)
        
        typealias Alert = UtilityServicePaymentFlowState.Alert
        typealias FullScreenCover = UtilityServicePaymentFlowState.FullScreenCover
    }
}

extension ServicePaymentFlowState {
    
    var alert: Modal.Alert? {
        
        guard case let .alert(alert) = modal
        else { return nil }
        
        return alert
    }
    
    var fraud: FraudNoticePayload? {
        
        guard case let .fraud(fraud) = modal
        else { return nil }
        
        return fraud
    }
    
    var fullScreenCover: Modal.FullScreenCover? {
        
        guard case let .fullScreenCover(fullScreenCover) = modal
        else { return nil }
        
        return fullScreenCover
    }
}
