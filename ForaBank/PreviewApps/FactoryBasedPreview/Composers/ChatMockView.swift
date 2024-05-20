//
//  ChatMockView.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 27.04.2024.
//

import SwiftUI

enum ChatMockEvent: Equatable {
    
    case goToMain
}

struct ChatMockView: View {
    
    let event: (Event) -> Void
    
    var body: some View {
        
        ZStack {
            
            Color.clear
            
            Button("Go to Main") { event(.goToMain) }
        }
        .navigationTitle("Chat")
    }
}

extension ChatMockView {
    
    typealias Event = ChatMockEvent
}

#Preview {
    ChatMockView { _ in }
}
