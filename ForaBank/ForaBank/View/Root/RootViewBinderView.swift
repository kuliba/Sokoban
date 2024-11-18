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
        
        RootWrapperView(flow: binder.flow) {
            
            RootView(
                viewModel: binder.content,
                rootViewFactory: rootViewFactory
            )
        }
    }
}

struct RootWrapperView: View {
    
    @ObservedObject var flow: RootViewDomain.Flow
    
    let rootView: () -> RootView
    
    var body: some View {
        
        ZStack {
            
            SpinnerView(viewModel: .init())
                .opacity(flow.state.isLoading ? 1 : 0)
                .zIndex(1.0)
            
            RxWrapperView(model: flow) { state, event in
                
                rootView()
                    .fullScreenCoverInspectable(
                        item: .init(
                            get: { state.navigation?.fullScreenCover },
                            set: { if $0 == nil { event(.dismiss) }}
                        ),
                        content: {
                            
                            switch $0 {
                            case .scanQR:
                                Text("TBD: QR Scanner")
                                    .accessibilityIdentifier(ElementIDs.rootView(.qrFullScreenCover).rawValue)
                            }
                        }
                    )
            }
        }
    }
}

extension RootViewDomain.Navigation {
    
    var fullScreenCover: FullScreenCover? {
        
        switch self {
        case .scanQR: return .scanQR
        }
    }
    
    enum FullScreenCover {
        
        case scanQR
    }
}

extension RootViewDomain.Navigation.FullScreenCover: Identifiable {
    
    var id: ID {
        
        switch self {
        case .scanQR: return .scanQR
        }
    }
    
    enum ID: Hashable {
        
        case scanQR
    }
}
