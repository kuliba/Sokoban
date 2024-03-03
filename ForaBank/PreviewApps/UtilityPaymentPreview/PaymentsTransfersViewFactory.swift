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
    
    var prePaymentView: () -> some View {
        
        switch mode {
        case .mock:
            PrePaymentMockView.init
        }
    }
    
    var prePaymentFailureView: (@escaping PayByInstruction) -> some View {
        
        switch mode {
        case .mock:
            PrePaymentFailureMockView.init
        }
    }
}

extension PaymentsTransfersViewFactory {
    
    enum Mode {
        
        case mock
    }
    
    typealias PayByInstruction = () -> Void
}
