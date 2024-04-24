//
//  ContentView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

import SwiftUI

struct ContentView<RootView>: View
where RootView: View {
    
    let factory: ContentViewFactory<RootView>
    
    var body: some View {
        
        factory.makeRootView()
    }
}

struct ContentViewFactory<RootView>
where RootView: View {
    
    let makeRootView: () -> RootView
}

#Preview {
    ContentView(
        factory: .init(
            makeRootView: { Text("Root View here.") }
        )
    )
}
