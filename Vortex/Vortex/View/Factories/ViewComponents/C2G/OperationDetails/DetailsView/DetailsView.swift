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

// MARK: - Previews

struct DetailsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        DetailsView(detailsCells: .preview, config: .iVortex) {
            
            DetailsCellView(cell: $0, config: .iVortex)
        }
    }
}

extension [DetailsCell] {
    
    static let preview: Self = [
        .field(.init(
            image: .ic24Calendar,
            title: "Дата и время операции (МСК)",
            value: "06.05.2021 15:38:12")
        ),
        .field(.init(
            image: nil,
            title: "Назначение платежа",
            value: "Транспортный налог")
        ),
        .product(.init(title: "Product"))
    ]
}
