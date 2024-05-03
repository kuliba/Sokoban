//
//  PaymentsTransfersView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import SwiftUI

struct PaymentsTransfersView: View {
    
    @StateObject private var viewModel: ViewModel
    let factory: Factory
    
    init(
        viewModel: ViewModel,
        factory: Factory
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.factory = factory
    }
    
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}

extension PaymentsTransfersView {
    
    typealias Factory = PaymentsTransfersViewFactory
    typealias ViewModel = PaymentsTransfersViewModel
}

#Preview {
    PaymentsTransfersView(viewModel: .preview(), factory: .preview)
}
