//
//  QRView.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import RxViewModel
import SwiftUI

struct QRView: View {
    
    let binder: QRDomain.Binder
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            QRFlowView(
                state: state,
                event: event,
                contentView: {
                    
                    QRContentView(model: binder.content)
                        .navigationTitle("QR Scanner")
                },
                destinationView: {
                    
                    switch $0 {
                    case let .payments(payments):
                        PaymentsView(model: payments)
                    }
                }
            )
        }
    }
}
