//
//  PaymentsDestinationView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 25.04.2024.
//

import SwiftUI

struct PaymentsDestinationView<UtilityPrepaymentView>: View
where UtilityPrepaymentView: View {
    
    let state: State
    let factory: Factory
    
    var body: some View {
        
        switch state {
        case let .prepaymentFlow(destination):
            switch destination {
            case let .utilityServicePayment(state):
                factory.makeUtilityPrepaymentView(state)
            }
        }
    }
}

extension PaymentsDestinationView {
    
    typealias State = PaymentsState.Destination
    typealias Factory = PaymentsDestinationViewFactory<UtilityPrepaymentView>
}

struct PaymentsDestinationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            preview(.empty)
            preview(.preview)
        }
    }
    
    private static func preview(
        _ state: PrepaymentFlowState.Destination.UtilityPrepaymentState
    ) -> some View {
        
        PaymentsDestinationView(
            state: .prepaymentFlow(
                .utilityServicePayment(state)
            ),
            factory: .preview
        )
    }
}
