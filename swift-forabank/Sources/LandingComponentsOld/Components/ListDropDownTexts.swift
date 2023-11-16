//
//  ListDropDownTexts.swift
//  
//
//  Created by Dmitry Martynov on 14.08.2023.
//

import SwiftUI
import Combine

/*
 {
         "type": "LIST_DROP_DOWN_TEXTS",
         "data": {
           "title": "Часто задаваемые вопросы",
           "list": [
             {
               "title": "Как можно отправить перевод за рубеж?",
               "description": "В приложении в разделе «Платежи» выберите «Перевести за рубеж и по РФ».\nВыберите страну и введите номер телефона или ФИО получателя. Номера мобильного телефона будет достаточно для перевода в Армению или ФИО получателя при переводе в другие страны."
             },
             {
               "title": "Как можно отправить перевод в Армению?",
               "description": "В приложении выберите Перевод по номеру телефона и введите номер телефона получателя. Далее следуйте подсказкам системы и выберите банк – получателя в Армении."
             },
             {
               "title": "В какой валюте можно отправить и получить перевод?",
               "description": "Валюта отправки и получения перевода зависит от выбранной страны получения перевода. Например, отправка переводов в Армению осуществляется в рублях, а получить перевод можно на карту с валютой счета – рубль РФ, драм, доллар США или евро."
             },
             {
               "title": "Какую сумму можно отправить и сколько стоит перевод?",
               "description": "В Армению можно отправить до 1 млн. рублей за операцию / в день / в месяц. Комиссия составит 1%.\nВ другие страны по ПС Contact – до 5 000$ или эквивалент в другой валюте за операцию / в день / в месяц. Комиссия от 0% до 2% от суммы перевода зависит от страны и валюты перевода."
             },
             {
               "title": "Как быстро получатель сможет получить денежные средства?",
               "description": "Перевод будет зачислен моментально, при переводах в Армению средства поступят на счет/карту в банке-партнере.\nПри переводах в иные страны перевод доступен к получению через несколько секунд в пунктах выдачи наличных (ПВН) ПС Contact."
             }
           ]
         }
       }
 */

public struct ListDropDownTextsModel: Decodable, Equatable {
    
    let type: LandingComponentsType
    let data: ListDropDownTextsData
    
    struct ListDropDownTextsData: Decodable, Equatable {
        let title: String
        let list: [ListDropDownTextsDataList]
    }
    
    struct ListDropDownTextsDataList: Decodable, Equatable {
        let title: String
        let description: String
    }
    
    public func reduce() -> ListDropDownTextsViewModel {
        
        let items = data.list.map {
            
            ListDropDownTextsViewModel.ItemViewModel
                .init(title: $0.title, description: $0.description)
        }
        
        return .init(title: data.title, items: items)
    }
}

// MARK: - ViewModel

public final class ListDropDownTextsViewModel {
    
    let items: [ItemViewModel]
    let title: String
    let id: UUID = UUID()
    
    private var bindings = Set<AnyCancellable>()
    
    init(title: String,
         items: [ItemViewModel]) {
        
        self.items = items
        self.title = title
        bind()
    }
    
    private func bind() {
        
        for item in items {
            
            item.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                        
                    case _ as ListDropDownTextsAction.Item.Tap:
         
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
    
extension ListDropDownTextsViewModel: Hashable {

    class ItemViewModel: ObservableObject, Identifiable {

        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var isCollapsed: Bool = true
        
        let id = UUID()
        let title: String
        let description: String
     
        init(title: String,
             description: String) {
    
            self.title = title
            self.description = description
        }
    }
    
    public static func == (lhs: ListDropDownTextsViewModel,
                           rhs: ListDropDownTextsViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - View

public struct ListDropDownTextsView: View {
    
    public init(viewModel: ListDropDownTextsViewModel) {
        self.viewModel = viewModel
    }
    
    let viewModel: ListDropDownTextsViewModel
    
    public var body: some View {
    
        ZStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(Color("mainColorsGrayLightest", bundle: Bundle.module))//.mainColorsGrayLightest)
            
            VStack(alignment: .leading) {
                
                Text(viewModel.title)
                    //.font(.textH3SB18240())
                    .foregroundColor(.black)//.mainColorsBlack)
                    .padding(.horizontal)
                
                VStack(spacing: 0) {
                    
                    ForEach(viewModel.items) { item in
                        ItemView(viewModel: item)
                    }
                }
                
            }.padding(.top, 12)
        }.padding(.horizontal)
        
    }
}

extension ListDropDownTextsView {
    
    struct ItemView: View {
            
        @ObservedObject var viewModel: ListDropDownTextsViewModel.ItemViewModel
            
        var body: some View {
             
            VStack(alignment: .leading) {
                
                HStack {
                    
                    Text(viewModel.title)
                        //.font(.textBodyMR14200())
                    
                    Spacer(minLength: 20)
                    
                    Image("ic24ChevronDown", bundle: Bundle.module)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 22, height: 22)
                        .rotationEffect(viewModel.isCollapsed ? .degrees(0) : .degrees(-180))
                }
                .foregroundColor(.black)//.mainColorsBlack)
                .background(Color("mainColorsGrayLightest", bundle: Bundle.module))//mainColorsGrayLightest)
                .frame(height: 64)
                .onTapGesture {
                        viewModel.action.send(ListDropDownTextsAction.Item.Tap())
                }
                
                if !viewModel.isCollapsed {
                    
                    Text(viewModel.description)
                        .multilineTextAlignment(.leading)
                        //.font(.textBodyMR14200())
                        .foregroundColor(.gray)//.mainColorsGray)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal)
            
        }
    }
}

// MARK: - Action

enum ListDropDownTextsAction {
    
    enum Item {
        
        struct Tap: Action {}
    }
}

// MARK: - PreviewContent

extension ListDropDownTextsViewModel {
    
    static var sampleItems: [ItemViewModel] = [
        .init(title: "Как можно отправить перевод за рубеж?",
              description: "В приложении в разделе «Платежи» выберите «Перевести за рубеж и по РФ».\nВыберите страну и введите номер телефона или ФИО получателя. Номера мобильного телефона будет достаточно для перевода в Армению или ФИО получателя при переводе в другие страны."),
        
        .init(title: "Как можно отправить перевод в Армению?",
              description: "В приложении выберите Перевод по номеру телефона и введите номер телефона получателя. Далее следуйте подсказкам системы и выберите банк – получателя в Армении.")
    ]
}

// MARK: - Preview

struct ListDropDownTextsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ListDropDownTextsView(viewModel: .init(title: "Часто задаваемые вопросы",
                                               items: ListDropDownTextsViewModel.sampleItems))
    }
}
