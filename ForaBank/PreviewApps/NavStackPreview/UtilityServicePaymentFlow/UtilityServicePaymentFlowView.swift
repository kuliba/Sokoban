//
//  UtilityServicePaymentFlowView.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import SwiftUI
import UIPrimitives

struct UtilityServicePaymentFlowView<Icon, OperatorPicker, ServicePicker>: View
where OperatorPicker: View,
      ServicePicker: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory<Icon, OperatorPicker, ServicePicker>
    
#warning("replace with NavStack")
    
    var body: some View {
        
        factory.makeOperatorPicker(
            { event(.selectUtilityServiceOperator($0)) }
        )
        .navigationDestination(
            item: .init(
                get: { state.destination },
                set: { if $0 == nil { event(.resetDestination) }}
            ),
            // TODO: replace with factory.makeDestinationView
            content: destinationView
        )
    }
    
    private func destinationView(
        destination: Destination
    ) -> some View {
        
        switch destination {
        case let .services(state):
            servicePicker(state)
        }
    }
    
    private func servicePicker(
        _ state: PickerState
    ) -> some View {
        
        factory.makeServicePicker(state, { event(.selectUtilityService($0)) })
            .navigationTitle(state.`operator`.navTitle)
            .toolbar { factory.asyncImage(state.operator.icon) }
            .navigationBarTitleDisplayMode(.inline)
    }
}

private extension UtilityServicePickerState.Operator {
    
    var navTitle: String {
        
        [nameTitle, innTitle, iconTitle].joined(separator: ", ")
    }
    
    private var nameTitle: Substring { name.prefix(6) }
    private var innTitle: Substring { inn.prefix(4) }
    private var iconTitle: Substring { String(describing: icon).prefix(4) }
}

extension UtilityServicePaymentFlowView {
    
    typealias Destination = UtilityServicePaymentFlowState<Icon>.Destination
    typealias PickerState = UtilityServicePickerState<Icon>
    
    typealias State = UtilityServicePaymentFlowState<Icon>
    typealias Event = UtilityServicePaymentFlowEvent<Icon>
    typealias Effect = UtilityServicePaymentFlowEffect<Icon>
    typealias Factory = UtilityServicePaymentFlowFactory
}

//#Preview {
//    UtilityServicePaymentFlowView()
//}
