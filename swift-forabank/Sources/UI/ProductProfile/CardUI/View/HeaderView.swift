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
    
    public init(number: String?, period: String? = nil) {
        self.number = number
        self.period = period
    }
}

public struct HeaderView: View {
    
    let config: Config
    let header: HeaderDetails
    
    public init(config: Config, header: HeaderDetails) {
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
}

struct HeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            HeaderView.init(config: .config(.preview), header: .init(number: "111111"))
            
            HeaderView.init(config: .config(.preview), header: .init(number: nil, period: "01/02"))
            
            HeaderView.init(config: .config(.preview), header: .init(number: "45454", period: "01/02"))
        }
    }
}
