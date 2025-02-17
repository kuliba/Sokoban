//
//  OrderCardVerticalListView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 04.12.2024.
//

import SwiftUI
import SharedConfigs

struct OrderCardVerticalList: View {
    
    typealias Config = OrderCardVerticalListConfig
    typealias Model = OrderCardVerticalListViewModel
    
    let model: Model
    let config: Config
    
    var body: some View {
        
        VStack(spacing: 13) {
            
            Text(model.title)
                .font(config.title.textFont)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 13) {
                
                ForEach(model.items) { item in
                    
                    itemView(
                        item,
                        config: config
                    )
                }
            }
            .padding(.trailing, 16)
        }
        .padding(.leading, 16)
        .padding(.vertical, 12)
        .padding(.trailing, 8)
    }
}

extension OrderCardVerticalList {
    
    @ViewBuilder
    func itemView(
        _ item: OrderCardVerticalListViewModel.Item,
        config: Config
    ) -> some View {
        
        HStack(spacing: 16) {
            
            VStack {
                
                imageView(item.image)
                    .frame(width: 56, height: 56, alignment: .center)
                
                Spacer()
            }
            
            VStack(spacing: 7) {
                
                item.title.text(withConfig: config.itemTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                item.subtitle.text(withConfig: config.itemSubTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
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
                .foregroundStyle(.gray)
        }
    }
}

struct OrderCardVerticalListViewModel {
    
    let title: String
    let items: [Item]
    
    struct Item: Identifiable {
        
        var id: String {
            self.title
        }
        
        let title: String
        let subtitle: String
        let image: Image?
    }
}

#Preview {
    OrderCardVerticalList(
        model: .init(
            title: "Выгодные условия",
            items: [
                .init(
                    title: "0 ₽",
                    subtitle: "Условия обслуживания",
                    image: nil
                ),
                .init(
                    title: "До 35%",
                    subtitle: "Кешбэк и скидки",
                    image: nil
                ),
                .init(
                    title: "Кешбэк 5%",
                    subtitle: "На востребованные категории",
                    image: nil
                ),
                .init(
                    title: "Кешбэк 5%",
                    subtitle: "На топливо и 3% кешбэк на кофе",
                    image: nil
                ),
                .init(
                    title: "8% годовых",
                    subtitle: "При сумме остатка от 500 001 ₽ ",
                    image: nil
                )
            ]
        ),
        config: .init(
            title: .init(textFont: .body, textColor: .black),
            itemTitle: .init(textFont: .body, textColor: .black),
            itemSubTitle: .init(textFont: .body, textColor: .black)
        )
    )
}
