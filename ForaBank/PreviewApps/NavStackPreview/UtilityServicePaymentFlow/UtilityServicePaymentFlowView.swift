//
//  UtilityServicePaymentFlowView.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import SwiftUI
import UIPrimitives

struct UtilityServicePaymentFlowView<OperatorPicker, ServicePicker>: View
where OperatorPicker: View,
      ServicePicker: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory<OperatorPicker, ServicePicker>
    
#warning("replace with NavStack")
    
    var body: some View {
        
        factory.makeOperatorPicker()
            .navigationDestination(
                item: .init(
                    get: { state },
                    set: { if $0 == nil { event(.resetDestination) }}
                ),
                content: destinationView
            )
    }
    
    private func destinationView(
        destination: UtilityServicePaymentFlowDestination
    ) -> some View {
        
        factory.makeServicePicker()
    }
}

extension UtilityServicePaymentFlowView {
    
    typealias State = UtilityServicePaymentFlowState
    typealias Event = UtilityServicePaymentFlowEvent
    typealias Effect = UtilityServicePaymentFlowEffect
    typealias Factory = UtilityServicePaymentFlowFactory
}

//#Preview {
//    UtilityServicePaymentFlowView()
//}
