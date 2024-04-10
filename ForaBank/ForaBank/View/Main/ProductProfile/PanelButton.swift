//
//  PanelButton.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 09.04.2024.
//

import SwiftUI

struct PanelButton: View {
    
    let details: Details
    let event: () -> Void
    let config: PanelView.Config
    
    var body: some View {

        Button(action: event) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                HStack(spacing: config.spacings.hstack) {
                    
                    details.icon
                        .frame(width: config.height, height: config.height)
                        .background(config.colors.background)
                        .cornerRadius(config.height/2)
                    
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

extension PanelButton {
    
    struct Details {
        
        let ID: ProductData.ID
        let title: String
        let icon: Image?
        let subtitle: String?
        let kind: Kind
    }
}

extension PanelButton {
    
    enum Kind {
        
        case accountDetails
        case accountStatement
    }
}

extension PanelButton.Details {
    
    func event() -> Event {
    
        switch kind {
        case .accountDetails:
            return .accountDetails(ID)
        case .accountStatement:
            return .accountStatement(ID)
        }
    }
}

extension PanelButton.Details {
    
    typealias Event = ProductNavigationStateManager.ButtonEvent
}
