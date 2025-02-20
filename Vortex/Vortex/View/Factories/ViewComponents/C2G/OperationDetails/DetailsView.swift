//
//  DetailsView.swift
//  Vortex
//
//  Created by Igor Malyarov on 18.02.2025.
//

import SharedConfigs
import SwiftUI

enum DetailsCell: Equatable {
    
    case field(Field)
    case product(Product)
 
    struct Field: Equatable {
        
        let image: Image?
        let title: String
        let value: String
    }
    
    struct Product: Equatable {
        
        let title: String
    }
}

struct DetailCellViewConfig: Equatable {
    
    let insets: EdgeInsets
    let imageSize: CGSize
    let imageTopPadding: CGFloat
    let hSpacing: CGFloat
    let vSpacing: CGFloat
    let title: TextConfig
    let value: TextConfig
}

struct DetailsCellView: View {
    
    let cell: DetailsCell
    let config: DetailCellViewConfig
    
    var body: some View {
        
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
                .padding(.top, config.imageTopPadding)
            
            VStack(alignment: .leading, spacing: config.vSpacing) {
                
                field.title.text(withConfig: config.title)
                field.value.text(withConfig: config.value)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(config.insets)
    }
    
    func imageView(
        _ field: DetailsCell.Field
    ) -> some View {
        
        ZStack {
            
            Color.clear
            
            field.image.map {
                
                $0.renderingMode(.original)
            }
        }
    }
    
    func productView(
        _ product: DetailsCell.Product
    ) -> some View {
        
        Text("TBD: productView")
    }
}

struct DetailsViewConfig: Equatable {
    
    let padding: CGFloat
    let spacing: CGFloat
}

struct DetailsView<DetailsCellView: View, Footer: View>: View {
    
    let detailsCells: [DetailsCell]
    let config: DetailsViewConfig
    let detailsCellView: (DetailsCell) -> DetailsCellView
    let footer: () -> Footer
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            // TODO: extract to config
            VStack(spacing: config.spacing) {
                
                ForEach(detailsCells, id: \.title, content: detailsCellView)
            }
        }
        .padding(config.padding)
        .safeAreaInset(edge: .bottom, content: footer)
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
