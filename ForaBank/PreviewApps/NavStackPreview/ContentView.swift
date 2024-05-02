//
//  ContentView.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import RxViewModel
import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        UtilityServicePaymentFlowStateWrapperView(
            viewModel: .init(),
            factory: .default
        )
    }
}

private extension RxViewModel
where State == UtilityServicePaymentFlowState, Event == UtilityServicePaymentFlowEvent, Effect == UtilityServicePaymentFlowEffect {
    
    convenience init() {
        
        let reducer = UtilityServicePaymentFlowReducer()
        let effectHandler = UtilityServicePaymentFlowEffectHandler()
        
        self.init(
            initialState: .none,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .main
        )
    }
}

private extension UtilityServicePaymentFlowFactory
where OperatorPicker == _OperatorPicker,
      ServicePicker == _ServicePicker {
    
    static var `default`: Self {
        
        .init(
            makeOperatorPicker: _makeOperatorPicker,
            makeServicePicker: _makeServicePicker
        )
    }
    
    private static func _makeOperatorPicker(
    ) -> OperatorPicker {
        
        _OperatorPicker()
    }
    
    private static func _makeServicePicker(
    ) -> ServicePicker {
        
        _ServicePicker()
    }
}

#Preview {
    ContentView()
}
