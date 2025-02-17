//
//  OrderCardHorizontalListView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 04.12.2024.
//

import SwiftUI
import SharedConfigs

struct OrderCardHorizontalList: View {
    
    typealias Config = OrderCardHorizontalConfig
    typealias Model = OrderCardHorizontalListViewModel
    
    let model: Model
    let config: Config
    
    var body: some View {
        
        VStack {
            
            model.title.text(withConfig: config.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            
            HStack {
                
                ForEach(model.items) { item in
                    
                    itemView(item, config: config.itemConfig)
                        .frame(width: 80, height: 80, alignment: .center)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
    }
}

extension OrderCardHorizontalList {
    
    @ViewBuilder
    fileprivate func itemView(
        _ item: OrderCardHorizontalListViewModel.Item,
        config: TextConfig
    ) -> some View {
        
        VStack(spacing: 8) {
            
            imageView(item.image)
                .frame(width: 56, height: 56, alignment: .center)
            
            item.title.text(withConfig: config)
        }
    }
}

extension OrderCardHorizontalList {
    
    @ViewBuilder
    func imageView(
        _ image: Image?
    ) -> some View {
        
        if let image {
            
            image
            
        } else {
            
            Circle()
                .foregroundStyle(.gray)
        }
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

#Preview {
    
    OrderCardHorizontalList(
        model: .init(
            title: "Скидки и переводы",
            items: [
                .init(title: "СПБ", image: nil),
                .init(title: "За рубеж", image: nil),
                .init(title: "ЖКХ", image: nil),
                .init(title: "Налоги", image: nil)
            ]
        ),
        config: .init(
            title: .init(textFont: .body, textColor: .black),
            itemConfig: .init(textFont: .body, textColor: .black)
        )
    )
}
