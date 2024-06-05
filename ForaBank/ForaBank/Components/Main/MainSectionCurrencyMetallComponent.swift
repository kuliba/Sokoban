//
//  MainSectionCurrencyMetallComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 04.07.2022.
//

import Foundation
import SwiftUI
import Combine
import UIPrimitives

//MARK: - ViewModel

extension MainSectionCurrencyMetallView {
    
    class ViewModel: MainSectionCollapsableViewModel, ObservableObject {

        override var type: MainSectionType { .currencyMetall }
        
        @Published var content: Content
        @Published var selector: OptionSelectorView.ViewModel?
        @Published var items: [ItemViewModel]
        
        enum Content {
            
            case placeholders
            case items([ItemViewModel])
        }

        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        internal init(content: Content, items: [ItemViewModel] = [],
                      selector: OptionSelectorView.ViewModel?,
                      model: Model = .emptyMock,
                      isCollapsed: Bool) {
            
            self.content = content
            self.items = items
            self.selector = selector
            self.model = model
            super.init(isCollapsed: isCollapsed)
        }
        
        init(_ model: Model) {
            
            self.content = .placeholders
            self.selector = nil
            self.model = model
            self.items = []
            super.init(isCollapsed: false)
            
            bind()
        }
        
//MARK: Bindings
        
        private func bind() {
            
            model.dictionariesUpdating
                .receive(on: DispatchQueue.main)
                .sink { dictUpdatingSet in
                
                    updateContent(dictUpdatingSet)
            }
            .store(in: &bindings)
            
            model.currencyWalletList
                .combineLatest(model.currencyList)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] data in
                
                    let list = data.0
                    let currencyData = data.1
                
                    let result = Self.reduce(
                        
                        model,
                        list: list,
                        currencyData: currencyData,
                        itemAction: { [weak self] currency in
                            return { self?.action.send(
                                MainSectionViewModelAction.CurrencyMetall.DidTapped.Item(code: currency))}},
                        buyAction: { [weak self] currency in
                            return { self?.action.send(
                                MainSectionViewModelAction.CurrencyMetall.DidTapped.Buy(code: currency))}},
                        sellAction: { [weak self] currency in
                            return  { self?.action.send(
                                MainSectionViewModelAction.CurrencyMetall.DidTapped.Sell(code: currency)) }})
                    
                    self.items = result.items
                
                    if !result.imagesMd5ToUpload.isEmpty {
                        model.action.send(
                            ModelAction.Dictionary.DownloadImages.Request(imagesIds: result.imagesMd5ToUpload))
                    }
                    
            }.store(in: &bindings)
        
            $items
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] items in

                    updateContent(model.dictionariesUpdating.value)

                }.store(in: &bindings)

            model.images
                .receive(on: DispatchQueue.main)
                .sink { [unowned self ] images in
                    let emptyImg = self.items.filter { $0.mainImg.img == nil }
                
                    guard !emptyImg.isEmpty else { return }
                    withAnimation {
                        self.items.forEach { $0.mainImg.img = images[$0.mainImg.md5]?.image }
                    }
            }
            .store(in: &bindings)
            
            func updateContent(_ dictUpdatingSet: Set<DictionaryType>) {
                
                if dictUpdatingSet.contains(.currencyWalletList) || self.items.isEmpty {

                    withAnimation {
                        self.content = .placeholders
                    }

                } else {
                    
                    withAnimation {
                        self.content = .items(self.items)
                    }
                }
            }
        }

//MARK: Reduce Items
        
        static func reduce(_ model: Model,
                           list: [CurrencyWalletData],
                           currencyData: [CurrencyData],
                           itemAction: @escaping (Currency) -> () -> Void,
                           buyAction: @escaping (Currency) -> () -> Void,
                           sellAction: @escaping (Currency) -> () -> Void)
                    -> (items: [ItemViewModel], imagesMd5ToUpload: [String]) {
                    
            let items = list.map { item -> ItemViewModel in
                
                let imageData = model.images.value[item.md5hash]
                let itemViewModel: ItemViewModel = .init(currencyData: currencyData,
                                                         item: item,
                                                         imageData: imageData,
                                                         itemAction: itemAction,
                                                         buyAction: buyAction,
                                                         sellAction: sellAction)
                return itemViewModel
            }
            
            let filterredItems = items.filter { $0.mainImg.img == nil }
            let imagesMd5ToUpload = filterredItems.map { $0.mainImg.md5 }
                    
            return (items, imagesMd5ToUpload)
        }
    }
}

//MARK: - View

struct MainSectionCurrencyMetallView: View {
    
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        CollapsableSectionView(title: viewModel.title, edges: .horizontal, padding: 20, isCollapsed: $viewModel.isCollapsed) {
            
            VStack(spacing: 16) {
                
                if let selectorViewModel = viewModel.selector {
                    
                    OptionSelectorView(viewModel: selectorViewModel)
                        .frame(height: 24)
                        .padding(.leading, 20)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    switch viewModel.content {
                    case .placeholders:
                        
                        PlaceholderItemView()
                            .padding(.horizontal, 20)
                        
                    case let .items(items):
                            
                        HStack(spacing: 8) {
                                
                            ForEach(items) { itemViewModel in
                                    
                                CurrencyMetallItemView(viewModel: itemViewModel)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                        
                }
            }.frame(height: 124, alignment: .top)
        }
        
    }
}

extension MainSectionCurrencyMetallView.ViewModel {
        
    class ItemViewModel: ObservableObject, Identifiable {
        
        let id = UUID()
        let type: ItemType
        @Published
        var mainImg: (md5: String, img: Image?)
        let title: String
        let subtitle: String
        let action: () -> Void
        let topDashboard: DashboardViewModel
        let bottomDashboard: DashboardViewModel
        
        init(type: ItemType = .currency,
             mainImg: (md5: String, img: Image?),
             title: String, subtitle: String,
             action: @escaping () -> Void,
             topDashboard: DashboardViewModel,
             bottomDashboard: DashboardViewModel) {
            
            self.type = type
            self.mainImg = mainImg
            self.title = title
            self.subtitle = subtitle
            self.action = action
            self.topDashboard = topDashboard
            self.bottomDashboard = bottomDashboard
            
        }

        convenience init(currencyData: [CurrencyData],
                         item: CurrencyWalletData,
                         imageData: ImageData?,
                         itemAction: @escaping (Currency) -> () -> Void,
                         buyAction: @escaping (Currency) -> () -> Void,
                         sellAction: @escaping (Currency) -> () -> Void) {
            
            let imageData: (String, Image?) = (item.md5hash, imageData?.image)
            let currency: Currency = .init(description: item.code)
            
            
            let topText = Self.formattedText(item.rateSell * Double(item.currAmount))
            let bottomText = Self.formattedText(item.rateBuy * Double(item.currAmount))
            
            let rateSellDelta = item.rateSellDelta ?? 0
            let rateBuyDelta = item.rateBuyDelta ?? 0
            
            let subtitle = currencyData.first(where: { $0.code == item.code })?.shortName ?? ""
            
            let topDashboard: DashboardViewModel = .init(
                kindImage: Self.kindImage(rateSellDelta),
                valueText: topText,
                type: .buy,
                action: buyAction(currency) )
            
            let bottomDashboard: DashboardViewModel = .init(
                kindImage: Self.kindImage(rateBuyDelta),
                valueText: bottomText,
                type: .sell,
                action: sellAction(currency) )
            
            self.init(mainImg: imageData,
                      title: item.nameCw,
                      subtitle: subtitle,
                      action: itemAction(currency),
                      topDashboard: topDashboard,
                      bottomDashboard: bottomDashboard)
        }
        
        enum ItemType: String {
            case currency
            case metall
        }
        
        struct DashboardViewModel {
            let kindImage: KindImage
            let valueText: String
            let type: DashboardType
            let action: () -> Void
        }
        
        enum KindImage {
            case up
            case down
            case no
        }
        
        enum DashboardType: String {
            case buy = "Купить"
            case sell = "Продать"
        }
        
        static private func kindImage(_ rateDelta: Double) -> KindImage {
            rateDelta > 0 ? .up : rateDelta == 0 ? .no : .down
        }
        
        static private func formattedText(_ rate: Double) -> String {
            NumberFormatter.decimal(rate)
        }
    }
}

//MARK: - Views

extension MainSectionCurrencyMetallView {
    
    struct CurrencyMetallItemView: View {
        
        @ObservedObject var viewModel: ViewModel.ItemViewModel
        
        var body: some View {
            
            ZStack {
                Color.bgIconGrayLightest
                    .cornerRadius(12)
                    .frame(height: 124)
                
                HStack(spacing: 14) {
                    Button(action: viewModel.action, label: {
                        VStack(spacing: 15) {
                        
                            if let mainImage = viewModel.mainImg.img {
                            
                                mainImage
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            
                            } else {
                            
                                Circle()
                                    .fill(Color.mainColorsGrayMedium)
                                    .frame(width: 40, height: 40)
                                    .shimmering()
                            }
                        
                            VStack(spacing: 2) {
                        
                                Text(viewModel.title)
                                    .font(.textBodyMM14200())
                                    .foregroundColor(.textSecondary)
                            
                                Text(viewModel.subtitle)
                                    .font(.textBodySR12160())
                                    .foregroundColor(.textPlaceholder)
                                
                            }.lineLimit(1)
                        }
                    })
                    .frame(width: 65)
                    .padding(.leading, 15)
                    
                    //dashboards
                    VStack(alignment: .leading, spacing: 20) {
                        
                        DashboardView(viewModel: viewModel.topDashboard)
                        DashboardView(viewModel: viewModel.bottomDashboard)
                    }
                    .padding(.trailing, 18)
                }
            }
            
        }
    }
    
//PaceholderItemView
    
    struct PlaceholderItemView: View {
        
        var body: some View {
            
            HStack(spacing: 8) {
                
                ForEach(0..<3) { _ in
                    
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: 183, height: 124)
                        .foregroundColor(.mainColorsGray)
                        .shimmering()
                }
            }
        }
    }
    
}

extension MainSectionCurrencyMetallView.CurrencyMetallItemView {

    //MARK: DashboardView
        
    struct DashboardView: View {
        
        var viewModel: MainSectionCurrencyMetallView.ViewModel.ItemViewModel.DashboardViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                    
                HStack(spacing: 8) {
                        
                    switch viewModel.kindImage {
                    case .up: Image.ic16ArrowUp
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.systemColorActive)
                    
                    case .down: Image.ic16ArrowDown
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.iconRed)
                    
                    case .no: Spacer().frame(width: 12, height: 12)
                    }
                        
                    VStack(alignment: .leading, spacing: 2) {
                    
                        Text(viewModel.valueText)
                            .font(.textBodyMM14200())
                            .foregroundColor(.textSecondary)
                            
                        Text(viewModel.type.rawValue)
                            .font(.textBodySR12160())
                            .foregroundColor(.textPlaceholder)
                    }
                }
            }
        }
    }
}
    

//MARK: - Preview

struct CurrencyMetallView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            MainSectionCurrencyMetallView(viewModel: .sample)
                .previewLayout(.fixed(width: 375, height: 300))

            MainSectionCurrencyMetallView.PlaceholderItemView()
                .previewLayout(.fixed(width: 375, height: 300))
        }
    }
}



