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
        
        RootWrapperView(
            flow: binder.flow,
            rootView: {
                
                RootView(
                    viewModel: binder.content,
                    rootViewFactory: rootViewFactory
                )
            },
            makeQRScannerView: rootViewFactory.components.makeQRView
        )
    }
}

struct RootWrapperView: View {
    
    @ObservedObject var flow: RootViewDomain.Flow
    
    let rootView: () -> RootView
    let makeQRScannerView: MakeQRView
    
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
            }
        }
    }
}

private extension RootWrapperView {
    
    @ViewBuilder
    func fullScreenCoverContent(
        fullScreenCover: RootViewDomain.Navigation.FullScreenCover
    ) -> some View {
        
        switch fullScreenCover {
        case let .scanQR(qrScanner):
            makeQRScannerView(qrScanner)
                .accessibilityIdentifier(ElementIDs.rootView(.qrFullScreenCover).rawValue)
        }
    }
}

extension RootViewDomain.Navigation {
    
    var fullScreenCover: FullScreenCover? {
        
        switch self {
        case let .scanQR(node):
            return .scanQR(node.model.qrModel)
        }
    }
    
    enum FullScreenCover {
        
        case scanQR(QRViewModel)
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
