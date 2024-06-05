//
//  CurrencyListVIewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 22.06.2022.
//

import SwiftUI
import Combine
import Shimmer

typealias CurrencyListViewModel = CurrencyListView.ViewModel
typealias CurrencyItemViewModel = CurrencyListView.ViewModel.ItemViewModel

// MARK: - ViewModel

extension CurrencyListView {

    class ViewModel: ObservableObject, CurrencyWalletItem {
        
        let action: PassthroughSubject<Action, Never> = .init()

        @Published var items: [ItemViewModel]
        @Published var currency: Currency
        @Published var bottomSheet: BottomSheet?
        @Published var isUserInteractionEnabled: Bool

        private var bindings = Set<AnyCancellable>()
        
        private let model: Model
        let id = UUID().uuidString

        lazy var button: ButtonViewModel = .init { [unowned self] in
            action.send(CurrencyListAction.Button.Tapped())
        }

        init(_ model: Model, currency: Currency, items: [ItemViewModel], isUserInteractionEnabled: Bool = true) {

            self.model = model
            self.currency = currency
            self.items = items
            self.isUserInteractionEnabled = isUserInteractionEnabled
        }
        
        convenience init(_ model: Model, currency: Currency) {

            self.init(model, currency: currency, items: [])
            bind()
        }
        
        private func bind() {
            
            model.currencyWalletList
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] items in
                    
                    let images = model.images.value
                    let items = Self.reduce(items: items, images: images, currency: currency)
                    
                    withAnimation(.interactiveSpring()) {
                        self.items = items
                    }
                    
                    let iconsHashNeedsDownload = iconsHashNeedsDownload(self.items)
                    
                    if iconsHashNeedsDownload.isEmpty == false {
                        
                        model.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: iconsHashNeedsDownload))
                    }
                    
                }.store(in: &bindings)
            
            model.images
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] images in
                    
                    let itemsNeedsUpdateIcons = itemsNeedsUpdateIcons(items)
                    
                    guard itemsNeedsUpdateIcons.isEmpty == false else {
                        return
                    }
                    
                    withAnimation(.interactiveSpring()) {
                        
                        itemsNeedsUpdateIcons.forEach { $0.icon = images[$0.iconId]?.image }
                    }
                    
                }.store(in: &bindings)
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as CurrencyListAction.Button.Tapped:
                        
                        if model.currencyWalletList.value.isEmpty == false {
                            bottomSheet = .init(sheetType: .currencyRate(model))
                        } else {
                            bottomSheet = .init(sheetType: .placeholder)
                        }
                        
                    case let payload as CurrencyListAction.Item.Tapped:
                        
                        currency = payload.currency
                        items.forEach { $0.isSelected = currency.description == $0.currency.description }

                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                        
                    default:
                        break
                    }
                }.store(in: &bindings)
        }
        
        struct BottomSheet: BottomSheetCustomizable {

            let id = UUID()
            let sheetType: BottomSheetType

            enum BottomSheetType {

                case placeholder
                case currencyRate(Model)
            }
        }
    }
}

extension CurrencyListView.ViewModel {

    // MARK: - Item

    class ItemViewModel: ObservableObject, Identifiable {

        @Published var isSelected: Bool

        var id: String { currency.description }
        var icon: Image?
        let currency: Currency
        let rateBuy: String
        let rateSell: String
        let rateBuyItem: Double
        let rateSellItem: Double
        let iconId: String

        init(icon: Image?,
             currency: Currency,
             rateBuy: String,
             rateSell: String,
             rateBuyItem: Double,
             rateSellItem: Double,
             iconId: String = "",
             isSelected: Bool = false) {

            self.icon = icon
            self.currency = currency
            self.rateBuy = rateBuy
            self.rateSell = rateSell
            self.rateBuyItem = rateBuyItem
            self.rateSellItem = rateSellItem
            self.iconId = iconId
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
                                    currency: itemViewModel.currency))
                            }
                    }
                }.padding(.horizontal, 20)
            }
        }.bottomSheet(item: $viewModel.bottomSheet) { sheetType in
            
            switch sheetType.sheetType {
            case .placeholder:
                
                CurrencyRatesListView.PlaceholderItemView()
                
            case let .currencyRate(model):
                
                CurrencyRatesListView(viewModel: .init(model))
            }
            
        }.disabled(viewModel.isUserInteractionEnabled == false)
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
                                    .shimmering()
                            }
                            
                        }.frame(width: 25, height: 25)

                        Text(viewModel.currency.description)
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
                        .font(.textBodyMSb14200())
                        .foregroundColor(.mainColorsGray)

                }.frame(width: 29, height: 60)
            }
        }
    }
}

// MARK: - Reducers

extension CurrencyListView.ViewModel {
    
    static func reduce(items: [CurrencyWalletData], images: [String: ImageData], currency: Currency) -> [ItemViewModel] {
        
        items.map { item in
            
            let icon = images[item.md5hash]
            
            return .init(
                icon: icon?.image,
                currency: Currency(description: item.code),
                rateBuy: NumberFormatter.decimal(item.rateSell * Double(item.currAmount)),
                rateSell: NumberFormatter.decimal(item.rateBuy * Double(item.currAmount)),
                rateBuyItem: item.rateSell,
                rateSellItem: item.rateBuy,
                iconId: item.md5hash,
                isSelected: currency.description == item.code)
        }
    }
    
    static func reduceCurrencyWallet(_ items: [CurrencyWalletData], images: [String: ImageData], currency: Currency) -> [CurrencyItemViewModel] {
        
        return items.map { item in
            
            let icon = images[item.md5hash]
            
            return .init(
                icon: icon?.image,
                currency: Currency(description: item.code),
                rateBuy: NumberFormatter.decimal(item.rateSell),
                rateSell: NumberFormatter.decimal(item.rateBuy),
                rateBuyItem: item.rateSell,
                rateSellItem: item.rateBuy,
                iconId: item.md5hash,
                isSelected: currency.description == item.code)
        }
    }
}

// MARK: - Methods

extension CurrencyListView.ViewModel {
    
    func iconsHashNeedsDownload(_ items: [ItemViewModel]) -> [String] {
        
        return items.filter { $0.icon == nil }.map { $0.iconId }
    }
    
    func itemsNeedsUpdateIcons(_ items: [ItemViewModel]) -> [ItemViewModel] {
        
        return items.filter { $0.icon == nil }
    }
}

// MARK: - Action

enum CurrencyListAction {

    enum Button {

        struct Tapped: Action {}
    }
    
    enum Item {

        struct Tapped: Action {
            
            let currency: Currency
        }
    }
}

// MARK: - Previews

struct CurrencyListViewComponent_Previews: PreviewProvider {

    static var previews: some View {

        CurrencyListView(viewModel: .sample)
            .fixedSize()
            .previewLayout(.sizeThatFits)
            .padding(.vertical)
    }
}
