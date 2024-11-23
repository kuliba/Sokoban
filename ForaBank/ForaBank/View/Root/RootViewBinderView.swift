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
                makeQRScannerView: { binder in
                    
                    let components = rootViewFactory.components
                    
                    return QRWrapperView(
                        binder: binder,
                        makeQRView: { components.makeQRView(binder.content.qrScanner) },
                        makePaymentsView: components.makePaymentsView
                    )
                }
            )
            .navigationBarHidden(true)
        }
    }
}
struct RootWrapperView: View {
    
    @ObservedObject var flow: RootViewDomain.Flow
    
    let rootView: () -> RootView
    let makeQRScannerView: MakeQRView
    
    typealias MakeQRView = (QRScannerDomain.Binder) -> QRWrapperView
    
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
        destination: RootViewDomain.Navigation.Destination
    ) -> some View {
        
        switch destination {
        case let .templates:
            Text("TBD: Templates")
                .accessibilityIdentifier(ElementIDs.rootView(.destination(.templates)).rawValue)
        }
    }
    
    @ViewBuilder
    func fullScreenCoverContent(
        fullScreenCover: RootViewDomain.Navigation.FullScreenCover
    ) -> some View {
        
        switch fullScreenCover {
        case let .scanQR(qrScanner):
            NavigationView {
                
                makeQRScannerView(qrScanner)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarHidden(true)
            }
            .navigationViewStyle(.stack)
            .accessibilityIdentifier(ElementIDs.rootView(.qrFullScreenCover).rawValue)
        }
    }
}

extension RootViewDomain.Navigation {
    
    var destination: Destination? {
        
        switch self {
        case .scanQR:
            return nil
            
        case .templates:
            return .templates
        }
    }
    
    enum Destination {
        
        case templates
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

extension RootViewDomain.Navigation.Destination: Identifiable {
    
    var id: ID {
        
        switch self {
        case let .templates:
            return .templates
        }
    }
    
    enum ID: Hashable {
        
        case templates//(ObjectIdentifier)
    }
}

extension RootViewDomain.Navigation.FullScreenCover: Identifiable {
    
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
