//
//  SectionView.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import SwiftUI

struct SectionView: View {
    
    typealias State = SectionState
    typealias Config = FilterOptionButtonView.Config
    typealias Event = SectionEvent
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            Text(config.title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            ContentView(
                items: state.items,
                event: event,
                config: config
            )
        }
    }
    
    struct ContentView: View {
        
        private let size: CGFloat = 150
        private let padding: CGFloat = 8
        let items: [SectionState.Item]
        let event: (Event) -> Void
        let config: FilterOptionButtonView.Config
        
        var body: some View {
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100, maximum: 260))
            ]) {
                
                ForEach(items, id: \.id) { item in
                    
                    FilterOptionButtonView(
                        state: .init(isSelected: item.isSelected),
                        event: { event in },
                        config: .init(
                            title: item.title,
                            titleConfig: config.titleConfig,
                            selectedConfig: config.selectedConfig
                        )
                    )
                }
            }
        }
    }
}

#Preview {
    
    VStack(spacing: 24) {
        
        SectionView(
            state: .init(items: [
                .init(title: "Списание", isSelected: true),
                .init(title: "Пополнение", isSelected: false)
            ]),
            event: { item in
                
                print(item)
            },
            config: .init(title: "Движение средств", titleConfig: .init(textFont: .body, textColor: .red), selectedConfig: .init(textFont: .body, textColor: .yellow))
        )
        
        SectionView(
            state: .init(items: [
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
            ]),
            event: { item in
                
                print(item)
            },
            config: .init(title: "Категории", titleConfig: .init(textFont: .body, textColor: .red), selectedConfig: .init(textFont: .body, textColor: .yellow))
        )
    }
}
