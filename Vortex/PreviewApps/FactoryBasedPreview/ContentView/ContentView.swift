//
//  ContentView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

struct ContentView<RootView>: View
where RootView: View {
    
    let state: RootState
    let factory: Factory
    
    var body: some View {
        
        factory.makeRootView(state)
    }
}

extension ContentView {
    
    typealias Factory = ContentViewFactory<RootView>
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        preview()
        preview(spinner: .on)
    }
    
    private static func preview(
        spinner: SpinnerState = .off
    ) -> some View {
        
        ContentView(
            state: .init(spinner: spinner),
            factory: .init(makeRootView: { Text(String(describing: $0)) })
        )
    }
}
