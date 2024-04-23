//
//  UtilityPaymentOperatorPickerStateWrapperView.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import RxViewModel
import SwiftUI

typealias UtilityPaymentOperatorPickerViewModel<Icon> = RxViewModel<UtilityPaymentOperatorPickerState<Icon>, UtilityPaymentOperatorPickerEvent<Icon>, UtilityPaymentOperatorPickerEffect>

struct UtilityPaymentOperatorPickerStateWrapperView<Icon>: View {
    
    @StateObject private var viewModel: ViewModel
    
    private let config: Config
    
    init(
        viewModel: ViewModel,
        config: Config
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.config = config
    }
    
    var body: some View {
        
        UtilityPaymentOperatorPicker(
            state: viewModel.state,
            event: viewModel.event,
            config: config
        )
    }
}

extension UtilityPaymentOperatorPickerStateWrapperView {
    
    typealias ViewModel = UtilityPaymentOperatorPickerViewModel<Icon>
    typealias Config = UtilityPaymentOperatorPickerConfig
}

//#Preview {
//    UtilityPaymentOperatorPickerStateWrapperView()
//}
