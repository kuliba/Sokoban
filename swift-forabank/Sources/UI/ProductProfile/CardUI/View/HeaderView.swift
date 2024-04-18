//
//  HeaderView.swift
//  
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import SwiftUI

public struct HeaderDetails {
    
    let number: String?
    let period: String?
    let icon: Image?
    
    public init(
        number: String?,
        period: String? = nil,
        icon: Image? = nil
    ) {
        self.number = number
        self.period = period
        self.icon = icon
    }
}

public struct HeaderView: View {
    
    let config: Config
    let header: HeaderDetails
    
    public init(
        config: Config,
        header: HeaderDetails
    ) {
        self.config = config
        self.header = header
    }
    
    public var body: some View {
        
        HStack(alignment: .center, spacing: 8) {
            
            header.number.map {
                
                Text($0)
                    .font(config.fonts.header)
                    .foregroundColor(config.appearance.textColor)
                    .accessibilityIdentifier("productNumber")
            }
            
            period()
            
            header.icon.map{
                $0
                    .renderingMode(.original)
                    .frame(height: 16, alignment: .center)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    private func period() -> some View {
        
        header.period.map { text in
           
            HStack {
                
                Rectangle()
                    .frame(width: 1, height: 16)
                    .foregroundColor(config.appearance.textColor)
                
                Text(text)
                    .font(config.fonts.header)
                    .foregroundColor(config.appearance.textColor)
                    .accessibilityIdentifier("productPeriod")
            }
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            HeaderView.init(config: .config(.previewCard), header: .init(number: "111111", icon: Image(systemName: "snowflake.circle")))
                .border(.red)
            
            HeaderView.init(config: .config(.previewAccount), header: .init(number: "111111", icon: Image(systemName: "snowflake.circle.fill")))
            
            HeaderView.init(config: .config(.previewLoan), header: .init(number: nil, period: "01/02"))
            
            HeaderView.init(config: .config(.previewDeposit), header: .init(number: "45454", period: "01/02"))
        }
    }
}
