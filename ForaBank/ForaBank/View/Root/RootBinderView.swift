//
//  RootViewBinderView.swift
//  Vortex
//
//  Created by Igor Malyarov on 08.11.2024.
//

import SwiftUI

struct RootBinderView: View {
    
    let binder: RootViewDomain.Binder
    let rootViewFactory: RootViewFactory
    
    var body: some View {
        
        NavigationView {
            
            rootViewFactory.makeRootWrapperView(binder: binder)
                .navigationBarHidden(true)
        }
    }
}

extension RootViewFactory {
    
    func makeRootWrapperView(
        binder: RootViewDomain.Binder
    ) -> RootWrapperView {
        
        return .init(
            flow: binder.flow,
            rootView: {
                
                .init(viewModel: binder.content, rootViewFactory: self)
            },
            viewFactory: self
        )
    }
}
