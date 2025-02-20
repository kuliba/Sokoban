//
//  DetailsView.swift
//  Vortex
//
//  Created by Igor Malyarov on 18.02.2025.
//

import SwiftUI

struct DetailsView<DetailsCellView: View>: View {
    
    let detailsCells: [DetailsCell]
    let config: DetailsViewConfig
    let detailsCellView: (DetailsCell) -> DetailsCellView
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: config.spacing) {
                
                ForEach(detailsCells, id: \.title, content: detailsCellView)
            }
        }
        .padding(config.padding)
    }
}

private extension DetailsCell {
    
    var title: String {
        
        switch self {
        case let .field(field):     return field.title
        case let .product(product): return product.title
        }
    }
}
