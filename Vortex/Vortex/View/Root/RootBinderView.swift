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
        
        RootWrapperView(
            flow: binder.flow,
            rootView: {
                
                return .init(
                    viewModel: binder.content,
                    rootViewFactory: rootViewFactory
                )
            },
            viewFactory: rootViewFactory
        )
    }
}
