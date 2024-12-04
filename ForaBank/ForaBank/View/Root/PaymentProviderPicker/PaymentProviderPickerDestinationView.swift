//
//  PaymentProviderPickerDestinationView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 28.11.2024.
//

import SwiftUI

struct PaymentProviderPickerDestinationView: View {
    
    let destination: PaymentProviderPickerDomain.Navigation
    let components: ViewComponents
    
    var body: some View {
        
        switch destination {
        case let .backendFailure(backendFailure):
            Text("TBD: destination view \(String(describing: backendFailure))")
            
        case let .detailPayment(wrapper):
            components.makePaymentsView(wrapper.paymentsViewModel)
            
        case let .payment(payment):
            Text("TBD: destination view \(String(describing: payment))")
            
        case let .servicePicker(servicePicker):
            Text("TBD: destination view \(String(describing: servicePicker))")
            
        case let .servicesFailure(servicesFailure):
            Text("TBD: destination view \(String(describing: servicesFailure))")
        }
    }
}
