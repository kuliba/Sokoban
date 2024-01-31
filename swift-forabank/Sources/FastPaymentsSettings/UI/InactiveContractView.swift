//
//  InactiveContractView.swift
//  
//
//  Created by Igor Malyarov on 13.01.2024.
//

import SwiftUI

struct InactiveContractView: View {
    
    let action: () -> Void
    let config: InactiveContractConfig
    
    var body: some View {
        
        List {
            
            Button("Включить переводы СБП", action: action)
            
            HStack(spacing: 16) {
                
                Text("Переводы выключены")
                    .font(.subheadline)
                
                ToggleMockView(status: .inactive)
            }
        }
    }
}

struct InactiveContractView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        InactiveContractView(
            action: {},
            config: .preview
        )
    }
}
