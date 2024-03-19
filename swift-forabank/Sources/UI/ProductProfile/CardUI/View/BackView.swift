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
    
   /* let opacity: Double
    let isShowingCardBack: Bool*/
    let backConfig: Config.Back
    
    let header: () -> Header
    let cvv: () -> CVV
    
    public init(
       /* opacity: Double,
        isShowingCardBack: Bool,*/
        backConfig: Config.Back,
        header: @escaping () -> Header,
        cvv: @escaping () -> CVV
    ) {
        /*self.opacity = opacity
        self.isShowingCardBack = isShowingCardBack*/
        self.backConfig = backConfig
        self.header = header
        self.cvv = cvv
    }
    
    public var body: some View {
        
        VStack {
            
            header()
                .padding(.leading, backConfig.headerLeadingPadding)
                .padding(.top, backConfig.headerLeadingPadding)
                .padding(.trailing, backConfig.headerTrailingPadding)
            
            cvv()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
       /* .animation(
            isShowingCardBack: isShowingCardBack,
            cardWiggle: false,
            opacity: .init(startValue: opacity, endValue: 0),
            radians: .init(startValue: 0, endValue: .pi)
        )*/
    }
}

struct BackView_Previews: PreviewProvider {
    
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
}
