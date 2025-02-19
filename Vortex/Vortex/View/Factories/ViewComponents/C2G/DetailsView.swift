//
//  DetailsView.swift
//  Vortex
//
//  Created by Igor Malyarov on 18.02.2025.
//

import SharedConfigs
import SwiftUI

struct Details {}

extension Details {
    
    var transactionDetails: [DetailsCell] { [] }
    var paymentRequisites: [DetailsCell] { [] }
}

struct DetailsCell: Equatable {
    
    let image: Image?
    let title: String
    let value: String
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
        
        HStack(alignment: .top, spacing: config.hSpacing) {
            
            imageView()
                .frame(config.imageSize)
                .padding(.top, config.imageTopPadding)
            
            VStack(alignment: .leading, spacing: config.vSpacing) {
                
                cell.title.text(withConfig: config.title)
                cell.value.text(withConfig: config.value)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(config.insets)
    }
}

private extension DetailsCellView {
    
    func imageView() -> some View {
        
        ZStack {
            
            Color.clear
            
            cell.image.map {
                
                $0.renderingMode(.original)
            }
        }
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
