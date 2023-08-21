//
//  ProductListView.swift
//  
//
//  Created by Дмитрий Савушкин on 20.07.2023.
//

import SwiftUI

struct ProductListView<P: Product, ProductView: View>: View {
    
    let products: [P]
    let productView: (P) -> ProductView
    
    let backgroundColor: Color
    
    var body: some View {
    
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 32) {
                
                ForEach(products) { product in
                    
                    SubscriptionRow(product: product, productView: productView)
                        .background(backgroundColor)
                        .cornerRadius(12)
                }
            }
        }
    }
}
