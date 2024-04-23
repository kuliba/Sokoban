//
//  UtilityServicePaymentFlowStateWrapperView.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import ForaTools
import RxViewModel
import SwiftUI

struct UtilityServicePaymentFlowStateWrapperView<OperatorPicker, ServicePicker>: View
where OperatorPicker: View,
      ServicePicker: View {
    
    @StateObject private var viewModel: ViewModel
    
    private let factory: Factory
    
    init(
        viewModel: ViewModel,
        factory: Factory
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.factory = factory
    }
    
    var body: some View {
        
        UtilityServicePaymentFlowView(
            state: viewModel.state,
            event: viewModel.event,
            factory: factory
        )
    }
}

extension UtilityServicePaymentFlowStateWrapperView {
    
    typealias ViewModel = RxViewModel<State, Event, Effect>
    
    typealias State = UtilityServicePaymentFlowState
    typealias Event = UtilityServicePaymentFlowEvent
    typealias Effect = UtilityServicePaymentFlowEffect
    typealias Factory = UtilityServicePaymentFlowFactory<OperatorPicker, ServicePicker>
}

//#Preview {
//    UtilityServicePaymentFlowStateWrapperView()
//}
