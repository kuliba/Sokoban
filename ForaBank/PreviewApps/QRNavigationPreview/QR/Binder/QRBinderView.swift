//
//  QRBinderView.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import RxViewModel
import SwiftUI

struct QRBinderView: View {
    
    let binder: QRDomain.Binder
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            content
                .navigationDestination(
                    destination: state.destination,
                    dismiss: { event(.dismiss) },
                    content: {
                        
                        switch $0 {
                        case let .payments(payments):
                            PaymentsView(model: payments)
                            
                        case let .qrFailure(qrFailure):
                            QRFailureBinderView(binder: qrFailure)
                        }
                    }
                )
        }
    }
    
    private var content: some View {
        
        ZStack(alignment: .bottom) {
            
            ZStack(alignment: .top) {
                
                Color.clear
                
                QRContentView(model: binder.content)
                    .navigationTitle("QR Scanner")
            }
            
            Button("Cancel* - see print") {
                
                binder.content.close()
                print("dismiss: in the app QRModelWrapper has state case `cancelled` - which should be observed")
            }
            .foregroundColor(.red)
        }
    }
}

extension QRDomain.FlowDomain.State {
    
    var destination: Destination? {
        
        switch navigation {
        case .none:
            return nil
            
        case let .payments(node):
            return .payments(node.model)
            
        case let .qrFailure(node):
            return .qrFailure(node.model)
        }
    }
    
    enum Destination {
        
        case payments(Payments)
        case qrFailure(QRFailureDomain.Binder)
    }
}

extension QRDomain.FlowDomain.State.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .payments(payments):
            return .payments(.init(payments))
            
        case let .qrFailure(qrFailure):
            return .qrFailure(.init(qrFailure))
        }
    }
    
    enum ID: Hashable {
        
        case payments(ObjectIdentifier)
        case qrFailure(ObjectIdentifier)
    }
}
