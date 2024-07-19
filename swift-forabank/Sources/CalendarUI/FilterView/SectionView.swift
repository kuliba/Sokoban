//
//  SectionView.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import SwiftUI

struct SectionView: View {
    
    let title: String
    let items: [Item]
    let tapAction: (Item) -> Void
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ContentView(items: items, tapAction: tapAction)
        }
    }
    
    struct Item: Identifiable, Hashable {
        
        var id: String { title }
        let title: String
        let isSelected: Bool
    }
    
    struct ContentView: View {
        
        private let size: CGFloat = 150
        private let padding: CGFloat = 8
        @State var items: [Item]
        let tapAction: (Item) -> Void
        
        var body: some View {
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100, maximum: 260))
            ]) {
                ForEach(items, id: \.self) { item in
                    
                    FilterOptionButtonView(
                        title: item.title,
                        isSelected: item.isSelected,
                        tappedAction: { tapAction(item) }
                    )
                }
            }
        }
    }
}

#Preview {
    
    VStack(spacing: 24) {
      
        SectionView(
            title: "Движение средств",
            items: [
                .init(title: "Списание", isSelected: true),
                .init(title: "Пополнение", isSelected: false)
            ]
        ) { item in
            
            print(item)
        }
        
        SectionView(
            title: "Категории",
            items: [
                .init(title: "В другой банк", isSelected: false),
                .init(title: "Между своими", isSelected: false),
                .init(title: "ЖКХ", isSelected: false),
                .init(title: "Входящие СБП", isSelected: false),
                .init(title: "Выплата процентов", isSelected: false),
                .init(title: "Гос. услуги", isSelected: false),
                .init(title: "Дом, ремонт", isSelected: false),
                .init(title: "Ж/д билеты", isSelected: false),
                .init(title: "Закрытие вклада", isSelected: false),
                .init(title: "Закрытие счета", isSelected: false),
                .init(title: "Интернет, ТВ", isSelected: false),
                .init(title: "Заработная плата", isSelected: false),
                .init(title: "Потребительские кредиты", isSelected: false)
            ]
        ) { item in
            
            print(item)
        }
    }
}
