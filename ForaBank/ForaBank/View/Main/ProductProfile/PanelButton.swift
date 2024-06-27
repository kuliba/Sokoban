//
//  PanelButton.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 09.04.2024.
//

import SwiftUI

struct PanelButton: View {
    
    let details: PanelButtonDetails
    let event: () -> Void
    let config: PanelView.Config
    
    var body: some View {

        Button(action: event) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                HStack(spacing: config.spacings.hstack) {
                    
                    details.icon.map {
                        $0
                            .renderingMode(.original)
                            .frame(width: config.height, height: config.height)
                            .background(config.colors.background)
                            .cornerRadius(config.height/2)
                    }
                    
                    Text(details.title)
                        .font(config.fonts.title)
                }
                .frame(height: config.height)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                details.subtitle.map {
                    
                    Text($0)
                        .font(config.fonts.subtitle)
                        .foregroundColor(config.colors.subtitle)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, config.paddings.subtitleLeading)
                }
            }
        }
        .buttonStyle(PushButtonStyle())
        .foregroundColor(config.colors.title)
        .frame(maxWidth: .infinity)
    }
}
