//
//  UtilityPaymentOperatorPickerStateWrapperView.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import RxViewModel
import SwiftUI

typealias UtilityPaymentOperatorPickerViewModel<Icon> = RxViewModel<UtilityPaymentOperatorPickerState<Icon>, UtilityPaymentOperatorPickerEvent<Icon>, UtilityPaymentOperatorPickerEffect>

struct UtilityPaymentOperatorPickerStateWrapperView<Icon, FooterView, LastPaymentsView, OperatorsView>: View
where FooterView: View,
      LastPaymentsView: View,
      OperatorsView: View {
    
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
        
        UtilityPaymentOperatorPickerLayoutView(
            state: viewModel.state,
            factory: factory
        )
    }
}

extension UtilityPaymentOperatorPickerStateWrapperView {
    
    typealias ViewModel = UtilityPaymentOperatorPickerViewModel<Icon>
    typealias Factory = UtilityPaymentOperatorPickerLayoutFactory<Icon, FooterView, LastPaymentsView, OperatorsView>
}

//#Preview {
//    UtilityPaymentOperatorPickerStateWrapperView()
//}
