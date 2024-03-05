//
//  SelectorView.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import SwiftUI

struct SelectorView: View {
    
    typealias Selector = CarouselState.ProductTypeSelector
    
    let state: Selector
    let event: (Product.ID.ProductType) -> Void
    
    var body: some View {
        
        HStack {
            ForEach(state.items.uniqueValues, id: \.self, content: productTypeView)
        }
    }
    
    private func productTypeView(
        productType: Product.ID.ProductType
    ) -> some View {
        
        Text(productType.pluralName)
            .foregroundColor(productType == state.selected ? .orange : .gray)
            .onTapGesture { event(productType) }
    }
}
