//
//  PaymentProviderPickerWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

import SwiftUI

struct PaymentProviderPickerWrapperView<OperatorLabel, Footer>: View
where OperatorLabel: View,
      Footer: View {
    
    @ObservedObject var model: Model
    
    let operatorLabel: (SegmentedOperatorProvider) -> OperatorLabel
    let footer: () -> Footer
    let config: Config

    var body: some View {
        
        PaymentProviderPickerView(
            segments: model.state.segments,
            providerView: providerView,
            footer: footer,
            config: config
        )
    }
}

extension PaymentProviderPickerWrapperView {
    
    typealias Model = PaymentProviderPickerModel<SegmentedOperatorProvider>
    typealias Config = PaymentProviderPickerViewConfig
}

private extension PaymentProviderPickerWrapperView {
    
    func providerView(
        segmented: SegmentedOperatorProvider
    ) -> some View {
        
        Button {
            switch segmented {
            case let .operator(`operator`):
                model.event(.select(.item(.operator(`operator`))))
                
            case let .provider(provider):
                model.event(.select(.item(.provider(provider))))
            }
        } label: {
            operatorLabel(segmented)
        }
    }
}
