//
//  PaymentsView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI
import UIPrimitives

struct PaymentsView<DestinationView, PaymentButtonLabel>: View
where DestinationView: View,
      PaymentButtonLabel: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 16) {
                
                ForEach(PaymentButton.allCases, content: paymentButton)
            }
        }
        .navigationDestination(
            item: .init(
                get: { state.destination },
                set: { if $0 == nil { event(.dismissDestination) }}
            ),
            content: factory.makeDestinationView
        )
    }
    
    private func paymentButton(
        button: PaymentButton
    ) -> some View {
        
        Button(
            action: { event(.payment(.buttonTapped(button.button))) },
            label: { factory.makePaymentButtonLabel(button.button) }
        )
    }
}

extension PaymentsView {
    
    typealias State = PaymentsState
    typealias Event = PaymentsEvent
    
    typealias Factory = PaymentsViewFactory<DestinationView, PaymentButtonLabel>
}

private enum PaymentButton: CaseIterable {
    
    case mobile
    case utilityService
    
    init(_ button: PaymentEvent.PaymentButton) {
        
        switch button {
        case .mobile:
            self = .mobile
            
        case .utilityService:
            self = .utilityService
        }
    }
    
    var button: PaymentEvent.PaymentButton {
        
        switch self {
        case .mobile:
            return .mobile
            
        case .utilityService:
            return .utilityService
        }
    }
}

extension PaymentButton: Identifiable {
    
    var id: ID {
        
        switch self {
        case .mobile:
            return .mobile
            
        case .utilityService:
            return .utilityService
        }
    }
    
    enum ID {
        
        case mobile
        case utilityService
    }
}

extension PaymentsState.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .utilityService:
            return .utilityService
        }
    }
    
    enum ID: Hashable {
        
        case utilityService
    }
}

struct PaymentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            preview(.preview())
            preview(.preview(.utilityService(.prepayment(.empty))))
            preview(.preview(.utilityService(.prepayment(.preview))))
        }
    }
    
    static func preview(
        _ state: PaymentsState
    ) -> some View {
        
        NavigationView {
            
            PaymentsView(
                state: state,
                event: { print($0) },
                factory: .preview()
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
