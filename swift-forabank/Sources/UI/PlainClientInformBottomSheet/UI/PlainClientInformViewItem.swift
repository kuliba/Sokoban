//
//  PlainClientInformViewItem.swift
//  ForaBank
//
//  Created by Nikolay Pochekuev on 07.10.2024.
//

import SwiftUI

@available(iOS 15, *)
struct PlainClientInformRowView: View {
    
    let logo: Image?
    let text: String
    let config: PlainClientInformBottomSheetConfig
    
    init(
        logo: Image? = nil,
        text: AttributedString,
        config: PlainClientInformBottomSheetConfig
    ) {
        self.logo = logo
        self.text = NSAttributedString(text).string
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
            
            Text(text)
                .font(config.textConfig.textFont)
                .foregroundColor(config.textConfig.textColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
