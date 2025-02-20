//
//  DetailsCellView.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.02.2025.
//

import SwiftUI

struct DetailsCellView: View {
    
    let cell: DetailsCell
    let config: DetailCellViewConfig
    
    var body: some View {
        
        switch cell {
        case let .field(field):     fieldView(field)
        case let .product(product): productView(product)
        }
    }
}

private extension DetailsCellView {
    
    func fieldView(
        _ field: DetailsCell.Field
    ) -> some View {
        
        HStack(alignment: .top, spacing: config.hSpacing) {
            
            imageView(field)
                .frame(config.imageSize)
                .padding(.top, config.imageTopPadding)
            
            VStack(alignment: .leading, spacing: config.vSpacing) {
                
                field.title.text(withConfig: config.title)
                field.value.text(withConfig: config.value)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(config.insets)
    }
    
    func imageView(
        _ field: DetailsCell.Field
    ) -> some View {
        
        ZStack {
            
            Color.clear
            
            field.image.map {
                
                $0.renderingMode(.original)
            }
        }
    }
    
    func productView(
        _ product: DetailsCell.Product
    ) -> some View {
        
        Text("TBD: productView")
    }
}
