//
//  ServicePickerView.swift
//  
//
//  Created by Igor Malyarov on 05.05.2024.
//

import Foundation
import SwiftUI

struct ServicePickerView<LastPayment, Operator>: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
        
        List {
            
            ForEach(state.services.elements, content: serviceView)
        }
        .listStyle(.plain)
    }
    
    private func serviceView(
        service: Service
    ) -> some View {
        
        Button {
            
            event(.service(service, for: state.`operator`))
            
        } label: {
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text(service.name)
                    .font(.subheadline)
                
                Text(service.id)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 1)
            .contentShape(Rectangle())
            .foregroundColor(service.id.localizedCaseInsensitiveContains("failure") ? .red : .primary)
        }
    }
}

extension ServicePickerView {
    
    typealias Service = UtilityService
    
    typealias PaymentViewModel = ObservingAnywayTransactionViewModel
    typealias UtilityFlowState = UtilityPaymentFlowState<Operator, Service, UtilityPrepaymentViewModel, PaymentViewModel>
    typealias State = UtilityServicePickerFlowState<Operator, Service, PaymentViewModel>.Content
    typealias Event = UtilityPrepaymentFlowEvent<LastPayment, Operator, UtilityService>.Select
}
