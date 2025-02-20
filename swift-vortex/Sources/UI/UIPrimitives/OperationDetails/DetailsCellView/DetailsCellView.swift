//
//  DetailsCellView.swift
//  Vortex
//
//  Created by Igor Malyarov on 20.02.2025.
//

import SwiftUI

public struct DetailsCellView: View {
    
    private let cell: DetailsCell
    private let config: DetailCellViewConfig
    
    public init(
        cell: DetailsCell,
        config: DetailCellViewConfig
    ) {
        self.cell = cell
        self.config = config
    }
    
    public var body: some View {
        
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
                .padding(config.imagePadding)
            
            VStack(alignment: .leading, spacing: config.vSpacing) {
                
                field.title.text(withConfig: config.title)
                field.value.text(withConfig: config.value)
            }
            .padding(.vertical, config.labelVPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func imageView(
        _ field: DetailsCell.Field
    ) -> some View {
        
        ZStack {
            
            Color.clear
            
            field.image.map { image in
                
                image
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(config.imageForegroundColor)
            }
        }
    }
    
    func productView(
        _ product: DetailsCell.Product
    ) -> some View {
        
        Text("TBD: productView")
    }
}

// MARK: - Previews

struct DetailsCellView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack(spacing: 16) {
            
            detailsCellView(.fieldPreview)
            detailsCellView(.productPreview)
        }
    }
    
    private static func detailsCellView(
        _ cell: DetailsCell
    ) -> some View {
        
        DetailsCellView(cell: cell, config: .preview)
    }
}

extension DetailsCell {
    
    static let fieldPreview: Self = .field(.init(
        image: .init(systemName: "scribble"),
        title: "Field Title",
        value: "Field Value"
    ))
    
    static let productPreview: Self = .product(.init(
        title: "Product Title"
    ))
}
