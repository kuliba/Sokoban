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
            
            factory.makeContent({ event($0) })
            
            if state == .on {
                
                factory.makeSpinner()
                    .ignoresSafeArea()
            }
        }
    }
}

extension RootView {
    
    typealias State = SpinnerState
    typealias Event = SpinnerEvent
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
        _ state: SpinnerState
    ) -> some View {
        
        RootView(
            state: state,
            event: { _ in },
            factory: makeFactory()
        )
    }
    
    private static func makeFactory(
    ) -> RootViewFactory<Text, SpinnerView> {
        
        .init(
            makeContent: { _ in Text("RootView Content") },
            makeSpinner: SpinnerView.init
        )
    }
    
    private struct SpinnerView: View {
        
        var body: some View {
            
            ZStack {
                
                Color.secondary.opacity(0.3)
                
                ProgressView()
            }
        }
    }
}
