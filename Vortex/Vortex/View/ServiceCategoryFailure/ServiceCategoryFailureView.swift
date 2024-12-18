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
                .frame(maxHeight: .infinity)
                .navigationDestination(
                    destination: state.destination,
                    dismiss: { event(.dismiss) },
                    content: destinationView
                )
                .navigationBarWithBack(
                    title: binder.content.name,
                    dismiss: { binder.flow.event(.dismiss) },
                    rightItem: .barcodeScanner(
                        action: { binder.flow.event(.select(.scanQR)) }
                    )
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
            state: .failure(.iVortex),
            event: { event in
                
                switch event {
                case .payByInstruction:
                    binder.flow.event(.select(.detailPayment))
                    
                case .addCompany:
                    break
                }
            },
            config: .iVortex
        )
    }
}

extension ServiceCategoryFailureDomain.FlowDomain.State {
    
    var destination: Destination? {
        
        switch navigation {
        case .none, .scanQR:
            return nil
            
        case let .detailPayment(node):
            return .detailPayment(node.model)
        }
    }
    
    enum Destination {
        
        case detailPayment(PaymentsViewModel)
    }
}

extension ServiceCategoryFailureDomain.Destination: Identifiable {
    
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
