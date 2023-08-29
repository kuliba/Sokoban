//
//  MultiLineHeaderView.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

struct MultiLineHeaderView: View {
    
    let viewModel: MultiLineHeaderViewModel
    let config: Config
    
    init(
        viewModel: MultiLineHeaderViewModel,
        config: Config
    ) {
        
        self.viewModel = viewModel
        self.config = config
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            if let regularTextItems = viewModel.regularTextItems {
                
                ForEach(regularTextItems) {
                    
                    ItemView(
                        font: config.item.fontRegular,
                        text: $0.name,
                        textColor: config.item.color
                    )
                }
            }
            
            if let boldTextItems = viewModel.boldTextItems {
                
                ForEach(boldTextItems) {
                    
                    ItemView(
                        font: config.item.fontBold,
                        text: $0.name,
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
                viewModel: .defaultViewModelBlack,
                config: .defaultValueBlack
            )
            .previewDisplayName("Black")

            MultiLineHeaderView(
                viewModel: .defaultViewModelGray,
                config: .defaultValueGray
            )
            .previewDisplayName("Gray")
            
            MultiLineHeaderView(
                viewModel: .defaultViewModelWhite,
                config: .defaultValueWhite
            )
            .previewDisplayName("White")
        }
    }
}
