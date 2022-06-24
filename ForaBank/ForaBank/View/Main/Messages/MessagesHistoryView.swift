//
//  MessagesHistoryView.swift
//  ForaBank
//
//  Created by Константин Савялов on 21.04.2022.
//

import SwiftUI
import Combine
import Introspect

struct MessagesHistoryView: View {
    
    @ObservedObject var viewModel: MessagesHistoryViewModel
    @State private var height: CGFloat = .zero
    @State private var tabBarController: UITabBarController?
    
    var body: some View {
        
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
        .navigationBar(with: viewModel.navigationBar)
        .introspectTabBarController(customize: { tabBarController in
            
            self.tabBarController = tabBarController
            tabBarController.tabBar.isHidden = true
            UIView.transition(with: tabBarController.view, duration: 0.05, options: .transitionCrossDissolve, animations: nil)
        })
        .onDisappear {
            
            if let tabBarController = tabBarController {
                
                tabBarController.tabBar.isHidden = false
                UIView.transition(with: tabBarController.view, duration: 0.05, options: .transitionCrossDissolve, animations: nil)
            }
        }
        .bottomSheet(item: $viewModel.sheet) {
        } content: { sheet in
            
            switch sheet.sheetType {
            case let .item(model):
                MessagesHistoryDetailView(model: model)
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
            title: "25 агуста, ср",
            items: [MessagesHistoryItemView.ViewModel(icon: Image.ic24MoreHorizontal, title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56"),
                    MessagesHistoryItemView.ViewModel(icon: Image.ic24MoreHorizontal, title: "Отказ. Недостаточно средств.", content: "LIQPAY*IP Artur Danilo, Moscow Интернет-оплата. Карта / счет .4387 16:59", time: "17:56")
                   ]),
        .init(title: "26 агуста, чт",
              items: [MessagesHistoryItemView.ViewModel(icon: Image.ic24MoreHorizontal, title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56"),
                      MessagesHistoryItemView.ViewModel(icon: Image.ic24MoreHorizontal, title: "Отказ. Недостаточно средств.", content: "LIQPAY*IP Artur Danilo, Moscow Интернет-оплата. Карта / счет .4387 16:59", time: "17:56")
                     ]),
        .init(title: "27 агуста, пт",
              items: [MessagesHistoryItemView.ViewModel(icon: Image.ic24MoreHorizontal, title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56"),
                      MessagesHistoryItemView.ViewModel(icon: Image.ic24MoreHorizontal, title: "Отказ. Недостаточно средств.", content: "LIQPAY*IP Artur Danilo, Moscow Интернет-оплата. Карта / счет .4387 16:59", time: "17:56")
                     ]),
        .init(title: "28 агуста, суб",
              items: [MessagesHistoryItemView.ViewModel(icon: Image.ic24MoreHorizontal, title: "Срок вашей карты истекает 29.08.2021 г.", content: "Оставте он-лайн заявку или обратитесь в ближайшее отделение банка", time: "17:56"),
                      MessagesHistoryItemView.ViewModel(icon: Image.ic24MoreHorizontal, title: "Отказ. Недостаточно средств.", content: "LIQPAY*IP Artur Danilo, Moscow Интернет-оплата. Карта / счет .4387 16:59", time: "17:56")
                     ])
        
    ], model: Model.emptyMock, state: .stating)
}
