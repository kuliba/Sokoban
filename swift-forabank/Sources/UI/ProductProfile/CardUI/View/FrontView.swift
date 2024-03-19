//
//  FrontView.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import Foundation
import SwiftUI

//MARK: - View

public struct FrontView<Header: View, Footer: View, StatusAction: View>: View {
    
    let name: String
    let balance: Balance
    let isChecked: Bool
    let isUpdating: Bool

    let opacity: Double
    let isShowingCardBack: Bool
    let cardWiggle: Bool
    
    let config: Config
    let headerView: () -> Header
    let footerView: (Balance) -> Footer
    
    let statusActionView: () -> StatusAction?
    
    let action: () -> Void

    public init(
        name: String,
        balance: Balance,
        isChecked: Bool,
        isUpdating: Bool,
        opacity: Double,
        isShowingCardBack: Bool,
        cardWiggle: Bool,
        config: Config,
        headerView: @escaping () -> Header,
        footerView: @escaping (Balance) -> Footer,
        statusActionView: @escaping () -> StatusAction?,
        action: @escaping () -> Void
    ) {
        self.name = name
        self.balance = balance
        self.isChecked = isChecked
        self.isUpdating = isUpdating
        self.opacity = opacity
        self.isShowingCardBack = isShowingCardBack
        self.cardWiggle = cardWiggle
        self.config = config
        self.headerView = headerView
        self.footerView = footerView
        self.statusActionView = statusActionView
        self.action = action
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            headerView()
                .padding(.leading, config.front.headerLeadingPadding)
                .padding(.top, config.front.headerTopPadding)
            
            VStack(alignment: .leading, spacing: config.front.nameSpacing) {
                
                Text(name)
                    .font(config.fonts.card)
                    .foregroundColor(config.appearance.textColor)
                    .opacity(0.5)
                    .accessibilityIdentifier("productName")
                
                footerView(balance)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .card(
            isChecked: isChecked,
            isUpdating: isUpdating,
            statusActionView: statusActionView(),
            config: config,
            isFrontView: true,
            action: action
        )
        .animation(
            isShowingCardBack: isShowingCardBack,
            cardWiggle: cardWiggle,
            opacity: .init(
                startValue: 0,
                endValue: opacity),
            radians: .init(startValue: .pi, endValue: 2 * .pi)
        )
    }
}

/*struct FrontView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            FrontView(
                name: "Name",
                balance: .init("123 RUB"),
               /* opacity: 1,
                isShowingCardBack: false,
                cardWiggle: false,*/
                config: .config(.preview),
                headerView: {
                    HeaderBackView(
                        cardInfo: .previewWiggleFalse,
                        action: { print("action") },
                        config: .config(.preview))
                },
                footerView: {
                    FooterView(
                        config: .config(.preview),
                        footer: .init(balance: $0.rawValue))
                }, 
                statusActionView: {
                    EmptyView()
                })
            .fixedSize()
            
            FrontView(
                name: "Name",
                balance: .init("123012 RUB"),
               /* opacity: 0.5,
                isShowingCardBack: false,
                cardWiggle: false,*/
                config: .config(.preview),
                headerView: {
                    HeaderBackView(
                        cardInfo: .previewWiggleFalse,
                        action: { print("action") },
                        config: .config(.preview))
                },
                footerView: {
                    FooterView(
                        config: .config(.preview),
                        footer: .init(balance: $0.rawValue, interestRate: "8.05"))
                },
                statusActionView: {
                    EmptyView()
                })
            .fixedSize()
        }
    }
}
*/
