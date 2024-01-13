//
//  ContentView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var demo: Demo = .consent
    
    var body: some View {
        
        ZStack {
            
            Color.clear
            
            Group {
                
                switch demo {
                case .consent:
                    ConsentListPrototypeView(initialState: .collapsedError)
                    
                case .fps:
                    FPSPrototypeView()
                }
            }
        }
        .overlay(alignment: .topLeading, content: picker)
    }
    
    private func picker() -> some View {
        
        Picker("Select Demo", selection: $demo) {
            
            ForEach(Demo.allCases, id: \.self) {
                
                Text($0.rawValue).tag($0)
            }
        }
        .pickerStyle(.menu)
    }
}

private extension ContentView {
    
    enum Demo: String, CaseIterable {
        
        case consent, fps
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView()
    }
}
