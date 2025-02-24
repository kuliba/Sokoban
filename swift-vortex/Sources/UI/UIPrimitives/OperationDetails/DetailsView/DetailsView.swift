//
//  DetailsView.swift
//  Vortex
//
//  Created by Igor Malyarov on 18.02.2025.
//

import SwiftUI

public struct DetailsView<DetailsCellView: View>: View {
    
    private let detailsCells: [DetailsCell]
    private let config: DetailsViewConfig
    private let detailsCellView: (DetailsCell) -> DetailsCellView
    
    public init(
        detailsCells: [DetailsCell],
        config: DetailsViewConfig,
        detailsCellView: @escaping (DetailsCell) -> DetailsCellView
    ) {
        self.detailsCells = detailsCells
        self.config = config
        self.detailsCellView = detailsCellView
    }
    
    public var body: some View {
        
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
        
        DetailsView(detailsCells: .preview, config: .preview) {
            
            DetailsCellView(cell: $0, config: .preview)
        }
    }
}

extension [DetailsCell] {
    
    static let preview: Self = [
        .fieldPreview,
        .field(.init(
            image: .init(systemName: "calendar"),
            title: "Дата и время операции (МСК)",
            value: "06.05.2021 15:38:12")
        ),
        .field(.init(
            image: nil,
            title: "Назначение платежа",
            value: "Транспортный налог")
        ),
        .productPreview
    ]
}
