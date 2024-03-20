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
    let modifierConfig: ModifierConfig
    let config: Config
    let headerView: () -> Header
    let footerView: (Balance) -> Footer
    
    let statusActionView: () -> StatusAction?

    public init(
        name: String,
        balance: Balance,
        modifierConfig: ModifierConfig,
        config: Config,
        headerView: @escaping () -> Header,
        footerView: @escaping (Balance) -> Footer,
        statusActionView: @escaping () -> StatusAction?
    ) {
        self.name = name
        self.balance = balance
        self.modifierConfig = modifierConfig
        self.config = config
        self.headerView = headerView
        self.footerView = footerView
        self.statusActionView = statusActionView
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
            isChecked: modifierConfig.isChecked,
            isUpdating: modifierConfig.isUpdating,
            statusActionView: statusActionView(),
            config: config,
            isFrontView: true,
            action: modifierConfig.action
        )
        .animation(
            isShowingCardBack: modifierConfig.isShowingCardBack,
            cardWiggle: modifierConfig.cardWiggle,
            opacity: .init(
                startValue: 0,
                endValue: modifierConfig.opacity),
            radians: .init(startValue: .pi, endValue: 2 * .pi)
        )
    }
}

struct FrontView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            FrontView(
                name: "Name",
                balance: .init("123 RUB"),
                modifierConfig: .previewUpdating,
                config: .config(.preview),
                headerView: {
                    HeaderView(
                        config: .config(.preview),
                        header: .init(
                            number: "111111",
                            icon: Image(systemName: "snowflake.circle"))
                    )
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
                modifierConfig: .previewFront,
                config: .config(.preview),
                headerView: {
                    HeaderView(
                        config: .config(.preview),
                        header: .init(
                            number: "111111",
                            icon: Image(systemName: "snowflake.circle.fill"))
                    )
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

