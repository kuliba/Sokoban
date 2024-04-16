//
//  CardModifier.swift
//
//
//  Created by Andryusina Nataly on 19.03.2024.
//

import SwiftUI

struct CardModifier<StatusAction: View>: ViewModifier {

    let isChecked: Bool
    let isUpdating: Bool
    let isFrontView: Bool
    let config: CardUI.Config
    let statusAction: () -> StatusAction?
    
    @ViewBuilder
    private func checkView() -> some View {
        
        if isChecked {
            CheckView(config: config)
        }
    }
    
    @ViewBuilder
    private func statusActionView() -> some View {
        
        if let statusAction = statusAction() {
            
            statusAction
        }
    }
    
    @ViewBuilder
    private func updatingView() -> some View {
        
        if isUpdating {
            
            ZStack {
                
                DotsAnimations()
                .zIndex(3)
                
                AnimatedGradientView(duration: 3.0)
                    .blendMode(.colorDodge)
                    .clipShape(RoundedRectangle(cornerRadius: config.front.cornerRadius))
                    .zIndex(4)
            }
        }
    }
    
    @ViewBuilder
    private func background() -> some View {
        
        if isFrontView, let backgroundImage = config.appearance.background.image {
            
            backgroundImage
                .resizable()
                .aspectRatio(contentMode: .fit)
            
        } else {
            
            config.appearance.background.color
        }
    }
    
    func body(content: Content) -> some View {
        
        content
            .padding(config.front.cardPadding)
            .background(background())
            .overlay(checkView(), alignment: .topTrailing)
            .overlay(statusActionView(), alignment: .center)
            .overlay(updatingView(), alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: config.front.cornerRadius, style: .circular))
    }
}
