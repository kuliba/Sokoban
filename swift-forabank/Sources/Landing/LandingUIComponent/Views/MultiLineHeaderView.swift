//
//  MultiLineHeaderView.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

typealias ComponentMLH = Landing.MultiLineHeader
typealias ConfigMLH = Landing.MultiLineHeader.Config

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
                        textColor: config.item.color
                    )
                }
            }
            
            if let boldTextItems = model.boldTextList {
                
                ForEach(boldTextItems) {
                    
                    ItemView(
                        font: config.item.fontBold,
                        text: $0,
                        textColor: config.item.color
                    )
                }
            }
        }
        .padding(.horizontal)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(config.backgroundColor.value)
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
        }
    }
}

// MARK: - Preview

struct MultiLineHeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            MultiLineHeaderView(
                model: .defaultViewModel,
                config: .defaultValueBlack
            )
            .previewDisplayName("Black")
            
            MultiLineHeaderView(
                model: .defaultViewModel,
                config: .defaultValueGray
            )
            .previewDisplayName("Gray")
            
            MultiLineHeaderView(
                model: .defaultViewModel,
                config: .defaultValueWhite
            )
            .previewDisplayName("White")
        }
    }
}
