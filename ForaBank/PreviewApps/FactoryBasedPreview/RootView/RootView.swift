//
//  RootView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

struct RootView<Content, Spinner>: View
where Content: View,
      Spinner: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    var body: some View {
        
        ZStack {
            
            factory.makeContent()
            
            if state.spinner == .on {
                
                factory.makeSpinner()
                    .ignoresSafeArea()
            }
        }
        .animation(.easeInOut, value: state)
    }
}

extension RootView {
    
    typealias State = RootState
    typealias Event = RootEvent
    typealias Factory = RootViewFactory<Content, Spinner>
}

struct RootView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            rootView(.off)
            rootView(.on)
        }
    }
    
    private static func rootView(
        _ spinner: SpinnerState
    ) -> some View {
        
        RootView(
            state: .init(spinner: spinner),
            event: { print($0) },
            factory: makeFactory()
        )
    }
    
    private static func makeFactory(
    ) -> RootViewFactory<Text, SpinnerView> {
        
        .init(
            makeContent: { Text("RootView Content") },
            makeSpinner: SpinnerView.init
        )
    }
}
