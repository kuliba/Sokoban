//
//  MessagesHistoryView.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.04.2022.
//

import SwiftUI
import Combine

struct MessagesHistoryView: View {
    
    @ObservedObject var viewModel: MessagesHistoryViewModel
    @State private var height: CGFloat = .zero
    
    var body: some View {
        
        NavigationView {
            
            ScrollView {
                
                VStack(spacing: 0) {
                    
                    ForEach(viewModel.sections) { section in
                        MessagesHistorySectionView(viewModel: section)
                    }
                }
                .padding(.leading, 15)
                .background(GeometryReader { geo in
                    
                    Color.clear
                        .preference(key: ScrollOffsetKey.self, value: -geo.frame(in: .named("scroll")).origin.y)
                        .preference(key: ScrollContentHeifgtKey.self, value: geo.frame(in: .named("scroll")).height)
                })
                .onPreferenceChange(ScrollOffsetKey.self) { offset in
                    
                    if offset > height - UIScreen.main.bounds.size.height {
                        viewModel.action.send(MessagesHistoryViewModelAction.ScrolledToEnd())
                    }
                }
                .onPreferenceChange(ScrollContentHeifgtKey.self) { height in
                    self.height = height
                }
            }
            .coordinateSpace(name: "scroll")
            .navigationBarTitle(
                Text("Центр уведомлений"),
                displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                
            }, label: { Image.ic16ArrowLeft }))
            .navigationViewStyle(StackNavigationViewStyle())
            .bottomSheet(item: $viewModel.sheet) {

                // onDismiss action

            } content: { sheet in

                switch sheet.sheetType {
                case .button:

                    Color.mainColorsGrayLightest
                        .frame(height: 250)

                case let .item(model):
                    MessagesHistoryDetailView(model: model)
                    
                }
            }
        }
    }
}

extension MessagesHistoryView {
    
    struct ScrollOffsetKey: PreferenceKey {
        
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
    
    struct ScrollContentHeifgtKey: PreferenceKey {
        
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
}

struct MessagesHistoryView_Previews: PreviewProvider {
    
    static var previews: some View {
        MessagesHistoryView(viewModel: .sample)
    }
}

extension MessagesHistoryViewModel {
    
    static let sample = MessagesHistoryViewModel(sections: [
        .init(
            section: "25 агуста, ср",
            items: [MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56"),
                    MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Отказ. Недостаточно средств.", content: "LIQPAY*IP Artur Danilo, Moscow Интернет-оплата. Карта / счет .4387 16:59", time: "17:56")
                   ]),
        .init(section: "26 агуста, чт",
              items: [MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56"),
                      MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Отказ. Недостаточно средств.", content: "LIQPAY*IP Artur Danilo, Moscow Интернет-оплата. Карта / счет .4387 16:59", time: "17:56")
                     ]),
        .init(section: "27 агуста, пт",
              items: [MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56"),
                      MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Отказ. Недостаточно средств.", content: "LIQPAY*IP Artur Danilo, Moscow Интернет-оплата. Карта / счет .4387 16:59", time: "17:56")
                     ]),
        .init(section: "28 агуста, суб",
              items: [MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56"),
                      MessagesHistoryItemView.ViewModel(icon: Image("Payments List Sample"), title: "Отказ. Недостаточно средств.", content: "LIQPAY*IP Artur Danilo, Moscow Интернет-оплата. Карта / счет .4387 16:59", time: "17:56")
                     ])
        
    ], model: Model.emptyMock, state: .stating)
}
