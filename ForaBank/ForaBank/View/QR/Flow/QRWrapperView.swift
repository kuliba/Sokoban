//
//  QRWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 19.11.2024.
//

import RxViewModel
import SwiftUI

struct QRWrapperView: View {
    
    let binder: QRScannerDomain.Binder
    let makeQRView: () -> QRScanner_View
    let makePaymentsView: (PaymentsViewModel) -> PaymentsView
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            makeQRView()
                .navigationDestination(
                    destination: state.navigation?.destination,
                    dismiss: { event(.dismiss) },
                    content: destinationContent
                )
        }
    }
}

private extension QRWrapperView {
 
    typealias Destination = QRScannerDomain.Navigation.Destination
    
    @ViewBuilder
    func destinationContent(
        destination: Destination
    ) -> some View {
        
        switch destination {
        case let .payments(payments):
            makePaymentsView(payments.paymentsViewModel)
        }
    }
}

extension QRScannerDomain.Navigation {
    
    var destination: Destination {
        
        switch self {
        case let .payments(payments):
            return .payments(payments)
        }
    }
    
    enum Destination {
        
        case payments(ClosePaymentsViewModelWrapper)
    }
}

extension QRScannerDomain.Navigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .payments(payments):
            return .payments(.init(payments))
        }
    }
    
    enum ID: Hashable {
        
        case payments(ObjectIdentifier)
    }
}
