//
//  BackView.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import SwiftUI
import Foundation

//MARK: - View

struct BackView<Header: View, CVV: View>: View {
    
    let modifierConfig: ModifierConfig
    let config: Config
    
    let header: () -> Header
    let cvv: () -> CVV
    
    init(
        modifierConfig: ModifierConfig,
        config: Config,
        header: @escaping () -> Header,
        cvv: @escaping () -> CVV
    ) {
        self.modifierConfig = modifierConfig
        self.config = config
        self.header = header
        self.cvv = cvv
    }
    
    var body: some View {
        
        VStack {
            
            header()
                .padding(.leading, config.back.headerLeadingPadding)
                .padding(.top, config.back.headerLeadingPadding)
                .padding(.trailing, config.back.headerTrailingPadding)
            
            cvv()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .card(
            isChecked: modifierConfig.isChecked,
            isUpdating: modifierConfig.isUpdating,
            statusActionView: EmptyView(),
            config: config,
            isFrontView: false,
            action: modifierConfig.action
        )
        .animation(
            isShowingCardBack: modifierConfig.isShowingCardBack,
            cardWiggle: modifierConfig.cardWiggle,
            opacity: .init(startValue: modifierConfig.opacity, endValue: 0),
            radians: .init(startValue: 0, endValue: .pi)
        )
    }
}

struct BackView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        BackView(
            modifierConfig: .previewBack,
            config: .config(.previewCard),
            header: {
                HeaderBackView(
                    cardInfo: .previewWiggleFalse,
                    action: { print("action") },
                    config: .config(.previewCard))
            },
            cvv: {
                CVVView(
                    cardInfo: .previewWiggleFalse,
                    config: .config(.previewCard),
                    action: { print("cvv action") })
            })
        .fixedSize()
    }
}
