//
//  PaymentsView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

struct PaymentsView: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    
    var body: some View {
        
        utilityServicePaymentsButton()
    }
    
    private func utilityServicePaymentsButton(
    ) -> some View {
        
        Button("Utility Service Payments") {
            
            event(.buttonTapped(.utilityService))
        }
    }
}

extension PaymentsView {
    
    typealias State = PaymentsState
    typealias Event = PaymentsEvent
    typealias Effect = PaymentsEffect
    
    typealias Config = PaymentsViewConfig
}

struct PaymentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            preview(.init())
            preview(.init(destination: .utilityServicePayment))
        }
    }
    
    static func preview(
        _ state: PaymentsState
    ) -> some View {
        
        PaymentsView(
            state: state,
            event: { _ in },
            config: .preview
        )
    }
}
