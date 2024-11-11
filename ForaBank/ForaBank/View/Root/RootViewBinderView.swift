//
//  RootViewBinderView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.11.2024.
//

import RxViewModel
import SwiftUI

struct RootViewBinderView: View {
    
    let binder: RootDomain.Binder
    let rootViewFactory: RootViewFactory
    
    var body: some View {
        
        RootWrapperView(flow: binder.flow) {
            
            RootView(
                viewModel: binder.content,
                rootViewFactory: rootViewFactory
            )
        }
    }
    
    typealias RootDomain = RootViewDomain<RootViewModel>
}

struct RootWrapperView: View {
    
    @ObservedObject var flow: RootDomain.Flow
    
    let rootView: () -> RootView
    
    var body: some View {
        
        ZStack {
            
            SpinnerView(viewModel: .init())
                .opacity(flow.state.isLoading ? 1 : 0)
                .zIndex(1.0)
            
            RxWrapperView(model: flow) { state, event in
                
                rootView()
                    .fullScreenCover(
                        cover: state.navigation?.fullScreenCover,
                        dismiss: { event(.dismiss) },
                        content: {
                            
                            switch $0 {
                            case .scanQR:
                                Text("TBD: QR Scanner")
                            }
                        }
                    )
            }
        }
    }
    
    typealias RootDomain = RootViewDomain<RootViewModel>
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
