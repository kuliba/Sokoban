//
//  ProductFrontViewComponent.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 03.05.2023.
//

import Foundation
import SwiftUI
import Combine

//MARK: - View

struct ProductFrontView<Header: View, Footer: View>: View {
    
    @Binding var name: String
    
    let config: ProductView.Config
    let headerView: () -> Header
    let footerView: () -> Footer
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            headerView()
                .padding(.leading, config.cardViewConfig.headerLeadingPadding)
                .padding(.top, config.cardViewConfig.headerTopPadding)
            
            VStack(alignment: .leading, spacing: config.cardViewConfig.nameSpacing) {
                
                Text(name)
                    .font(config.fontConfig.nameFontForCard)
                    .foregroundColor(config.appearance.textColor)
                    .opacity(0.5)
                    .accessibilityIdentifier("productName")
                
                footerView()
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

