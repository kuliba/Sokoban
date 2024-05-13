//
//  ServicePickerView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

import Foundation
import SwiftUI

struct ServicePickerView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        List {
            
            ForEach(state.services.elements, content: serviceView)
        }
    }
    
    private func serviceView(
        service: UtilityService
    ) -> some View {
        
        Button(String(service.id.prefix(23))) {
            
            event(.service(service, for: state.`operator`))
        }
        .foregroundColor(service.id.localizedCaseInsensitiveContains("failure") ? .red : .primary)
    }
}

extension ServicePickerView {
    
    typealias UtilityFlowState = UtilityPaymentFlowState<LastPayment, Operator, UtilityService, UtilityPrepaymentViewModel, ObservingPaymentFlowMockViewModel>
    typealias State = UtilityFlowState.Destination.ServicePickerFlowState.Content
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, UtilityService>.UtilityPrepaymentFlowEvent.Select
}

//#Preview {
//    ServicePickerView()
//}
