//
//  MultiLineHeaderView.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

struct MultiLineHeaderView: View {
    
    let viewModel: MultiLineHeaderViewModel
    
    init(viewModel: MultiLineHeaderViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            if let regularTextItems = viewModel.regularTextItems {
                
                ForEach(regularTextItems, id: \.self) {
                    
                    ItemView(
                        font: .title,
                        text: $0.name,
                        textColor: viewModel.textColor
                    )
                }
            }
            
            if let boldTextItems = viewModel.boldTextItems {
                
                ForEach(boldTextItems, id: \.self) {
                    
                    ItemView(
                        font: .bold(.title)(),
                        text: $0.name,
                        textColor: viewModel.textColor
                    )
                }
            }
        }
        .padding(.horizontal)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(viewModel.backgroundColor.value)
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
                viewModel: .defaultViewModelBlack
            )
            .previewDisplayName("Black")

            MultiLineHeaderView(
                viewModel: .defaultViewModelGray
            )
            .previewDisplayName("Gray")
            
            MultiLineHeaderView(
                viewModel: .defaultViewModelWhite
            )
            .previewDisplayName("White")
        }
    }
}
