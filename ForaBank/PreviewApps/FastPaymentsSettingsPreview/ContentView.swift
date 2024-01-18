//
//  ContentView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var demo: Demo = .fastPaymentsSettings
    
    var body: some View {
        
        ZStack {
            
            Color.clear
            
            Group {
                
                switch demo {
                case .consent:
                    ConsentListPrototypeView()
                    
                case .fastPaymentsSettings:
                    FPSPrototypeView()
                }
            }
        }
        .overlay(alignment: .bottomLeading, content: picker)
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
        
        case consent, fastPaymentsSettings
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView()
    }
}
