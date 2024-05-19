//
//  ContentView.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 19.05.2024.
//

import SwiftUI

struct ContentView: View {
    
    init() {
        
    }
    
    var body: some View {
        
        TransactionStateWrapperView(initialState: .preview)
    }
}

#Preview {
    ContentView()
}
