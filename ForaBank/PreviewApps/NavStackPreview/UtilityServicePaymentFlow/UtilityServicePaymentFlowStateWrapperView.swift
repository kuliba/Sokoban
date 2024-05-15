//
//  UtilityServicePaymentFlowStateWrapperView.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import ForaTools
import RxViewModel
import SwiftUI

struct UtilityServicePaymentFlowStateWrapperView<Icon, OperatorPicker, ServicePicker>: View
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

typealias UtilityServicePaymentFlowViewModel<Icon> = RxViewModel<UtilityServicePaymentFlowState<Icon>,
      UtilityServicePaymentFlowEvent<Icon>,
      UtilityServicePaymentFlowEffect<Icon>>

extension UtilityServicePaymentFlowStateWrapperView {
    
    typealias ViewModel = UtilityServicePaymentFlowViewModel<Icon>
    
    typealias State = UtilityServicePaymentFlowState<Icon>
    typealias Event = UtilityServicePaymentFlowEvent<Icon>
    typealias Effect = UtilityServicePaymentFlowEffect<Icon>
    typealias Factory = UtilityServicePaymentFlowFactory<Icon, OperatorPicker, ServicePicker>
}

//#Preview {
//    UtilityServicePaymentFlowStateWrapperView()
//}
