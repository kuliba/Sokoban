//
//  BackView.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import SwiftUI
import Foundation

//MARK: - View

public struct BackView<Header: View, CVV: View>: View {
    
    let isChecked: Bool
    let isUpdating: Bool

    let opacity: Double
    let isShowingCardBack: Bool

    let config: Config
    
    let header: () -> Header
    let cvv: () -> CVV
        
    let action: () -> Void
    
    public init(
        isChecked: Bool,
        isUpdating: Bool,
        opacity: Double,
        isShowingCardBack: Bool,
        config: Config,
        header: @escaping () -> Header,
        cvv: @escaping () -> CVV,
        action: @escaping () -> Void
    ) {
        self.isChecked = isChecked
        self.isUpdating = isUpdating
        self.opacity = opacity
        self.isShowingCardBack = isShowingCardBack
        self.config = config
        self.header = header
        self.cvv = cvv
        self.action = action
    }
    
    public var body: some View {
        
        VStack {
            
            header()
                .padding(.leading, config.back.headerLeadingPadding)
                .padding(.top, config.back.headerLeadingPadding)
                .padding(.trailing, config.back.headerTrailingPadding)
            
            cvv()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .card(
            isChecked: isChecked,
            isUpdating: isUpdating,
            statusActionView: EmptyView(),
            config: config,
            isFrontView: false,
            action: action
        )
        .animation(
            isShowingCardBack: isShowingCardBack,
            cardWiggle: false,
            opacity: .init(startValue: opacity, endValue: 0),
            radians: .init(startValue: 0, endValue: .pi)
        )
    }
}

/*struct BackView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ZStack {
            
            Color.red
            BackView(
               /* opacity: 1,
                isShowingCardBack: true,*/
                backConfig: .preview,
                header: {
                    HeaderBackView(
                        cardInfo: .previewWiggleFalse,
                        action: { print("action") },
                        config: .config(.preview))
                },
                cvv: {
                    CVVView(
                        cardInfo: .previewWiggleFalse,
                        config: .config(.preview),
                        action: { print("cvv action") })
                })
        }
        .fixedSize()
    }
}*/
