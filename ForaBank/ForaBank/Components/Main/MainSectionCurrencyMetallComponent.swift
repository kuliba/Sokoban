//
//  MainSectionCurrencyMetallComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 04.07.2022.
//

import Foundation
import SwiftUI
import Combine
import Shimmer

//MARK: - ViewModel

extension MainSectionCurrencyMetallView {
    
    class ViewModel: MainSectionCollapsableViewModel {

        override var type: MainSectionType { .currencyMetall }
        
        @Published var content: Content
        @Published var selector: OptionSelectorView.ViewModel?
        
        enum Content {
            
            case placeholders
            case items([CurrencyMetallItemView.ViewModel])
        }
        
        private var items: [CurrencyMetallItemView.ViewModel] = []

        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        internal init(content: Content, selector: OptionSelectorView.ViewModel?, model: Model = .emptyMock, isCollapsed: Bool) {
            
            self.content = content
            self.selector = selector
            self.model = model
            super.init(isCollapsed: isCollapsed)
        }
        
        init(_ model: Model) {
            
            self.content = .placeholders
            self.selector = nil
            self.model = model
            super.init(isCollapsed: false)
            
            bind()
        }
        
        convenience init() {
            
            self.init(content: .items([]), selector: nil, isCollapsed: false)
            self.content = .items(self.sampleItems)
        }
        
        
        lazy var sampleItems: [CurrencyMetallItemView.ViewModel] =
           
            [.init(type: .currency,
                   mainImg: Image("Flag USD"),
                   title: "USD",
                   subtitle: "Доллар",
                   topDashboard: .init(kindImage: .down, valueText: "68,19", type: .buy, action: { [weak self] in
                                    self?.action.send(MainSectionViewModelAction
                                                        .CurrencyMetall
                                                        .ItemDashboardDidTapped.Buy(itemData: "USD"))}),
                   bottomDashboard: .init(kindImage: .up, valueText: "69,45", type: .sell, action: { [weak self] in
                                    self?.action.send(MainSectionViewModelAction
                                                        .CurrencyMetall
                                                        .ItemDashboardDidTapped.Sell(itemData: "USD"))} )),
             .init(type: .currency,
                   mainImg: Image("Flag EUR"),
                   title: "EUR",
                   subtitle: "Евро",
                   topDashboard: .init(kindImage: .up, valueText: "69,23", type: .buy, action: { [weak self] in
                                    self?.action.send(MainSectionViewModelAction
                                                        .CurrencyMetall
                                                        .ItemDashboardDidTapped.Buy(itemData: "EUR"))}),
                   bottomDashboard: .init(kindImage: .up, valueText: "70,01", type: .sell, action: { [weak self] in
                                    self?.action.send(MainSectionViewModelAction
                                                        .CurrencyMetall
                                                        .ItemDashboardDidTapped.Sell(itemData: "EUR"))})),
             .init(type: .currency,
                   mainImg: Image("Flag CHF"),
                   title: "CHF",
                   subtitle: "Франк",
                   topDashboard: .init(kindImage: .down, valueText: "64,89", type: .buy, action: { [weak self] in
                                    self?.action.send(MainSectionViewModelAction
                                                        .CurrencyMetall
                                                        .ItemDashboardDidTapped.Buy(itemData: "CHF"))}),
                   bottomDashboard: .init(kindImage: .up, valueText: "65,09", type: .sell, action: { [weak self] in
                                    self?.action.send(MainSectionViewModelAction
                                                        .CurrencyMetall
                                                        .ItemDashboardDidTapped.Sell(itemData: "CHF"))}))]
        
//MARK: Bindings
        
        private func bind() {
            //TODO:
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
                        
                        PlaceholdersView()
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

extension MainSectionCurrencyMetallView.CurrencyMetallItemView {
        
    class ViewModel: ObservableObject, Identifiable {
        
        let id = UUID()
        let type: ItemType
        let mainImg: Image
        let title: String
        let subtitle: String
        let topDashboard: DashboardViewModel
        let bottomDashboard: DashboardViewModel
        
        init(type: ItemType, mainImg: Image, title: String, subtitle: String,
             topDashboard: DashboardViewModel,
             bottomDashboard: DashboardViewModel) {
            
            self.type = type
            self.mainImg = mainImg
            self.title = title
            self.subtitle = subtitle
            self.topDashboard = topDashboard
            self.bottomDashboard = bottomDashboard
            
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
        }
        
        enum DashboardType: String {
            case buy = "Купить"
            case sell = "Продать"
        }
        
    }
}

//MARK: - Views

extension MainSectionCurrencyMetallView {
    
    struct CurrencyMetallItemView: View {
        
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            
            ZStack {
                Color.bGIconGrayLightest
                    .cornerRadius(12)
                    .frame(height: 124)
                
                HStack(spacing: 14) {
                    
                    VStack(spacing: 15) {
                        
                        viewModel.mainImg
                            .resizable()
                            .frame(width: 40, height: 40)
                        
                        VStack(spacing: 2) {
                        
                            Text(viewModel.title)
                                .font(.textBodyMM14200())
                                .foregroundColor(.textSecondary)
                            
                            Text(viewModel.subtitle)
                                .font(.textBodySR12160())
                                .foregroundColor(.textPlaceholder)
                                
                        }.lineLimit(1)
                    }
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
        
    //MARK: DashboardView
        
    struct DashboardView: View {
        
        var viewModel: CurrencyMetallItemView.ViewModel.DashboardViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                    
                HStack(spacing: 8) {
                        
                    switch viewModel.kindImage {
                    case .up: Image.ic16ArrowUp
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.systemColorActive)
                    
                    case.down: Image.ic16ArrowDown
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.iconRed)
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
    
    struct PlaceholdersView: View {
        
        var body: some View {
            
            HStack(spacing: 8) {
                
                ForEach(0..<3) { _ in
                    
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: 183, height: 124)
                        .foregroundColor(.mainColorsGray)
                        .shimmering(active: true, bounce: false)
                }
            }
        }
    }
    
}

//MARK: - Preview

struct CurrencyMetallView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            MainSectionCurrencyMetallView(viewModel: .sample )
                .previewLayout(.fixed(width: 375, height: 300))

            MainSectionCurrencyMetallView.PlaceholdersView()
                .previewLayout(.fixed(width: 375, height: 300))
        }
    }
}

//MARK: - Preview Content

extension MainSectionCurrencyMetallView.ViewModel {

    static let sample = MainSectionCurrencyMetallView.ViewModel
        .init(
           content: .items(
               [.init(type: .currency,
                      mainImg: Image("Flag USD"),
                      title: "USD",
                      subtitle: "Доллар",
                      topDashboard: .init(kindImage: .down, valueText: "68,19", type: .buy, action: {}),
                      bottomDashboard: .init(kindImage: .up, valueText: "69,45", type: .sell, action: {} )),
               .init(type: .currency,
                     mainImg: Image("Flag EUR"),
                     title: "EUR",
                     subtitle: "Евро",
                     topDashboard: .init(kindImage: .up, valueText: "69,23", type: .buy, action: {}),
                     bottomDashboard: .init(kindImage: .up, valueText: "70,01", type: .sell, action: {})),
               .init(type: .currency,
                     mainImg: Image("Flag CHF"),
                     title: "CHF",
                     subtitle: "Франк",
                     topDashboard: .init(kindImage: .down, valueText: "64,89", type: .buy, action: {}),
                     bottomDashboard: .init(kindImage: .up, valueText: "65,09", type: .sell, action: {}))]),
           selector: nil,
           isCollapsed: false)

}




