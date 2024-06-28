//
//  HorizontalPanelButton.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 27.06.2024.
//

import SwiftUI

struct HorizontalPanelButton: View {
    
    let details: PanelButtonDetails
    let event: () -> Void
    let config: ControlPanelView.Config
    
    var body: some View {
        
        Button(action: event) {
            
            VStack() {
                
                details.icon.map {
                    $0
                        .renderingMode(.original)
                        .frame(width: config.height, height: config.height)
                        .background(config.colors.background)
                        .cornerRadius(config.height/2)
                }
                
                Text(details.title)
                    .font(config.fonts.title)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 80, height: 35)
            }
            .frame(height: config.height)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(PushButtonStyle())
        .foregroundColor(config.colors.title)
        .fixedSize()
    }
}
