//
//  QRFailureBinderView.swift
//  QRNavigationPreviewTests
//
//  Created by Igor Malyarov on 06.11.2024.
//

import PayHubUI
import RxViewModel
import SwiftUI

struct QRFailureBinderView: View {
    
    let binder: QRFailureDomain.Binder
    
    var body: some View {
        
        RxWrapperView(
            model: binder.flow,
            makeContentView: { state, event in
                
                QRFailureView(qrFailure: binder.content)
                    .navigationDestination(
                        destination: state.destination,
                        dismiss: { event(.dismiss) },
                        content: {
                            
                            switch $0 {
                            case let .categories(categories):
                                CategoriesView(model: categories)
                                
                            case let .detailPayment(detailPayment):
                                PaymentsView(model: detailPayment)
                            }
                        }
                    )
            }
        )
    }
}

private extension QRFailureDomain.FlowDomain.State {
    
    var destination: QRFailureDomain.Flow.Destination? {
        
        switch navigation {
        case .none, .scanQR:
            return nil
            
        case let .categories(node):
            return .categories(node.model)
            
        case let .detailPayment(node):
            return .detailPayment(node.model)
        }
    }
}

private extension QRFailureDomain.Flow {
    
    enum Destination {
        
        case categories(Categories)
        case detailPayment(Payments)
    }
}

extension QRFailureDomain.Flow.Destination: Identifiable {
    
    public var id: ID {
        
        switch self {
        case let .categories(categories):
            return .categories(.init(categories))
            
        case let .detailPayment(payments):
            return .detailPayment(.init(payments))
        }
    }
    
    public enum ID: Hashable {
        
        case categories(ObjectIdentifier)
        case detailPayment(ObjectIdentifier)
    }
}
