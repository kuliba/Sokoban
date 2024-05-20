//
//  MainMockView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 27.04.2024.
//

import SwiftUI

enum MainMockEvent {
    
    case chat, payments
}

struct MainMockView: View {
    
    let event: (Event) -> Void
    
    var body: some View {
        
        ZStack {
            
            Color.clear
            
            VStack(spacing: 32) {
                
                Button("Open Chat") { event(.chat) }
                Button("Open Payments") { event(.payments) }
            }
        }
        .navigationTitle("Chat")
    }
}

extension MainMockView {
    
    typealias Event = MainMockEvent
}

#Preview {
    MainMockView { print($0) }
}
