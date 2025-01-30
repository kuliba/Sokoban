//
//  OrderCardVerticalListView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 04.12.2024.
//

import SwiftUI

struct OrderCardVerticalList: View {
    
    let model: OrderCardVerticalListViewModel
    
    var body: some View {
        
        VStack(spacing: 13) {
            
            Text(model.title)
                .font(.textH3Sb18240())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 13) {
                
                ForEach(model.items) { item in
                    
                    HStack(spacing: 16) {
                        
                        VStack {
                            
                            imageView(item.image)
                                .frame(width: 56, height: 56, alignment: .center)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 7) {
                            
                            Text(item.title)
                                .font(.textH4M16240())
                                .foregroundStyle(.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(item.subtitle)
                                .font(.textBodyMR14180())
                                .foregroundStyle(.textPlaceholder)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .padding(.trailing, 16)
        }
        .padding(.leading, 16)
        .padding(.vertical, 12)
        .padding(.trailing, 8)
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
        )
    )
}
