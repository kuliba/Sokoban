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
        
        switch destination {
        case let .services(state):
            servicePicker(state)
        }
    }
    
#warning("mind `operator`.icon` - use AsyncImage")
    private func servicePicker(
        _ state: UtilityServicePickerState
    ) -> some View {
        
        factory.makeServicePicker(state, { event(.selectUtilityService($0)) })
            .navigationTitle(state.`operator`.navTitle)
            .navigationBarTitleDisplayMode(.inline)
    }
}

private extension UtilityServicePickerState.Operator {
    
    var navTitle: String {
        
        [nameTitle, innTitle, iconTitle].joined(separator: ", ")
    }
    
    private var nameTitle: Substring { name.prefix(6) }
    private var innTitle: Substring { inn.prefix(4) }
    private var iconTitle: Substring { icon.prefix(4) }
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
