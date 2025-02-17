//
//  DropDownListView.swift
//
//
//  Created by Дмитрий Савушкин on 17.02.2025.
//

import SwiftUI
import SharedConfigs

struct DropDownList: View {
    
    typealias Model = DropDownListViewModel
    typealias Config = DropDownListConfig
    
    let viewModel: Model
    let config: Config
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            viewModel.title.text(withConfig: config.title)
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
            
            ForEach(viewModel.items, id: \.self) { item in
                
                itemView(item, config: config.itemTitle)
            }
        }
        .padding(.horizontal, 15)
        .background(config.backgroundColor)
        .cornerRadius(12)
    }
    
    fileprivate func itemView(
        _ item: DropDownListViewModel.Item,
        config: TextConfig
    ) -> some View {
        
        DisclosureGroup() {
            
            Text(item.description)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
        } label: {
            
            item.title.text(withConfig: config)
                .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
        }
        .accentColor(.gray)
    }
}

struct DropDownListViewModel {
    
    let title: String
    let items: [Item]
    
    struct Item: Hashable {
        
        var id: String {
            self.title
        }
        
        let title: String
        let description: String
    }
}

#Preview {
    DropDownList(
        viewModel: .init(
            title: "Часто задаваемые вопросы",
            items: [
                .init(
                    title: "Как повторно подключить подписку?",
                    description: "тест"
                ),
                .init(
                    title: "Как начисляются проценты?",
                    description: "тесттесттесттесттесттесттесттест"
                ),
                .init(
                    title: "Какие условия бесплатного обслуживания?",
                    description: ""
                )
            ]),
        config: .init(
            title: .init(
                textFont: .body,
                textColor: .blue
            ),
            itemTitle: .init(
                textFont: .body,
                textColor: .yellow
            ),
            backgroundColor: .black
        )
    )
}
