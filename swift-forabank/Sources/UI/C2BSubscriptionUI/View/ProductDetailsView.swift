//
//  ProductDetailsView.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import SwiftUI

#warning("FIX THIS")
struct ProductDetailsView: View {
    
    typealias ProductDetails = GetC2BSubResponse.Details.ProductSubscription.ProductDetails
    
    let product: ProductDetails
    
    var body: some View {
        
        HStack {
            
            productIcon()
            
            VStack(alignment: .leading) {
                
                productTitle()
                productView()
                productNumber()
            }
        }
    }
    
    private func productIcon() -> some View {
        
        Image(systemName: "creditcard")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
    }
    
    private func productTitle() -> some View {
        
        Text(product.productTitle)
            .foregroundColor(.secondary)
            .font(.footnote)
    }
    
    private func productView() -> some View {
        
        HStack {
            
            productName()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            productBalance()
        }
    }
    
    private func productName() -> some View {
        
        Text("Текущий счет")
    }
    
    private func productBalance() -> some View {
        
        Text("654 367 ₽")
    }
    
    private func productNumber() -> some View {
        
        Text("3387")
            .foregroundColor(.secondary)
            .font(.footnote)
    }
}

struct ProductDetailsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ProductDetailsView(product: .preview)
    }
}
