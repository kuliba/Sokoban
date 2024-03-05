//
//  ProductView.swift
//
//
//  Created by Disman Dmitry on 20.02.2024.
//

import SwiftUI

struct ProductView: View {
    
    let product: Product
    
    var body: some View {
        
        product.color
            .cornerRadius(10)
            .frame(width: 121, height: 70)
        
        Text("\(product.id.value.rawValue)")
    }
}
