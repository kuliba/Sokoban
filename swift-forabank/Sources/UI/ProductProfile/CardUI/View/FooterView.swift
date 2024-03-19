//
//  FooterView.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import SwiftUI

public struct FooterDetails {
    
    public var balance: String
    public let interestRate: String?
    public let paymentSystem: Image?
    
    public init(
        balance: String,
        interestRate: String? = nil,
        paymentSystem: Image? = nil
    ) {
        
        self.balance = balance
        self.interestRate = interestRate
        self.paymentSystem = paymentSystem
    }
}

public struct FooterView: View {
    
    let config: Config
    let footer: FooterDetails
    
    public init(
        config: Config,
        footer: FooterDetails
    ) {
        self.config = config
        self.footer = footer
    }
    
    public var body: some View {
        
        if let paymentSystem = footer.paymentSystem {
            
            HStack {
                
                Text(footer.balance)
                    .font(config.fonts.footer)
                    .fontWeight(.semibold)
                    .foregroundColor(config.appearance.textColor)
                    .accessibilityIdentifier("productBalance")
                    .frame(maxWidth: .infinity, alignment: .leading)
                paymentSystem
                    .renderingMode(.template)
                    .resizable()
                    .frame(height: config.sizes.paymentSystemIcon.height)
                    .foregroundColor(config.appearance.textColor)
                    .accessibilityIdentifier("productPaymentSystemIcon")
                    .frame(maxWidth: config.sizes.paymentSystemIcon.width, alignment: .trailing)
            }
        } else {
            
            HStack {
                
                Text(footer.balance)
                    .font(config.fonts.footer)
                    .fontWeight(.semibold)
                    .foregroundColor(config.appearance.textColor)
                    .accessibilityIdentifier("productBalance")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                footer.interestRate.map { text in
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(config.colors.rateFill)
                            .frame(width: 56, height: 20)
                        Text(text)
                            .font(config.fonts.rate)
                            .fontWeight(.regular)
                            .foregroundColor(config.colors.rateForeground)
                    }
                }
            }
        }
    }
}

struct FooterView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            FooterView(
                config: .config(.preview),
                footer: .init(balance: "1235 RUB"))
            
            FooterView(
                config: .config(.preview),
                footer: .init(balance: "1235 RUB", interestRate: "Rate"))
            
            FooterView(
                config: .config(.preview),
                footer: .init(
                    balance: "1235 RUB",
                    paymentSystem: Image(systemName: "person.text.rectangle"))
            )
        }
    }
}
