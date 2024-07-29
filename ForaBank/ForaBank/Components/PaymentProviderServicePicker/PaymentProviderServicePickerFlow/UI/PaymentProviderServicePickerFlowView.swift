//
//  PaymentProviderServicePickerFlowView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.07.2024.
//

import SwiftUI

struct PaymentProviderServicePickerFlowView<ContentView, DestinationContent>: View
where ContentView: View,
      DestinationContent: View {
    
    @ObservedObject var model: Model
    
    let contentView: (Content) -> ContentView
    let alertContent: (ServiceFailureAlert) -> Alert
    let destinationContent: (Destination) -> DestinationContent
    
    var body: some View {
        
        contentView(model.state.content)
            .alert(
                item: model.state.alert,
                content: alertContent
            )
            .navigationDestination(
                destination: model.state.destination,
                dismissDestination: { model.event(.dismissDestination) },
                content: destinationContent
            )
    }
}

extension PaymentProviderServicePickerFlowView {
    
    typealias Model = PaymentProviderServicePickerFlowModel
    typealias Content = Model.State.Content
    typealias Destination = Model.State.Destination
}

extension PaymentProviderServicePickerFlowState.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .payment:
            return .payment
            
        case .paymentByInstruction:
            return .paymentByInstruction
        }
    }
    
    enum ID: Hashable {
        
        case payment
        case paymentByInstruction
    }
}

#Preview {
    
    PaymentProviderServicePickerFlowView(
        model: .init(
            initialState: .init(
                content: .init(
                    initialState: .init(payload: .preview),
                    reduce: { state, _ in (state, nil) },
                    handleEffect: { _,_ in }
                )
            ),
            factory: .init(
                makeServicePaymentBinder: { .preview(transaction: $0) }
            ),
            reduce: { state, _ in (state, nil) },
            handleEffect: { _,_ in }
        ),
        contentView: { _ in Text("ContentView") },
        alertContent: { alert in
            
            return .init(with: .init(
                title: "Error",
                message: {
                    
                    switch alert.serviceFailure {
                    case .connectivityError:
                        return "Some Error"
                        
                    case let .serverError(errorMessage):
                        return errorMessage
                    }
                }(),
                primary: .init(
                    type: .default,
                    title: "OK",
                    action: { print("dismiss alert") }
                )
            ))
        },
        destinationContent: {
            
            switch $0 {
            case .payment:
                Text("DestinationView: payment")
                
            case .paymentByInstruction:
                Text("DestinationView: paymentByInstruction")
            }
        }
    )
}
