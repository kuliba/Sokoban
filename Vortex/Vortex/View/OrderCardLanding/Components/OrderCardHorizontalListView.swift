//
//  OrderCardHorizontalListView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 04.12.2024.
//

import SwiftUI

struct OrderCardHorizontalList: View {
    
    let model: OrderCardHorizontalListViewModel
    
    var body: some View {
        
        VStack {
            
            Text(model.title)
                .font(.textH3Sb18240())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            
            HStack {
                
                ForEach(model.items) { item in
                    
                    VStack(spacing: 8) {
                        
                        imageView(item.image)
                            .frame(width: 56, height: 56, alignment: .center)
                        
                        Text(item.title)
                            .font(.textBodySR12160())
                            .foregroundStyle(.textSecondary)
                    }
                    .frame(width: 80, height: 80, alignment: .center)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
    }
}

struct OrderCardHorizontalListViewModel {
    
    let title: String
    let items: [Item]
    
    struct Item: Identifiable {
        
        var id: String {
            self.title
        }
        
        let title: String
        let image: Image?
    }
}

@ViewBuilder
func imageView(
    _ image: Image?
) -> some View {
    
    if let image {
        
        image
        
    } else {
        
        Circle()
            .foregroundStyle(.mainColorsGray)
            .shimmering()
    }
}

#Preview {
    
    OrderCardHorizontalList(model: .init(
        title: "Скидки и переводы",
        items: [
            .init(title: "СПБ", image: nil),
            .init(title: "За рубеж", image: nil),
            .init(title: "ЖКХ", image: nil),
            .init(title: "Налоги", image: nil)
        ]
    ))
}
