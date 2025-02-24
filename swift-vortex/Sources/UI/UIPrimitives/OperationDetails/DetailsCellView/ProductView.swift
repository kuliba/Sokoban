//
//  ProductView.swift
//
//
//  Created by Igor Malyarov on 20.02.2025.
//

import SwiftUI

struct ProductView: View {
    
    let product: DetailsCell.Product
    let config: DetailCellViewConfig.ProductConfig
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            product.title.text(withConfig: config.title)
            // TODO: extract as computed property
                .padding(.leading, config.iconSize.width + config.hSpacing)
            
            HStack(spacing: config.hSpacing) {
                
                productIconView(product)
                    .frame(config.iconSize)
                
                product.name.text(withConfig: config.name)
                
                Spacer()
                
                product.formattedBalance.text(withConfig: config.balance)
                    .padding(.trailing, config.balanceTrailingPadding)
            }
            
            product.description.text(withConfig: config.description)
                .padding(.leading, config.iconSize.width + config.hSpacing)
        }
        .padding(.vertical, config.vStackVPadding)
    }
    
    func productIconView(
        _ product: DetailsCell.Product
    ) -> some View {
        
        ZStack {
            
            Color.clear
            
            product.icon.map { image in
                
                image
                    .resizable()
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}

// MARK: - Previews

#Preview {
    
    ProductView(product: .preview, config: .preview)
}

extension DetailsCell.Product {
    
    static let preview: Self = .init(
        title: "Product Title",
        icon: .init(systemName: "creditcard"),
        name: "product name",
        formattedBalance: "$ 1 000.00",
        description: "- 3456"
    )
}
