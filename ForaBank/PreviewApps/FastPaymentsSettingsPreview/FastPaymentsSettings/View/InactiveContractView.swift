//
//  InactiveContractView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

import SwiftUI

struct InactiveContractView: View {

    let action: () -> Void

    var body: some View {

        HStack(spacing: 16) {
            
            Color.black
                .clipShape(.circle)
                .frame(width: 64, height: 64)
            
            Button("Включить переводы СБП", action: action)
        }
    }
}

struct InactiveContractView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        InactiveContractView(action: {})
    }
}
