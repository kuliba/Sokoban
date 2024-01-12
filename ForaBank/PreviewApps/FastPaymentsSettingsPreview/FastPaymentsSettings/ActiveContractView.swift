//
//  ActiveContractView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 12.01.2024.
//

import SwiftUI

struct ActiveContractView: View {
    
    let action: () -> Void
    
    var body: some View {
        
        HStack(spacing: 16) {
            
            Color.green
                .clipShape(.circle)
                .frame(width: 64, height: 64)
            
            Button("Выключить переводы СБП", action: action)
        }
    }
}

struct ActiveContractView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ActiveContractView  {}
    }
}
