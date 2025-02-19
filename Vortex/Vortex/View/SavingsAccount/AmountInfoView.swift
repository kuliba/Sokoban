//  AmountInfoView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 04.02.2025.
//

import SwiftUI

struct AmountInfoView: View {
    
    var body: some View {
        
        HStack {
            
            "Без комиссии".text(
                withConfig: .init(
                    textFont: .textBodySR12160(),
                    textColor: .textPlaceholder)
            )
            
            Image.ic16Info
                .foregroundColor(.textPlaceholder)
        }
    }
}

#Preview {
    AmountInfoView()
}
