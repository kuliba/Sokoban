//
//  ProductView.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import SwiftUI

struct ProductView: View {
    
    let product: Product
    let config: ProductConfig
    
    var body: some View {
        
        HStack {
            
            productIcon()
            
            VStack(alignment: .leading) {
                
                product.title.text(withConfig: config.title)
                productView()
                product.number.text(withConfig: config.number)
            }
        }
    }
    
    private func productIcon() -> some View {
        
        product.icon.image(withFallback: .init(systemName: "creditcard"))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
    }
    
    private func productView() -> some View {
        
        HStack {
            
            product.name.text(withConfig: config.name)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            product.balance.text(withConfig: config.balance)
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ProductView(product: .preview, config: .preview)
    }
}
