//
//  Front.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import Foundation
import SwiftUI

//MARK: - View

struct Front<Header: View, Footer: View, StatusAction: View>: View {
    
    let name: String
    let modifierConfig: ModifierConfig
    let config: Config
    let headerView: () -> Header
    let footerView: () -> Footer
    
    let statusActionView: () -> StatusAction?
    
    init(
        name: String,
        modifierConfig: ModifierConfig,
        config: Config,
        headerView: @escaping () -> Header,
        footerView: @escaping () -> Footer,
        statusActionView: @escaping () -> StatusAction?
    ) {
        self.name = name
        self.modifierConfig = modifierConfig
        self.config = config
        self.headerView = headerView
        self.footerView = footerView
        self.statusActionView = statusActionView
    }
    
    var body: some View {
        
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
                
                footerView()
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

struct Front_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            Front(
                name: "Name",
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
                        footer: .init(balance: "123 RUB"))
                },
                statusActionView: {
                    EmptyView()
                })
            .fixedSize()
            
            Front(
                name: "Name",
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
                        footer: .init(balance: "123012 RUB", interestRate: "8.05"))
                },
                statusActionView: {
                    EmptyView()
                })
            .fixedSize()
        }
    }
}

