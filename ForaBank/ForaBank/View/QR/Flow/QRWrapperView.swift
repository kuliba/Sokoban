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
    let makeQRFailureView: (QRFailedViewModelWrapper) -> QRFailedViewModelWrapperView
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            makeQRView()
                .navigationDestination(
                    destination: state.navigation?.destination,
                    dismiss: { event(.dismiss) },
                    content: destinationContent
                )
                .accessibilityIdentifier(ElementIDs.qrScanner.rawValue)
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
        case let .failure(qrFailedViewModel):
            makeQRFailureView(qrFailedViewModel)
                .accessibilityIdentifier(ElementIDs.qrFailure.rawValue)
            
        case let .payments(payments):
            makePaymentsView(payments)
                .accessibilityIdentifier(ElementIDs.payments.rawValue)
        }
    }
}

extension QRScannerDomain.Navigation {
    
    var destination: Destination? {
        
        switch self {
        case let .failure(qrFailedViewModel):
            return .failure(qrFailedViewModel)
            
        case .outside:
            return nil
            
        case let .payments(node):
            return .payments(node.model)
        }
    }
    
    enum Destination {
        
        case failure(QRFailedViewModelWrapper)
        case payments(PaymentsViewModel)
    }
}

extension QRScannerDomain.Navigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .failure(failure):
            return .failure(.init(failure))
            
        case let .payments(payments):
            return .payments(.init(payments))
        }
    }
    
    enum ID: Hashable {
        
        case failure(ObjectIdentifier)
        case payments(ObjectIdentifier)
    }
}
