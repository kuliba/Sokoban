//
//  AnywayServicePickerFlowViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

import SwiftUI

struct AnywayServicePickerFlowViewFactory<ServicePicker>
where ServicePicker: View {
    
    let makeAnywayFlowView: MakeAnywayFlowView
    let makeServicePicker: MakeServicePicker
}

extension AnywayServicePickerFlowViewFactory {
    
    typealias MakeAnywayFlowView = (AnywayFlowModel) -> AnywayFlowView<PaymentCompleteView>
    typealias MakeServicePicker = (PaymentProviderServicePickerModel) -> ServicePicker // PaymentProviderServicePickerWrapperView
}
