//
//  MessagesHistorySectionComponentView.swift
//  ForaBank
//
//  Created by Константин Савялов on 20.04.2022.
//

import SwiftUI

//MARK: - ViewModel

extension MessagesHistorySectionView: Identifiable {
    
    class ViewModel {
        
        let section: String
        let items: [MessagesHistoryItemView.ViewModel]
        
        internal init(section: String, items: [MessagesHistoryItemView.ViewModel]) {
            self.section = section
            self.items = items
        }
    }
}

//MARK: - View

struct MessagesHistorySectionView: View {
    
    let id = UUID()
    let viewModel: MessagesHistorySectionView.ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4)  {
            
            Text(viewModel.section)
                .font(.textBodyMSB14200())
                .foregroundColor(.textSecondary)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .padding(.leading, 5)
            
            ForEach(viewModel.items) { item in
                MessagesHistoryItemView.init(viewModel: item)
            }
        }
    }
}

//MARK: - Preview

struct MessagesHistorySectionView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MessagesHistorySectionView(viewModel:.sample)
            .previewLayout(.fixed(width: 375, height: 200))
    }
}

//MARK: - Preview Content

extension MessagesHistorySectionView.ViewModel {
    
    static let sample = MessagesHistorySectionView.ViewModel(
        section: "25 агуста, ср",
        items: [MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56", action: {}),
                MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Отказ. Недостаточно средств.", content: "LIQPAY*IP Artur Danilo, Moscow Интернет-оплата. Карта / счет .4387 16:59", time: "17:56", action: {})
               ])
}
