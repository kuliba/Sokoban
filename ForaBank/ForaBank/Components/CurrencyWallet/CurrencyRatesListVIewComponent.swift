//
//  CurrencyBigListVIewComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 16.07.2022.
//

import SwiftUI
import Combine
import Shimmer

//MARK: - ViewModel

extension CurrencyRatesListView {
    
    class ViewModel: ObservableObject {
        
        @Published var content: Content
        @Published var items: [ItemViewModel]
        let titleList: String
        
        enum Content {
            
            case placeholders
            case items([ItemViewModel])
        }

        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(titleList: String,
             content: Content,
             items: [ItemViewModel] = [],
             model: Model = .emptyMock) {
            
            self.titleList = titleList
            self.content = content
            self.items = items
            self.model = model
        }
        
        init(_ model: Model) {
            
            self.titleList = "Курсы валют"
            self.content = .placeholders
            self.model = model
            self.items = []
            
            bind()
        }
        
        // bindings
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
                    let dict = data.1
                
                    let result = reduce(list: list, dict: dict)
                    self.items = result.items
                
                    if !result.imagesMd5ToUpload.isEmpty {
                        model.action.send(ModelAction.Dictionary.DownloadImages
                                        .Request(imagesIds: result.imagesMd5ToUpload))
                    }
            }
            .store(in: &bindings)
        
            $items
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] items in

                    updateContent(model.dictionariesUpdating.value)

                }.store(in: &bindings)

            model.images
                .receive(on: DispatchQueue.main)
                .sink { [unowned self ] images in
                    let emptyImg = self.items.filter { $0.mainImage.img == nil }
                
                    guard !emptyImg.isEmpty else { return }
                    withAnimation {
                        self.items.forEach { $0.mainImage.img = images[$0.mainImage.md5]?.image }
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
        
        // reduce Items
        private func reduce(list: [CurrencyWalletData],
                            dict: [CurrencyData]) -> (items: [ItemViewModel],
                                                      imagesMd5ToUpload: [String]) {
                    
            let items = list.map { item -> ItemViewModel in
                
                let rateSellDelta = item.rateSellDelta ?? 0
                let rateBuyDelta = item.rateBuyDelta ?? 0
                
                return ItemViewModel(id: item.code,
                              mainImage: (item.md5hash, model.images.value[item.md5hash]?.image),
                              nameCurrency: dict.first(where: { $0.code == item.code })?.shortName ?? "",
                              buySection: .init(kindImage: rateSellDelta > 0 ? .up
                                                         : rateSellDelta == 0 ? nil : .down,
                                                  valueText: String(item.rateSell),
                                                  type: .buy),
                              sellSection: .init(kindImage: rateBuyDelta > 0 ? .up
                                                          : rateBuyDelta == 0 ? nil : .down,
                                                     valueText: String(item.rateBuy),
                                                     type: .sell ))
            }
                    
            let imagesMd5ToUpload = items.filter { $0.mainImage.img == nil }
                                         .map { $0.mainImage.md5 }
                    
            return (items, imagesMd5ToUpload)
        }
        
    }
}

extension CurrencyRatesListView.ViewModel {
        
    class ItemViewModel: ObservableObject, Identifiable {
        
        let id: String

        @Published
        var mainImage: (md5: String, img: Image?)
        let nameCurrency: String
        let buySection: SectionItemViewModel
        let sellSection: SectionItemViewModel
        
        init(id: String,
             mainImage: (md5: String, img: Image?),
             nameCurrency: String,
             buySection: SectionItemViewModel,
             sellSection: SectionItemViewModel) {
            
            self.id = id
            self.mainImage = mainImage
            self.nameCurrency = nameCurrency
            self.buySection = buySection
            self.sellSection = sellSection
        }
        
        struct SectionItemViewModel {
            let kindImage: KindImage?
            let valueText: String
            let type: SectionType
        }
        
        enum KindImage {
            case up
            case down
        }
        
        enum SectionType: String {
            case buy = "Купить"
            case sell = "Продать"
        }
        
    }
}

//MARK: - View

struct CurrencyRatesListView: View {
    
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            Text(viewModel.titleList)
                .font(.textH3M18240())
                .foregroundColor(.textSecondary)
                .padding(.horizontal, 20)
                .padding(.top, 5)
                .padding(.bottom, 10)
            
            switch viewModel.content {
            case .placeholders:
                        
                PlaceholderItemView()
                    .padding(.horizontal, 20)
                        
            case let .items(items):
                        
                ScrollView {
                    VStack {
                                
                        ForEach(items) { itemViewModel in
                                    
                            CurrencyItemView(viewModel: itemViewModel)
                        }
                        
                    }.padding(.horizontal, 20)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.bottom, 48)
    }
}

//MARK: - Views

extension CurrencyRatesListView {
    
    struct CurrencyItemView: View {
        
        @ObservedObject var viewModel: ViewModel.ItemViewModel
        
        var body: some View {
            
            ZStack {
                Color.bGIconGrayLightest
                    .cornerRadius(12)
                    .frame(height: 72)
                
                HStack(spacing: 14) {
                    
                        HStack(spacing: 12) {
                        
                            if let mainImage = viewModel.mainImage.img {
                            
                                mainImage
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            
                            } else {
                            
                                Circle()
                                    .fill(Color.mainColorsGrayMedium)
                                    .frame(width: 26, height: 26)
                                    .shimmering(active: true, bounce: false)
                            }
                        
                            VStack(alignment: .leading, spacing: 2) {
                        
                                Text(viewModel.id)
                                    .font(.textBodyMM14200())
                                    .foregroundColor(.textSecondary)
                            
                                Text(viewModel.nameCurrency)
                                    .font(.textBodySR12160())
                                    .foregroundColor(.textPlaceholder)
                                
                            }.lineLimit(1)
                            
                        }.padding()
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        
                        SectionItemView(viewModel: viewModel.buySection)
                        SectionItemView(viewModel: viewModel.sellSection)
                    }
                    .padding(.trailing, 18)
                }
            }
        }
    }
    
//PaceholderItemView
    
    struct PlaceholderItemView: View {
        
        var body: some View {
            
            VStack(spacing: 8) {
                
                ForEach(0..<4) { _ in
                    
                    Color.mainColorsGrayLightest
                        .cornerRadius(12)
                        .frame(height: 72)
                        .padding(.vertical, 3)
                        .shimmering(active: true, bounce: false)
                }
                
                Spacer()
                
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

//MARK: SectionItemView

extension CurrencyRatesListView.CurrencyItemView {
        
    struct SectionItemView: View {
        
        var viewModel: CurrencyRatesListView.ViewModel.ItemViewModel.SectionItemViewModel
        var body: some View {
                    
            HStack(spacing: 8) {
                    
                if let kindImage = viewModel.kindImage {
                  
                    switch kindImage {
                    case .up: Image.ic16ArrowUp
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.systemColorActive)
                    
                    case .down: Image.ic16ArrowDown
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.iconRed)
                    }
                
                } else {
                    
                    Spacer().frame(width: 12, height: 12)
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

//MARK: - Preview

struct CurrencyRatesListView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            CurrencyRatesListView(viewModel: .sample)
                .previewLayout(.sizeThatFits)
                .fixedSize()
                .padding(.vertical, 20)

            CurrencyRatesListView.PlaceholderItemView()
                .frame(width: 375)
                .previewLayout(.sizeThatFits)
                .fixedSize()
                .padding()
        }
    }
}
