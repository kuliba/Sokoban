//
//  MessagesHistoryItemComponentView.swift
//  ForaBank
//
//  Created by Константин Савялов on 20.04.2022.
//

import SwiftUI

//MARK: - ViewModel

extension MessagesHistoryItemView {
    
    class ViewModel: Identifiable, Equatable {
        
        let id: NotificationData.ID
        let icon: Image
        let title: String
        let content: String
        let time: String

        internal init(id: NotificationData.ID = 1, icon: Image, title: String, content: String, time: String) {
            
            self.id = id
            self.icon = icon
            self.title = title
            self.content = content
            self.time = time
        }
        
        internal init(notification: NotificationData) {
            
            self.id = notification.id
            self.icon = Image.ic24MoreHorizontal
            self.title = notification.title
            self.content = notification.text
            self.time = DateFormatter.minutsAndSecond.string(from: notification.dateUtc)
        }
        
        static func == (lhs: MessagesHistoryItemView.ViewModel, rhs: MessagesHistoryItemView.ViewModel) -> Bool {
            lhs.id == rhs.id
        }
    }
}

//MARK: - View

struct MessagesHistoryItemView: View {
    
    let viewModel: MessagesHistoryItemView.ViewModel
    
    var body: some View {
        
        HStack(alignment: .top) {
            
            VStack(alignment: .center) {
                
                viewModel.icon
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.iconWhite)
                    .background(Circle().frame(width: 40, height: 40).foregroundColor(.bGIconRedLight))
                    .padding(.init(top: 12, leading: 16, bottom: 0, trailing: 12))
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6)  {
                
                VStack(alignment: .leading) {
                    
                    Text(viewModel.title)
                        .font(.textH4M16240())
                        .foregroundColor(.textSecondary)
                    
                    Text(viewModel.content)
                        .font(.textBodySR12160())
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                Text(viewModel.time)
                    .font(.textBodySR12160())
                    .foregroundColor(.gray)
            }
            Spacer()
        } .padding(.trailing, 19)
    }
}

//MARK: - Preview

struct MessagesHistoryItemView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MessagesHistoryItemView(viewModel:.sample)
            .previewLayout(.fixed(width: 375, height: 100))
    }
}

//MARK: - Preview Content

extension MessagesHistoryItemView.ViewModel {
    
    static let sample = MessagesHistoryItemView.ViewModel(icon: Image.ic24MoreHorizontal, title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56")
}
