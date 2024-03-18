//
//  ProductFrontViewComponent.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 03.05.2023.
//

import Foundation
import SwiftUI
import Combine
import Tagged
import CardUI

//MARK: - View

struct ProductFrontView<Header: View, Footer: View>: View {
    
    public typealias Balance = Tagged<_Balance, String>

    public enum _Balance {}
    
    @Binding var name: String
    @Binding var balance: Balance
    
    let config: CardUI.Config
    let headerView: () -> Header
    let footerView: (Balance) -> Footer
    
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
                
                footerView(balance)
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

