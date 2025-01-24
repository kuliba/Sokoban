//
//  PaymentProviderPickerDestinationView.swift
//  Vortex
//
//  Created by Igor Malyarov on 28.11.2024.
//

import SwiftUI
import UIPrimitives

struct PaymentProviderPickerDestinationView: View {
    
    let dismiss: () -> Void
    let detailPayment: () -> Void
    let destination: PaymentProviderPickerDomain.Destination
    let components: ViewComponents
    let makeIconView: MakeIconView
    
    var body: some View {
        
        switch destination {            
        case let .detailPayment(node):
            components.makePaymentsView(node.model)
            
        case let .payment(payment):
            paymentView(payment)
            
        case let .servicePicker(servicePicker):
            Text("TBD: destination view \(String(describing: servicePicker))")
            
        case let .servicesFailure(binder):
            components.serviceCategoryFailureView(binder: binder)
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
                .frame(maxHeight: .infinity)
                .navigationBarWithAsyncIcon(
                    title: utilityPaymentOperator.title,
                    subtitle: "ИНН \(utilityPaymentOperator.inn)",
                    dismiss: dismiss,
                    icon: makeMD5HashIconView(utilityPaymentOperator.icon),
                    style: .large
                )
                
            case let .serviceFailure(serviceFailure):
                EmptyView()
            }
            
        case let .success(success):
            switch success {
            case let .services(node):
                let binder = node.model
                
                ProviderServicePickerView(
                    binder: binder,
                    dismiss: dismiss,
                    makeAnywayFlowView: { anywayFlowModel in
                        
                        makeAnywayFlowView(
                            anywayFlowModel: anywayFlowModel,
                            dismiss: { binder.flow.event(.dismiss) }
                        )
                    },
                    makeIconView: makeIconView
                )
                
            case let .startPayment(node):
                makeAnywayFlowView(anywayFlowModel: node.model, dismiss: dismiss)
            }
        }
    }
    
    @ViewBuilder
    func makeAnywayFlowView(
        anywayFlowModel: AnywayFlowModel,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        let payload = anywayFlowModel.state.content.state.transaction.context.outline.payload
        
        components.makeAnywayFlowView(anywayFlowModel)
            .navigationBarWithAsyncIcon(
                title: payload.title,
                subtitle: payload.subtitle,
                dismiss: dismiss,
                icon: iconView(payload.icon),
                style: .normal
            )
    }
    
    func iconView(
        _ icon: String?
    ) -> IconDomain.IconView {
        
        makeIconView(icon.map { .md5Hash(.init($0)) })
    }

    private func makeMD5HashIconView(
        _ icon: String?
    ) -> UIPrimitives.AsyncImage {
        
        makeIconView(icon.map { .md5Hash(.init($0)) })
    }
}
