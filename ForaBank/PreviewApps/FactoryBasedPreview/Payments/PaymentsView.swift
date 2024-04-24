//
//  PaymentsView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI
import UIPrimitives

struct PaymentsView<DestinationView>: View
where DestinationView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            utilityServicePaymentsButton()
        }
        .navigationDestination(
            item: .init(
                get: { state.destination },
                set: { if $0 == nil { event(.dismissDestination) }}
            ),
            content: factory.makeDestinationView
        )
    }
    
    private func utilityServicePaymentsButton(
    ) -> some View {
        
        Button("Utility Service Payments") {
            
            event(.buttonTapped(.utilityService))
        }
    }
}

extension PaymentsView {
    
    typealias State = PaymentsState
    typealias Event = PaymentsEvent
    typealias Effect = PaymentsEffect
    
    typealias Factory = PaymentsViewFactory<DestinationView>
}

extension PaymentsState.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case .utilityServicePayment:
            return .utilityServicePayment
        }
    }
    
    enum ID {
        
        case utilityServicePayment
    }
}

struct PaymentsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            preview(.init())
            preview(.init(destination: .utilityServicePayment))
        }
    }
    
    static func preview(
        _ state: PaymentsState
    ) -> some View {
        
        NavigationView {
            
            PaymentsView(
                state: state,
                event: { _ in },
                factory: .preview
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
