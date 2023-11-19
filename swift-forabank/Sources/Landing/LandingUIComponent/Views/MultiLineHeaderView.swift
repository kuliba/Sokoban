//
//  MultiLineHeaderView.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

typealias ComponentMLH = UILanding.Multi.LineHeader
typealias ConfigMLH = UILanding.Multi.LineHeader.Config

struct MultiLineHeaderView: View {
    
    let model: ComponentMLH
    let config: ConfigMLH
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            if let regularTextList = model.regularTextList {
                
                ForEach(regularTextList) {
                    
                    ItemView(
                        font: config.item.fontRegular,
                        text: $0,
                        textColor: config.textColor(model.backgroundColor)
                    )
                }
            }
            
            if let boldTextItems = model.boldTextList {
                
                ForEach(boldTextItems) {
                    
                    ItemView(
                        font: config.item.fontBold,
                        text: $0,
                        textColor: config.textColor(model.backgroundColor)
                    )
                }
            }
        }
        .padding(.horizontal, config.paddings.horizontal)
        .padding(.vertical, config.paddings.vertical)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(config.backgroundColor(model.backgroundColor))
        .accessibilityIdentifier("MultiLineHeaderBody")
    }
}

extension MultiLineHeaderView{
    
    struct ItemView: View {
        
        let font: Font
        let text: String
        let textColor: Color
        
        var body: some View {
            
            Text(text)
                .font(font)
                .foregroundColor(textColor)
                .accessibilityIdentifier("MultiLineHeaderText")
        }
    }
}

// MARK: - Preview

struct MultiLineHeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            MultiLineHeaderView(
                model: .defaultViewModelBlack,
                config: .defaultValue
            )
            .previewDisplayName("Black")
            
            MultiLineHeaderView(
                model: .defaultViewModelGray,
                config: .defaultValue
            )
            .previewDisplayName("Gray")
            
            MultiLineHeaderView(
                model: .defaultViewModelWhite,
                config: .defaultValue
            )
            .previewDisplayName("White")
        }
    }
}
