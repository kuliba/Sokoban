//
//  PaymentProviderPickerDestinationView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 28.11.2024.
//

import SwiftUI

struct PaymentProviderPickerDestinationView: View {
    
    let dismiss: () -> Void
    let detailPayment: () -> Void
    let destination: PaymentProviderPickerDomain.Navigation
    let components: ViewComponents
    let makeIconView: MakeIconView
    
    var body: some View {
        
        switch destination {
        case let .backendFailure(backendFailure):
            Text("TBD: destination view \(String(describing: backendFailure))")
            
        case let .detailPayment(wrapper):
            components.makePaymentsView(wrapper.paymentsViewModel)
            
        case let .payment(payment):
            paymentView(payment)
            
        case let .servicePicker(servicePicker):
            Text("TBD: destination view \(String(describing: servicePicker))")
            
        case let .servicesFailure(servicesFailure):
            Text("TBD: destination view \(String(describing: servicesFailure))")
        }
    }
}

private extension PaymentProviderPickerDestinationView {
    
    @ViewBuilder
    func paymentView(
        _ payment: PaymentProviderPickerDomain.Payment
    ) -> some View {
        
        switch payment {
        case let .failure(failure):
            switch failure {
            case let .operatorFailure(utilityPaymentOperator):
                components.operatorFailureView(
                    operatorFailure: .init(content: utilityPaymentOperator), 
                    payByInstructions: detailPayment,
                    dismissDestination: dismiss
                )
                
            case let .serviceFailure(serviceFailure):
                Text("TBD: destination view \(String(describing: serviceFailure))")
            }
            
        case let .success(success):
            switch success {
            case let .services(milti, for: utilityPaymentOperator):
                // components.makeAnywayServicePickerFlowView(<#T##AnywayServicePickerFlowModel#>)
                Text("TBD: destination view \(String(describing: milti))")
                
            case let .anywayPayment(anywayPayment):
                let payload = anywayPayment.state.content.state.transaction.context.outline.payload
                
                components.makeAnywayFlowView(anywayPayment)
                    .navigationBarWithAsyncIcon(
                        title: payload.title,
                        subtitle: payload.subtitle,
                        dismiss: dismiss,
                        icon: makeIconView(payload.icon.map { .md5Hash(.init($0)) }),
                        style: .normal
                    )
            }
        }
    }
}
