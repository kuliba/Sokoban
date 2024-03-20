//
//  FrontView.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import Foundation
import SwiftUI

//MARK: - View

public struct FrontView<Header: View, Footer: View>: View {
    
    let name: String
    let balance: Balance
    
    let config: Config
    let headerView: () -> Header
    let footerView: (Balance) -> Footer
    
    public init(
        name: String,
        balance: Balance,
        config: Config,
        headerView: @escaping () -> Header,
        footerView: @escaping (Balance) -> Footer
    ) {
        self.name = name
        self.balance = balance
        self.config = config
        self.headerView = headerView
        self.footerView = footerView
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
    }
}

struct FrontView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            FrontView(
                name: "Name",
                balance: .init("123 RUB"),
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
                })
            .fixedSize()
            
            FrontView(
                name: "Name",
                balance: .init("123012 RUB"),
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
                })
            .fixedSize()
        }
    }
}
