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
    let factory: QRWrapperViewFactory
    
    var body: some View {
        
        RxWrapperView(model: binder.flow) { state, event in
            
            factory.makeQRView(binder.content.qrScanner)
                .navigationDestination(
                    destination: state.navigation?.destination,
                    dismiss: { event(.dismiss) },
                    content: destinationContent
                )
                .accessibilityIdentifier(ElementIDs.qrScanner.rawValue)
        }
    }
}

struct QRWrapperViewFactory {
    
    let makeQRView: MakeQRView
    let makeQRFailedWrapperView: MakeQRFailedWrapperView
    let makePaymentsView: MakePaymentsView
    let makeComposedSegmentedPaymentProviderPickerFlowView: MakeComposedSegmentedPaymentProviderPickerFlowView
}

private extension QRWrapperView {
    
    typealias Destination = QRScannerDomain.Navigation.Destination
    
    @ViewBuilder
    func destinationContent(
        destination: Destination
    ) -> some View {
        
        switch destination {
        case let .failure(qrFailedViewModel):
            factory.makeQRFailedWrapperView(qrFailedViewModel)
                .accessibilityIdentifier(ElementIDs.qrFailure.rawValue)
            
        case let .payments(payments):
            factory.makePaymentsView(payments)
                .accessibilityIdentifier(ElementIDs.payments.rawValue)
            
        case let .providerPicker(picker):
            factory.makeComposedSegmentedPaymentProviderPickerFlowView(picker)
                .accessibilityIdentifier(ElementIDs.providerPicker.rawValue)
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
            
        case let .providerPicker(node):
            return .providerPicker(node.model)
        }
    }
    
    enum Destination {
        
        case failure(QRFailedViewModelWrapper)
        case payments(PaymentsViewModel)
        case providerPicker(SegmentedPaymentProviderPickerFlowModel)
    }
}

extension QRScannerDomain.Navigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .failure(failure):
            return .failure(.init(failure))
            
        case let .payments(payments):
            return .payments(.init(payments))
            
        case let .providerPicker(picker):
            return .providerPicker(.init(picker))
        }
    }
    
    enum ID: Hashable {
        
        case failure(ObjectIdentifier)
        case payments(ObjectIdentifier)
        case providerPicker(ObjectIdentifier)
    }
}
