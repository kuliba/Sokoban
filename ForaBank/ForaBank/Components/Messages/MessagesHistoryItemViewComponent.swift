//
//  MessagesHistoryItemComponentView.swift
//  ForaBank
//
//  Created by Константин Савялов on 20.04.2022.
//

import SwiftUI

//MARK: - ViewModel

extension MessagesHistoryItemView {
    
    class ViewModel: Identifiable {
        
        let id = UUID()
        let icon: Image
        let title: String
        let content: String
        let time: String
        let action: () -> Void
        
        internal init(icon: Image, title: String, content: String, time: String, action: @escaping () -> Void) {
            
            self.icon = icon
            self.title = title
            self.content = content
            self.time = time
            self.action = action
        }
        
    }
}

//MARK: - View

struct MessagesHistoryItemView: View {
    
    let viewModel: MessagesHistoryItemView.ViewModel
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 20) {
            
            VStack(alignment: .center) {
                viewModel.icon
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.leading, 4)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4)  {
                
                Text(viewModel.title)
                    .font(.textH4M16240())
                    .foregroundColor(.textSecondary)
                
                Text(viewModel.content)
                    .font(.textBodySR12160())
                    .foregroundColor(.gray)
                
                Text(viewModel.time)
                    .font(.textBodySR12160())
                    .foregroundColor(.gray)
            }
            Spacer()
        }
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
    
    static let sample = MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56", action: {})
}
