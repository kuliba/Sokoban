//
//  ContentView.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 14.08.2024.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        TabWrapperView(
            model: .init(), 
            factory: .init(
                makeContent: { Text("TBD: \($0.tabTitle)") }
            )
        )
    }
}

#Preview {
    ContentView()
}
