//
//  PaymentsTransfersViewFactory.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import SwiftUI
import UtilityPayment

struct PaymentsTransfersViewFactory {
    
    let mode: Mode
    
    init(mode: Mode = .mock) {
        
        self.mode = mode
    }
    
    func prePaymentFailureView(
        _ payByInstruction: @escaping PayByInstruction
    ) -> some View {
        
        switch mode {
        case .mock:
            PrePaymentFailureMockView(payByInstruction: payByInstruction)
        }
    }
    
    func prePaymentView(
        event: @escaping (PPEvent) -> Void,
        addCompany: @escaping () -> Void
    ) -> some View {
        
        switch mode {
        case .mock:
            return PrePaymentMockView(event: event, addCompany: addCompany)
        }
    }
}

extension PaymentsTransfersViewFactory {
    
    enum Mode {
        
        case mock
    }
    
    typealias PayByInstruction = () -> Void
    
    typealias PPEvent = PrePaymentEvent<LastPayment, Operator, LoadServicesResponse, UtilityService>
}
