//
//  RootViewBinderView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.11.2024.
//

import RxViewModel
import SwiftUI

struct RootViewBinderView: View {
    
    let binder: RootViewDomain.Binder
    let rootViewFactory: RootViewFactory
    
    var body: some View {
        
        NavigationView {
            
            RootWrapperView(
                flow: binder.flow,
                rootView: {
                    
                    RootView(
                        viewModel: binder.content,
                        rootViewFactory: rootViewFactory
                    )
                },
                viewFactory: rootViewFactory
            )
            .navigationBarHidden(true)
        }
    }
}

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
    
    @ViewBuilder
    func destinationContent(
        destination: RootViewNavigation.Destination
    ) -> some View {
        
        switch destination {
        case let .templates(node):
            templatesView(node)
        }
    }
    
    private func templatesView(
        _ templates: RootViewNavigation.TemplatesNode
    ) -> some View {

        viewFactory.components.makeTemplatesListFlowView(templates)
            .accessibilityIdentifier(ElementIDs.rootView(.destination(.templates)).rawValue)
    }
    
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
            makeQRView: { components.makeQRView(binder.content.qrScanner) },
            makePaymentsView: components.makePaymentsView
        )
    }
}

extension RootViewNavigation {
    
    var destination: Destination? {
        
        switch self {
        case .scanQR:
            return nil
            
        case let .templates(node):
            return .templates(node)
        }
    }
    
    enum Destination {
        
        case templates(TemplatesNode)
        
        typealias TemplatesNode = RootViewNavigation.TemplatesNode
    }
    
    var fullScreenCover: FullScreenCover? {
        
        switch self {
        case let .scanQR(node):
            return .scanQR(node.model)
            
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
        case let .templates(templates):
            return .templates(.init(templates.model))
        }
    }
    
    enum ID: Hashable {
        
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
