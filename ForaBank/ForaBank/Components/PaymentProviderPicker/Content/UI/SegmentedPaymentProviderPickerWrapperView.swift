//
//  SegmentedPaymentProviderPickerWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 01.08.2024.
//

import SwiftUI

struct SegmentedPaymentProviderPickerWrapperView<OperatorLabel, Footer>: View
where OperatorLabel: View,
      Footer: View {
    
    @ObservedObject var model: Model
    
    let operatorLabel: (SegmentedOperatorProvider) -> OperatorLabel
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

private extension SegmentedPaymentProviderPickerWrapperView {
    
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
