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
        
        VStack(spacing: 16) {
            
            Button("Включить переводы СБП", action: action)
            
            HStack(spacing: 16) {
                
                Capsule(style: .continuous)
                    .strokeBorder(.gray)
                    .frame(width: 48, height: 24)
                    .overlay(alignment: .leading) {
                        Color.black
                            .clipShape(.circle)
                            .frame(width: 24, height: 24)
                    }
                
                Text("Переводы выключены")
                    .font(.subheadline)
            }
        }
    }
}

struct InactiveContractView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        InactiveContractView(action: {})
    }
}
