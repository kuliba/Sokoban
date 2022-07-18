//
//  CurrencyListVIewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 22.06.2022.
//

import SwiftUI
import Combine
import Shimmer

typealias CurrencyItemViewModel = CurrencyListView.ViewModel.ItemViewModel

// MARK: - ViewModel

extension CurrencyListView {

    class ViewModel: ObservableObject {

        let action: PassthroughSubject<Action, Never> = .init()

        @Published var items: [ItemViewModel]
        @Published var currencyType: String

        private var bindings = Set<AnyCancellable>()
        
        let model: Model

        lazy var button: ButtonViewModel = .init { [unowned self] in
            action.send(CurrencyListAction.Button.Tapped())
        }

        init(_ model: Model, currencyType: String, items: [ItemViewModel]) {

            self.model = model
            self.currencyType = currencyType
            self.items = items
            
            bind()
        }
        
        private func bind() {
            
            model.currencyWalletList
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] items in
                    
                    self.items = reduce(items)
                    
                }.store(in: &bindings)
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as CurrencyListAction.Item.Tapped:
                        
                        currencyType = payload.currencyType
                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                        
                        items.forEach { $0.isSelected = currencyType == $0.currencyType }
                        
                    default:
                        break
                    }
                }.store(in: &bindings)
        }
    }
}

extension CurrencyListView.ViewModel {

    // MARK: - Item

    class ItemViewModel: ObservableObject, Identifiable {

        @Published var isSelected: Bool

        let id: String
        let icon: Image?
        let currencyType: String
        let rateBuy: String
        let rateSell: String

        init(id: String = UUID().uuidString,
             icon: Image?,
             currencyType: String,
             rateBuy: String,
             rateSell: String,
             isSelected: Bool = false) {

            self.id = id
            self.icon = icon
            self.currencyType = currencyType
            self.rateBuy = rateBuy
            self.rateSell = rateSell
            self.isSelected = isSelected
        }
    }

    // MARK: - Button

    struct ButtonViewModel {

        let title: String = "∙∙∙"
        let action: () -> Void
    }
}

// MARK: - View

struct CurrencyListView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {

        HStack {

            ScrollView(.horizontal, showsIndicators: false) {

                HStack(spacing: 8) {

                    ButtonView(viewModel: viewModel.button)

                    ForEach(viewModel.items) { itemViewModel in
                        ItemView(viewModel: itemViewModel)
                            .onTapGesture {
                                viewModel.action.send(CurrencyListAction.Item.Tapped(
                                    currencyType: itemViewModel.currencyType))
                            }
                    }
                }.padding(20)
            }
        }
    }
}

extension CurrencyListView {

    // MARK: - Item

    struct ItemView: View {

        @ObservedObject var viewModel: ViewModel.ItemViewModel

        var body: some View {

            ZStack {

                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.mainColorsGrayLightest)

                HStack {

                    VStack {

                        ZStack {

                            if viewModel.isSelected == true {

                                Circle()
                                    .stroke(lineWidth: 2)
                                    .foregroundColor(.systemColorActive)
                            }

                            if let icon = viewModel.icon {
                                
                                icon
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                
                            } else {
                                
                                Circle()
                                    .fill(Color.mainColorsGrayMedium)
                                    .frame(width: 20, height: 20)
                                    .shimmering(active: true, bounce: false)
                            }
                            
                        }.frame(width: 25, height: 25)

                        Text(viewModel.currencyType)
                            .font(.textBodySM12160())
                            .foregroundColor(.mainColorsGray)
                    }

                    VStack(spacing: 8) {

                        Text(viewModel.rateBuy)
                            .font(.textBodySM12160())
                            .foregroundColor(.mainColorsBlack)

                        Divider()
                            .frame(width: 34)
                            .background(Color.mainColorsGrayMedium)

                        Text(viewModel.rateSell)
                            .font(.textBodySM12160())
                            .foregroundColor(.mainColorsBlack)
                    }
                }
            }.frame(width: 84, height: 60)
        }
    }

    // MARK: - Button

    struct ButtonView: View {

        let viewModel: ViewModel.ButtonViewModel

        var body: some View {

            Button(action: viewModel.action) {

                ZStack {

                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(.mainColorsGrayLightest)

                    Text(viewModel.title)
                        .font(.textBodyMSB14200())
                        .foregroundColor(.mainColorsGray)

                }.frame(width: 29, height: 60)
            }
        }
    }
}

// MARK: - Reducer

extension CurrencyListView.ViewModel {
    
    func reduce(_ items: [CurrencyWalletData]) -> [ItemViewModel] {
        
        items.map { item in
            
            let icon = model.images.value[item.md5hash]
            
            return .init(
                icon: icon?.image,
                currencyType: item.code,
                rateBuy: item.rateBuy.decimal(),
                rateSell: item.rateSell.decimal(),
                isSelected: currencyType == item.code)
        }
    }
}

// MARK: - Action

enum CurrencyListAction {

    enum Button {

        struct Tapped: Action {}
    }
    
    enum Item {

        struct Tapped: Action {
            
            let currencyType: String
        }
    }
}

// MARK: - Preview Content

extension CurrencyListView.ViewModel {
    
    static let sample: CurrencyListView.ViewModel = .init(
        .productsMock,
        currencyType: "USD",
        items: [
            .init(icon: .init("Flag USD"),
                  currencyType: "USD",
                  rateBuy: "68.19",
                  rateSell: "69.45",
                  isSelected: true),
            .init(icon: .init("Flag EUR"),
                  currencyType: "EUR",
                  rateBuy: "69.23",
                  rateSell: "70.01"),
            .init(icon: .init("Flag GBP"),
                  currencyType: "GBP",
                  rateBuy: "75.65",
                  rateSell: "76.83"),
            .init(icon: .init("Flag CHF"),
                  currencyType: "CHF",
                  rateBuy: "64.89",
                  rateSell: "65.09"),
            .init(icon: .init("Flag CHY"),
                  currencyType: "CHY",
                  rateBuy: "18.45",
                  rateSell: "19.26")
        ])
}

// MARK: - Previews

struct CurrencyListViewComponent_Previews: PreviewProvider {

    static var previews: some View {

        CurrencyListView(viewModel: .sample)
            .previewLayout(.sizeThatFits)
    }
}
