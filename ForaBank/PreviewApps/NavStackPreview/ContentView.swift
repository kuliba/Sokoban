//
//  ContentView.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import CombineSchedulers
import RxViewModel
import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        NavigationView {
            
            UtilityServicePaymentFlowStateWrapperView(
                viewModel: .make(initialState: .services(.preview)),
                factory: .makeFactory(config: .preview)
            )
        }
    }
}

private extension UtilityServicePaymentFlowViewModel {
    
    static func make<Icon>(
        initialState: UtilityServicePaymentFlowState<Icon>,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> UtilityServicePaymentFlowViewModel<Icon> {
        
        let reducer = UtilityServicePaymentFlowReducer<Icon>()
        let effectHandler = UtilityServicePaymentFlowEffectHandler<Icon>()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .main
        )
    }
}

private extension UtilityServicePaymentFlowFactory
where OperatorPicker == _OperatorPicker,
      ServicePicker == UtilityServicePicker<Icon> {
    
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
            state: PickerState,
            event: @escaping (Service) -> Void
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
