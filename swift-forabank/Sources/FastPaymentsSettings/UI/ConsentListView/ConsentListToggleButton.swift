//
//  ConsentListToggleButton.swift
//
//
//  Created by Igor Malyarov on 12.02.2024.
//

import SwiftUI

struct ConsentListToggleButton: View {
    
    let chevronRotationAngle: CGFloat
    let action: () -> Void
    let config: ConsentListConfig.Chevron
    
    var body: some View {
        
        Button(action: action) {
            
            HStack {
                
                "Запросы на переводы из банков".text(withConfig: config.title)
                
                Spacer()
                
                config.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .rotationEffect(.degrees(chevronRotationAngle))
                    .foregroundColor(config.color)
            }
        }
        .contentShape(Rectangle())
    }
}

struct ConsentListToggleButton_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ConsentListToggleButton(
            chevronRotationAngle: 0,
            action: {},
            config: .preview
        )
    }
}
