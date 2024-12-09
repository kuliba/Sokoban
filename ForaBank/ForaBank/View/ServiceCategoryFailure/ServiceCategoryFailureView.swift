//
//  ServiceCategoryFailureView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.12.2024.
//

import FooterComponent
import RxViewModel
import SwiftUI

struct ServiceCategoryFailureView<DestinationView: View>: View {
    
    let binder: Binder
    let destinationView: (Destination) -> DestinationView
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            contentView()
                .navigationDestination(
                    destination: state.navigation,
                    dismiss: { event(.dismiss) },
                    content: destinationView
                )
        }
    }
}

extension ServiceCategoryFailureView {
    
    typealias Domain = ServiceCategoryFailureDomain
    typealias Binder = Domain.Binder
    typealias Destination = Domain.Destination
}

extension ServiceCategoryFailureView {
    
    func contentView() -> some View {
        
        FooterView(
            state: .failure(.iFora),
            event: { event in
                
                switch event {
                case .payByInstruction:
                    binder.flow.event(.select(.detailPayment))
                    
                case .addCompany:
                    break
                }
            },
            config: .iFora
        )
    }
}

extension ServiceCategoryFailureDomain.Navigation: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .detailPayment(paymentsViewModel):
            return .detailPayment(.init(paymentsViewModel))
        }
    }
    
    enum ID: Hashable {
        
        case detailPayment(ObjectIdentifier)
    }
}
