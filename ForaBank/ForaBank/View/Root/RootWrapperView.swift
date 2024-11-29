//
//  RootWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 28.11.2024.
//

import RxViewModel
import SwiftUI

struct RootWrapperView: View {
    
    @ObservedObject var flow: RootViewDomain.Flow
    
    let rootView: () -> RootView
    let viewFactory: RootViewFactory
    
    var body: some View {
        
        ZStack {
            
            SpinnerView(viewModel: .init())
                .opacity(flow.state.isLoading ? 1 : 0)
                .zIndex(1.0)
            
            RxWrapperView(model: flow) { state, event in
                
                rootView()
                    .fullScreenCoverInspectable(
                        item: { state.navigation?.fullScreenCover },
                        dismiss: { event(.dismiss) },
                        content: fullScreenCoverContent
                    )
                    .navigationDestination(
                        destination: state.navigation?.destination,
                        dismiss: { event(.dismiss) },
                        content: destinationContent
                    )
            }
        }
    }
}

private extension RootWrapperView {
    
    // MARK: - Destination
    
    @ViewBuilder
    func destinationContent(
        destination: RootViewNavigation.Destination
    ) -> some View {
        
        switch destination {
        case let .standardPayment(picker):
            standardPaymentView(picker)
            
        case let .templates(node):
            templatesView(node)
        }
    }
    
    private func standardPaymentView(
        _ picker: PaymentProviderPicker.Binder
    ) -> some View {
        
        viewFactory.makePaymentProviderPickerView(picker)
            .accessibilityIdentifier(ElementIDs.rootView(.destination(.standardPayment)).rawValue)
    }
    
    private func templatesView(
        _ templates: RootViewNavigation.TemplatesNode
    ) -> some View {
        
        viewFactory.components.makeTemplatesListFlowView(templates)
            .accessibilityIdentifier(ElementIDs.rootView(.destination(.templates)).rawValue)
    }
    
    // MARK: - FullScreenCover
    
    @ViewBuilder
    func fullScreenCoverContent(
        fullScreenCover: RootViewNavigation.FullScreenCover
    ) -> some View {
        
        switch fullScreenCover {
        case let .scanQR(qrScanner):
            qrScannerView(qrScanner)
        }
    }
    
    private func qrScannerView(
        _ qrScanner: QRScannerDomain.Binder
    ) -> some View {
        
        NavigationView {
            
            viewFactory.makeQRScannerView(qrScanner)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .accessibilityIdentifier(ElementIDs.rootView(.qrFullScreenCover).rawValue)
    }
}

extension RootViewFactory {
    
    func makeQRScannerView(
        _ binder: QRScannerDomain.Binder
    ) -> some View {
        
        return QRWrapperView(
            binder: binder,
            factory: .init(
                makeAnywayServicePickerFlowView: components.makeAnywayServicePickerFlowView,
                makeOperatorView: InternetTVDetailsView.init,
                makePaymentsView: components.makePaymentsView,
                makeQRFailedWrapperView: components.makeQRFailedWrapperView,
                makeQRSearchOperatorView: components.makeQRSearchOperatorView,
                makeQRView: components.makeQRView,
                makeSberQRConfirmPaymentView: makeSberQRConfirmPaymentView,
                makeSegmentedPaymentProviderPickerView: components.makeSegmentedPaymentProviderPickerView
            )
        )
    }
}

extension RootViewNavigation {
    
    var destination: Destination? {
        
        switch self {
            // TODO: make alert
        case .failure:
            return nil
            
        case .outside:
            return nil
            
        case .scanQR:
            return nil
            
        case let .standardPayment(node):
            return .standardPayment(node.model)
            
        case let .templates(node):
            return .templates(node)
        }
    }
    
    enum Destination {
        
        case standardPayment(PaymentProviderPicker.Binder)
        case templates(TemplatesNode)
        
        typealias TemplatesNode = RootViewNavigation.TemplatesNode
    }
    
    var fullScreenCover: FullScreenCover? {
        
        switch self {
        case .failure:
            return nil
            
        case .outside:
            return nil
            
        case let .scanQR(node):
            return .scanQR(node.model)
            
        case .standardPayment:
            return nil
            
        case .templates:
            return nil
        }
    }
    
    enum FullScreenCover {
        
        case scanQR(QRScannerDomain.Binder)
    }
}

extension RootViewNavigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .standardPayment(picker):
            return .standardPayment(.init(picker))
            
        case let .templates(templates):
            return .templates(.init(templates.model))
        }
    }
    
    enum ID: Hashable {
        
        case standardPayment(ObjectIdentifier)
        case templates(ObjectIdentifier)
    }
}

extension RootViewNavigation.FullScreenCover: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .scanQR(qrRScanner):
            return .scanQR(.init(qrRScanner))
        }
    }
    
    enum ID: Hashable {
        
        case scanQR(ObjectIdentifier)
    }
}
