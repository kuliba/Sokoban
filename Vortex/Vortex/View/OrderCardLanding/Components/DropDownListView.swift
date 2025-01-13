//
//  DropDownListView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 04.12.2024.
//

import SwiftUI

struct DropDownList: View {
    
    let viewModel: DropDownListViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            Text(viewModel.title)
                .foregroundStyle(.textSecondary)
                .font(.textH3Sb18240())
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
            
            ForEach(viewModel.items, id: \.self) { item in
                
                DisclosureGroup() {
                    
                    Text(item.description)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                } label: {
                    
                    Text(item.title)
                        .foregroundStyle(Color.mainColorsBlack)
                        .font(.textBodyMR14200())
                        .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                }
                .accentColor(.mainColorsGray)
            }
        }
        .padding(.horizontal, 15)
        .background(.mainColorsGrayLightest)
        .cornerRadius(12)
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
            ])
    )
}
