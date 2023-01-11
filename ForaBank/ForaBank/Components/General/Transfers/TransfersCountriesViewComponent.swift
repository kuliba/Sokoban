//
//  TransfersCountriesViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 28.11.2022.
//  Refactor by Dmitry Martynov on 26.12.2022
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension TransfersCountriesView {
    
    class ViewModel: TransfersSectionViewModel, ObservableObject {
                
        override var type: TransfersSectionType { .countries }
        
        @Published var items: [TransfersItemViewModel]
        @Published var isCollapsed: Bool
                
        private let model: Model
        private var bindings = Set<AnyCancellable>()
                
        lazy var button: ButtonViewModel = .init { [weak self] in
            self?.action.send(TransfersCountriesAction.Button.Collapsed())
        }
        
        init(model: Model, items: [TransfersItemViewModel], isCollapsed: Bool = true) {
            
            self.model = model
            self.items = items
            self.isCollapsed = isCollapsed
        }
        
        convenience init(model: Model,
                         data: TransferAbroadResponseData.CountriesListData) {
            
            let countriesDict = model.countriesList.value
            let filterDict = data.codeList.flatMap { item in
                    countriesDict.filter { $0.code == item }
            }
            
            let images = model.images.value
            let filterImages = filterDict.reduce(into: [String: ImageData]()) { result, dict in
                  
                if let md5hash = dict.md5hash,
                   images.contains(where: { dict.md5hash == $0.key }) {
                    
                    result[md5hash] = images[md5hash]
                }
            }
            
            let items = Self.reduce(countriesCodeList: data.codeList,
                                    countriesDict: filterDict,
                                    images: filterImages)
            
            self.init(model: model, items: items, isCollapsed: true)
            self.title = data.title
            
            Self.downloadIconsIfNeeds(model, items: items)
            
            bind()
        }
        
        private func bind() {
            
            model.countriesList
                .combineLatest($isCollapsed)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] countriesDict, isCollapsed in
                    
                    var countriesCodeList = [String]()
                    
                    if isCollapsed {
                        countriesCodeList = model.transferAbroad.value?.main.countriesList.codeList ?? []
                        self.button.title = "Смотреть все страны"
                        
                    } else {
                        countriesCodeList = model.transferAbroad.value?.countriesDetailList.codeList ?? []
                        self.button.title = "Скрыть все страны"
                    }
                    
                    let filterDict = countriesCodeList.flatMap { item in
                        countriesDict.filter { $0.code == item }
                    }
                    
                    let images = model.images.value
                    let filterImages = filterDict.reduce(into: [String: ImageData]()) { result, dict in
                          
                        if let md5hash = dict.md5hash,
                           images.contains(where: { dict.md5hash == $0.key }) {
                            
                            result[md5hash] = images[md5hash]
                        }
                    }
                    
                    withAnimation {
                        self.items = Self.reduce(countriesCodeList: countriesCodeList,
                                                 countriesDict: filterDict,
                                                 images: filterImages)
                    }

                    Self.downloadIconsIfNeeds(model, items: items)
                    
                }.store(in: &bindings)
            
            model.images
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] images in
                    
                    for item in self.items {
                        
                        if case let .placeholder(md5hash) = item.icon,
                           let md5hash = md5hash,
                           let image = images[md5hash]?.image {
                            
                            item.icon = .icon(image)
                        }
                    }
                    
                }.store(in: &bindings)
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                        
                    case _ as TransfersCountriesAction.Button.Collapsed:
                        isCollapsed.toggle()
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}
        
extension TransfersCountriesView.ViewModel {
            
    static func reduce(countriesCodeList: [String],
                       countriesDict: [CountryData],
                       images: [String: ImageData]) -> [TransfersItemViewModel] {
        
        countriesCodeList.map { item in
            
            if let country = countriesDict.first(where: { $0.code == item }) {
                
                var icon: TransfersItemViewModel.IconState = .placeholder(country.md5hash)
                
                if let md5hash = country.md5hash,
                   let image = images[md5hash]?.image {
                    
                    icon = .icon(image)
                }
                
                return .init(title: country.name.capitalized,
                             countryCode: item,
                             icon: icon)
            } else {
                
                return .init(title: item,
                             countryCode: item,
                             icon: .placeholder(nil))
            }
        }
    }
            
    static func downloadIconsIfNeeds(_ model: Model, items: [TransfersItemViewModel]) {
        
        var imagesIds = [String]()
        
        for item in items {
            if case let .placeholder(md5hash) = item.icon,
               let md5hash = md5hash {
                
                imagesIds.append(md5hash)
            }
        }
        
        if !imagesIds.isEmpty {
            model.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: imagesIds))
        }
    }
}

extension TransfersCountriesView.ViewModel {

    class ButtonViewModel: ObservableObject {

        @Published var title: String

        let icon: Image
        let action: () -> Void
        
        init(title: String, icon: Image, action: @escaping () -> Void) {
            
            self.title = title
            self.icon = icon
            self.action = action
        }
        
        convenience init(_ action: @escaping () -> Void) {
            
            self.init(
                title: "Смотреть все страны",
                icon: .ic24MoreHorizontal,
                action: action
            )
        }
    }
}

// MARK: - Action

extension TransfersCountriesView.ViewModel {

    enum TransfersCountriesAction {
        
        enum Button {
            
            struct Collapsed: Action {}
        }
    }
}

// MARK: - View

struct TransfersCountriesView: View {
    
    @ObservedObject var viewModel: TransfersCountriesView.ViewModel
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.mainColorsGrayLightest)
            
            VStack(alignment: .leading, spacing: 24) {

                Text(viewModel.title)
                    .font(.textH3SB18240())
                    .foregroundColor(.mainColorsBlack)
                
                ForEach(viewModel.items) { item in
                    TransfersItemView(viewModel: item)
                }
                
                ButtonView(viewModel: viewModel.button)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
    }
}

extension TransfersCountriesView {
    
    struct TransfersItemView: View {
        
        @ObservedObject var viewModel: TransfersItemViewModel
        
        var body: some View {
            
            HStack(spacing: 20) {
                
                switch viewModel.icon {
                case let .icon(image):
                    
                    image
                        .resizable()
                        .cornerRadius(28)
                        .frame(width: 40, height: 40)
                
                case .placeholder:
                    
                    ZStack {
                        
                        Circle()
                            .foregroundColor(.mainColorsGrayMedium.opacity(0.4))
                            .frame(width: 40, height: 40)
                        
                        Text(viewModel.countryCode)
                            .font(.textBodySR12160())
                            .foregroundColor(.mainColorsGray)
                    }.shimmering(active: true, bounce: false)
                }

                Text(viewModel.title)
                    .font(.textH4M16240())
                    .foregroundColor(.mainColorsBlack)
            }
        }
    }
    
    struct ButtonView: View {
        
        @ObservedObject var viewModel: TransfersCountriesView.ViewModel.ButtonViewModel
        
        var body: some View {
            
            Button(action: viewModel.action) {
                
                HStack(spacing: 20) {
                    
                    ZStack(alignment: .center) {
                        
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.mainColorsWhite)
                        
                        viewModel.icon
                            .renderingMode(.original)
                    }
                    
                    Text(viewModel.title)
                        .font(.textH4M16240())
                        .foregroundColor(.mainColorsBlack)
                }
            }
        }
    }
}



// MARK: - Preview

struct TransfersCountriesView_Previews: PreviewProvider {
    
    static var previews: some View {
        TransfersCountriesView(viewModel: .init(model: .emptyMock,
                                                items: TransfersDirectionsView.ViewModel.sampleItems))
            .previewLayout(.sizeThatFits)
            .fixedSize(horizontal: false, vertical: true)
            .padding(8)
    }
}
