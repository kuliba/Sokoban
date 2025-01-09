//
//  ContentView.swift
//  PhoneNumberTextViewPreview
//
//  Created by Igor Malyarov on 09.01.2025.
//

import SwiftUI

struct ContentView: View {
    
    @State private var tab: Tab = .first
    
    var body: some View {
        
        TabView(selection: $tab) {
            
            MaskedTextFieldWrapperView()
                .tabItem { Label("Masked", systemImage: "theatermasks") }
                .tag(Tab.first)
            
            PhoneNumberTextContentView()
                .tabItem { Label("Previous", systemImage: "list.bullet.rectangle") }
                .tag(Tab.second)
        }
    }
}

private extension ContentView {
    
    enum Tab: String {
        
        case first, second
    }
}

#Preview {
    
    ContentView()
}
