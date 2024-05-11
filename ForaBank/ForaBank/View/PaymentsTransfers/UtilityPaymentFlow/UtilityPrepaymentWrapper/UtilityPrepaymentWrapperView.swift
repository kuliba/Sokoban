//
//  UtilityPrepaymentWrapperView.swift
//  
//
//  Created by Igor Malyarov on 03.05.2024.
//

import SwiftUI

struct UtilityPrepaymentWrapperView: View {
    
    @ObservedObject var viewModel: ViewModel

    let flowEvent: (FlowEvent) -> Void
    let config: Config
    
    var body: some View {
        
        ComposedUtilityPrepaymentView(
            state: viewModel.state,
            event: viewModel.event(_:),
            flowEvent: flowEvent,
            config: config
        )
    }
}

extension UtilityPrepaymentWrapperView {
    
    typealias FlowEvent = UtilityPrepaymentFlowEvent
    typealias ViewModel = UtilityPrepaymentViewModel
    typealias Config = ComposedUtilityPrepaymentView.Config
}
