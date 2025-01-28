//
//  SegmentedPaymentProviderPickerWrapperView.swift
//  Vortex
//
//  Created by Igor Malyarov on 01.08.2024.
//

import SwiftUI

struct SegmentedPaymentProviderPickerWrapperView<ProviderView, Footer>: View
where ProviderView: View,
      Footer: View {
    
    @ObservedObject var model: Model
    
    let providerView: (SegmentedOperatorProvider) -> ProviderView
    let footer: () -> Footer
    let config: Config

    var body: some View {
        
        SegmentedPaymentProviderPickerView(
            segments: model.state.segments,
            providerView: providerView,
            footer: footer,
            config: config
        )
    }
}

extension SegmentedPaymentProviderPickerWrapperView {
    
    typealias Model = SegmentedPaymentProviderPickerModel<SegmentedOperatorProvider>
    typealias Config = SegmentedPaymentProviderPickerViewConfig
}
