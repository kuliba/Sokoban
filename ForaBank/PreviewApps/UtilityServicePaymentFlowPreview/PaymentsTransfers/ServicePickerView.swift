//
//  ServicePickerView.swift
//  UtilityServicePaymentFlowPreview
//
//  Created by Igor Malyarov on 05.05.2024.
//

import SwiftUI

struct ServicePickerView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        List {
            
            ForEach(state.services.elements) { service in
                
                Button(String(service.id.prefix(24))) {
                    
                    event(.service(service, for: state.`operator`))
                }
            }
        }
    }
}

extension ServicePickerView {
    
    typealias State = UtilityPaymentFlowState.Destination.ServicePickerFlowState.Content
    typealias Event = UtilityPaymentFlowEvent.UtilityPrepaymentFlowEvent.Select
}

//#Preview {
//    ServicePickerView()
//}
