//
//  PaymentsTransfersViewFactory.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import SwiftUI

struct PaymentsTransfersViewFactory {
    
    let mode: Mode
    
    init(mode: Mode = .mock) {
        
        self.mode = mode
    }
    
    func prePaymentView() -> some View {
        
        switch mode {
        case .mock:
            return PrePaymentMockView()
        }
    }
    
    func prePaymentFailureView(
        _ payByInstruction: @escaping PayByInstruction
    ) -> some View {
        
        switch mode {
        case .mock:
            PrePaymentFailureMockView(payByInstruction: payByInstruction)
        }
    }
}

extension PaymentsTransfersViewFactory {
    
    enum Mode {
        
        case mock
    }
    
    typealias PayByInstruction = () -> Void
}
