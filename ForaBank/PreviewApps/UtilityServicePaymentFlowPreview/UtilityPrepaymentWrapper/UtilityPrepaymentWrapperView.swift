//
//  UtilityPrepaymentWrapperView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 03.05.2024.
//

import SwiftUI

struct UtilityPrepaymentWrapperView: View {
    
    @ObservedObject var viewModel: ViewModel

    let flowEvent: (Event) -> Void
    let config: Config
    
    var body: some View {
        
        UtilityPrepaymentView(
            state: viewModel.state,
            event: viewModel.event(_:),
            flowEvent: flowEvent,
            config: config
        )
    }
}

extension UtilityPrepaymentWrapperView {
    
    typealias Config = UtilityPrepaymentView.Config
    typealias Event = UtilityPrepaymentFlowEvent
    typealias ViewModel = UtilityPrepaymentViewModel
}

#Preview {
    UtilityPrepaymentWrapperView(viewModel: .preview(), flowEvent: { print($0) }, config: .preview)
}
