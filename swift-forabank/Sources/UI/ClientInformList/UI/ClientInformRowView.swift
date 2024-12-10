//
//  ClientInformRowView.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 07.10.2024.
//

import SwiftUI

struct ClientInformRowView: View {
    
    let logo: Image?
    let text: String
    let url: URL?
    let config: ClientInformListConfig
    
    init(
        logo: Image? = nil,
        text: String,
        url: URL?,
        config: ClientInformListConfig
    ) {
        self.logo = logo
        self.text = text
        self.url = url
        self.config = config
    }
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 20) {
            
            if let logo {
                logo
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: config.sizes.rowIconSize, height: config.sizes.rowIconSize)
            }
            
            let linkableText = url != nil ?
            "\(text) \(url!)" : text
            
            Text(.init(linkableText))
                .font(config.textConfig.textFont)
                .foregroundColor(config.titleConfig.textColor)
                .padding(.horizontal, config.paddings.horizontal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
