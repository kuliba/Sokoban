//
//  TransfersQuestionsViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 30.11.2022.
//  Refactor by Dmitry Martynov on 28.12.2022
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension TransfersQuestionsView {
    
    class ViewModel: TransfersSectionViewModel, ObservableObject {
        
        typealias QuestionsData = TransferAbroadResponseData.QuestionTransferData
        
        override var type: TransfersSectionType { .questions }
        let items: [ItemsViewModel]
        
        private var bindings = Set<AnyCancellable>()
        
        init(items: [ItemsViewModel]) {
            
            self.items = items
        }
        
        convenience init(data: QuestionsData) {
            
            self.init(items: Self.reduce(data: data.content))
            self.title = data.title
            bind()
        }
        
        private func bind() {
            
            for item in items {
                
                item.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                            
                        case _ as TransfersQuestionsAction.Item.Tap:
             
                            for elem in items {
                                if elem.id != item.id {
                                    withAnimation {
                                        elem.isCollapsed = true
                                    }
                                }
                            }
                            
                            withAnimation {
                                item.isCollapsed.toggle()
                            }
                            
                        default: break
                        }
                        
                    }.store(in: &bindings)
            }
        }
    }
}

extension TransfersQuestionsView.ViewModel {
    
    static func reduce(data: [QuestionsData.ContentData]) -> [ItemsViewModel] {
        
        var items = [ItemsViewModel]()
        for (index, dataItem) in data.enumerated() {
            
            items.append(.init(id: index,
                               title: dataItem.title,
                               description: dataItem.description))
        }
        
        return items
    }
}

extension TransfersQuestionsView.ViewModel {
    
    class ItemsViewModel: ObservableObject, Identifiable {

        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var isCollapsed: Bool = true
        
        let title: String
        let description: String
        let id: Int
        
        init(id: Int, title: String, description: String) {
        
            self.id = id
            self.title = title
            self.description = description
        }
    }
}

// MARK: - View

struct TransfersQuestionsView: View {
    
    let viewModel: TransfersQuestionsView.ViewModel
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(.mainColorsGrayLightest)
            
            VStack(alignment: .leading) {
                
                Text(viewModel.title)
                    .font(.textH3SB18240())
                    .foregroundColor(.mainColorsBlack)
                    .padding(.horizontal)
                
                VStack(spacing: 0) {
                    
                    ForEach(viewModel.items) { item in
                        ItemsView(viewModel: item)
                    }
                }
                
            }.padding(.top, 12)
        }
    }
}

extension TransfersQuestionsView {
    
    struct ItemsView: View {
        
        @ObservedObject var viewModel: TransfersQuestionsView.ViewModel.ItemsViewModel
        
        var body: some View {
            
            VStack(alignment: .leading) {
                
                HStack {
                    
                    Text(viewModel.title)
                        .font(.textBodyMR14200())
                    
                    Spacer(minLength: 20)
                    
                    Image.ic24ChevronDown
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 22, height: 22)
                        .rotationEffect(viewModel.isCollapsed ? .degrees(0) : .degrees(-180))
                }
                .foregroundColor(.mainColorsBlack)
                .background(Color.mainColorsGrayLightest)
                .frame(height: 64)
                .onTapGesture {
                        viewModel.action.send(TransfersQuestionsAction.Item.Tap())
                }
                
                if !viewModel.isCollapsed {
                    
                    Text(viewModel.description)
                        .multilineTextAlignment(.leading)
                        .font(.textBodyMR14200())
                        .foregroundColor(.mainColorsGray)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
    }
}

// MARK: - Action

enum TransfersQuestionsAction {
    
    enum Item {
        
        struct Tap: Action {}
    }
}

// MARK: - Content

extension TransfersQuestionsView.ViewModel {
    
    static let sampleData: QuestionsData =
    
        .init(title: "Часто задаваемые вопросы",
              content: [.init(title: "В какой срок получатель увидит на своем счете денежные средства?",
                      description: "Перевод будет зачислен и средства доступны уже через несколько секунд после отправки."),
                        .init(title: "Возможно ли отменить перевод?",
                              description: "После подтверждения отправки перевода и списания суммы с вашего счета вы можете подать заявление в любом офисе банка или обратиться любым удобным способом в контакт–центр банка, в том числе через приложение."),
                        .init(title: "Как перевести деньги, если у вашего получателя еще нет карты в банке-партнере?",
                              description: "Если у вашего получателя еще нет карты в АйДи Банке, Араратбанке, Ардшинбанке, АрмБизнесбанке или Эвокабанке, закажите её бесплатно с доставкой на сайте любого банка-партнера."),
                        .init(title: "1111", description: "qweqweqe qweqewqeqwe qe")])
}
// MARK: - Preview

struct TransfersQuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        TransfersQuestionsView(viewModel: .init(data: TransfersQuestionsView.ViewModel.sampleData))
            .padding(8)
    }
}
