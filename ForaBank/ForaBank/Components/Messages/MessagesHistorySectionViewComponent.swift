//
//  MessagesHistorySectionComponentView.swift
//  ForaBank
//
//  Created by Константин Савялов on 20.04.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension MessagesHistorySectionView {
    
    class ViewModel: Identifiable {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        let id = UUID()
        let title: String
        var items: [MessagesHistoryItemView.ViewModel]
        
        internal init(title: String, items: [MessagesHistoryItemView.ViewModel]) {
            self.title = title
            self.items = items
        }
        
        init(title: String, items: [NotificationData]) {
            self.title = title
            self.items = items.map { MessagesHistoryItemView.ViewModel(notification: $0)}
        }
    }
}

//MARK: - View

struct MessagesHistorySectionView: View {
    
    let id = UUID()
    let viewModel: MessagesHistorySectionView.ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4)  {
            
            Text(viewModel.title)
                .font(.textBodyMSB14200())
                .foregroundColor(.textSecondary)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .padding(.leading, 5)
            
            ForEach(viewModel.items) { item in
                MessagesHistoryItemView.init(viewModel: item)
                    .onTapGesture {
                        viewModel.action.send(MessagesHistorySectionViewAction.ItemTapped(itemId: item.id))
                    }
            }
        }
    }
}
                                              

enum MessagesHistorySectionViewAction {

   struct ItemTapped: Action {

     let itemId: NotificationData.ID
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
        title: "25 агуста, ср",
        items: [MessagesHistoryItemView.ViewModel(icon: Image.ic24Slash, title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56"),
                MessagesHistoryItemView.ViewModel(icon: Image.ic24Slash, title: "Отказ. Недостаточно средств.", content: "LIQPAY*IP Artur Danilo, Moscow Интернет-оплата. Карта / счет .4387 16:59", time: "17:56")
               ])
}
