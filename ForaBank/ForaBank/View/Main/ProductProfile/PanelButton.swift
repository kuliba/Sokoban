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
        case accountOurBank
        case accountAnotherBank
        case cardGuardian
        case changePin
        case visibility
    }
}

extension PanelButton.Details {
    
    func event() -> Event {
    
        switch kind {
        case .accountDetails:
            return .init(productID: ID, type: .accountDetails)
        case .accountStatement:
            return .init(productID: ID, type: .accountStatement)
        case .accountOurBank:
            return .init(productID: ID, type: .accountOurBank)
        case .accountAnotherBank:
            return .init(productID: ID, type: .accountAnotherBank)
        case .cardGuardian:
            return .init(productID: ID, type: .cardGuardian)
        case .changePin:
            return .init(productID: ID, type: .changePin)
        case .visibility:
            return .init(productID: ID, type: .visibility)
        }
    }
}

extension PanelButton.Details {
    
    typealias Event = ProductNavigationStateManager.ButtonEvent
}
