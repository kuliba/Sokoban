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
        
        NavigationView {
            
            UtilityServicePaymentFlowStateWrapperView(
                viewModel: .init(),
                factory: .makeFactory(config: .preview)
            )
        }
    }
}

private extension RxViewModel
where State == UtilityServicePaymentFlowState, Event == UtilityServicePaymentFlowEvent, Effect == UtilityServicePaymentFlowEffect {
    
    convenience init() {
        
        let reducer = UtilityServicePaymentFlowReducer()
        let effectHandler = UtilityServicePaymentFlowEffectHandler()
        
        self.init(
            initialState: .services(.preview),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .main
        )
    }
}

private extension UtilityServicePaymentFlowFactory
where OperatorPicker == _OperatorPicker,
      ServicePicker == UtilityServicePicker {
    
    static func makeFactory(
        config: UtilityServicePickerConfig
    ) -> Self {
        
        return .init(
            makeOperatorPicker: _makeOperatorPicker,
            makeServicePicker: _makeServicePicker
        )
        
        func _makeOperatorPicker(
        ) -> OperatorPicker {
            
            _OperatorPicker()
        }
        
        func _makeServicePicker(
            state: UtilityServicePickerState,
            event: @escaping (UtilityService) -> Void
        ) -> ServicePicker {
            
            UtilityServicePicker(
                state: state,
                event: event,
                config: config
            )
        }
    }
}

#Preview {
    ContentView()
}
