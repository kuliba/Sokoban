//
//  MessagesHistoryView.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.04.2022.
//

import SwiftUI

struct MessagesHistoryView: View {
    
   @ObservedObject var viewModel: MessagesHistoryViewModel
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                
                VStack(spacing: 0) {
                    
                    ForEach(viewModel.sections) { sections in
                        
                        MessagesHistorySectionView(viewModel: sections.viewModel)
                    }
                } .padding(.leading, 15)
            }
            .navigationBarTitle(
                Text("Центр уведомлений"),
                displayMode: .inline)
            
            .navigationBarItems(leading:
                                    Button(action: {
                
                                    }, label: {
                                        
                                    Image.ic16ArrowLeft
                                })
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MessagesHistoryView_Previews: PreviewProvider {
    
    static var previews: some View {
        MessagesHistoryView(viewModel: .init(sections: MessagesHistoryView.sections))
    }
}

extension MessagesHistoryView {
    
    static let sections = [MessagesHistorySectionView.init(viewModel: .init(section: "25 агуста, ср",
                                                                         items: [MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56", action: {}),
                                                                                 MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Отказ. Недостаточно средств.", content: "LIQPAY*IP Artur Danilo, Moscow Интернет-оплата. Карта / счет .4387 16:59", time: "17:56", action: {})
                                                                                ])),
                        MessagesHistorySectionView.init(viewModel: .init(section: "26 агуста, чт",
                                                                                             items: [MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56", action: {}),
                                                                                                     MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Отказ. Недостаточно средств.", content: "LIQPAY*IP Artur Danilo, Moscow Интернет-оплата. Карта / счет .4387 16:59", time: "17:56", action: {})
                                                                                                    ])),
                        MessagesHistorySectionView.init(viewModel: .init(section: "27 агуста, пт",
                                                                                             items: [MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56", action: {}),
                                                                                                     MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Отказ. Недостаточно средств.", content: "LIQPAY*IP Artur Danilo, Moscow Интернет-оплата. Карта / счет .4387 16:59", time: "17:56", action: {})
                                                                                                    ])),
                        MessagesHistorySectionView.init(viewModel: .init(section: "28 агуста, суб",
                                                                                             items: [MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56", action: {}),
                                                                                                     MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Отказ. Недостаточно средств.", content: "LIQPAY*IP Artur Danilo, Moscow Интернет-оплата. Карта / счет .4387 16:59", time: "17:56", action: {})
                                                                                                    ]))
                        
    ]
    
}
