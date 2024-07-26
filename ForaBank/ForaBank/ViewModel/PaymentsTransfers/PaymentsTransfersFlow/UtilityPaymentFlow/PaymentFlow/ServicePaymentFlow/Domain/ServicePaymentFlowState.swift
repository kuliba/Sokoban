//
//  ServicePaymentFlowState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 25.07.2024.
//

enum ServicePaymentFlowState: Equatable {
    
    case none
    case alert(Alert)
    case fraud(FraudNoticePayload)
    case fullScreenCover(FullScreenCover)
    case terminated
    
    typealias Alert = UtilityServicePaymentFlowState.Alert
    typealias FullScreenCover = UtilityServicePaymentFlowState.FullScreenCover
}

extension ServicePaymentFlowState {
    
    var alert: Alert? {
        
        guard case let .alert(alert) = self
        else { return nil }
        
        return alert
    }
    
    var fraud: FraudNoticePayload? {
        
        guard case let .fraud(fraud) = self
        else { return nil }
        
        return fraud
    }
    
    var fullScreenCover: FullScreenCover? {
        
        guard case let .fullScreenCover(fullScreenCover) = self
        else { return nil }
        
        return fullScreenCover
    }
}
