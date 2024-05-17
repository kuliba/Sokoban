//
//  ServicePickerView.swift
//  
//
//  Created by Igor Malyarov on 05.05.2024.
//

import Foundation
import SwiftUI

struct ServicePickerView<LastPayment, Operator, Service>: View
where Service: Identifiable,
      Service.ID: StringProtocol {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        List {
            
            ForEach(state.services.elements, content: serviceView)
        }
    }
    
    private func serviceView(
        service: Service
    ) -> some View {
        
        Button(String(service.id.prefix(23))) {
            
            event(.service(service, for: state.`operator`))
        }
        .foregroundColor(service.id.localizedCaseInsensitiveContains("failure") ? .red : .primary)
    }
}

extension ServicePickerView {
    
    typealias PaymentViewModel = ObservingPaymentFlowMockViewModel
    typealias UtilityFlowState = UtilityPaymentFlowState<LastPayment, Operator, Service, UtilityPrepaymentViewModel, PaymentViewModel>
    typealias State = UtilityServicePickerFlowState<Operator, Service, PaymentViewModel>.Content
    typealias Event = UtilityPaymentFlowEvent<LastPayment, Operator, Service>.UtilityPrepaymentFlowEvent.Select
}
