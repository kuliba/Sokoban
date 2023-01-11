//
//  TransfersDirectionsViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 24.11.2022.
//  Refactor by Dmitry Martynov on 26.12.2022
//

import SwiftUI
import Combine
import Shimmer

// MARK: - ViewModel

extension TransfersDirectionsView {
    
    class ViewModel: TransfersSectionViewModel, ObservableObject {
        
        override var type: TransfersSectionType { .directions }
        
        @Published var items: [TransfersItemViewModel]
        
        private var bindings = Set<AnyCancellable>()
        private let model: Model
        
        init(model: Model, items: [TransfersItemViewModel]) {
            
            self.model = model
            self.items = items
        }
        
        convenience init(model: Model, data: TransferAbroadResponseData.DirectionTransferData) {
            
            let countriesDict = model.countriesList.value
            let filterDict = data.countriesList.flatMap { item in
                countriesDict.filter { $0.code == item.code }
            }
            let items = Self.reduce(direction: data, countriesDict: filterDict)
            
            self.init(model: model, items: items)
            
            Self.downloadIconsIfNeeds(model, items: items)
            self.title = data.title
            bind()
        }
        
        private func bind() {
            
            model.countriesList
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] countriesDict in
                    
                    guard let directions = model.transferAbroad.value?.main.directions
                    else { return }
                    
                    let filter = directions.countriesList.flatMap { item in
                        countriesDict.filter { $0.code == item.code }
                    }
                    
                    self.items = Self.reduce(direction: directions, countriesDict: filter)

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
            
            $items
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] items in
                    
                    guard !items.isEmpty else { return }
                    bind(items)
                    
                }.store(in: &bindings)
        }
        
        private func bind(_ items: [TransfersItemViewModel]) {
            
            for item in items {
                
                item.action
                    .receive(on: DispatchQueue.main)
                    .sink { action in
                        
                        switch action {
                        case let payload as TransfersItemAction.Item.Tap:
                            self.action.send(TransfersSectionAction.Direction.Tap(countryCode: payload.countryCode))
                            
                        default:
                            break
                        }
                        
                    }.store(in: &bindings)
            }
        }
    }
}

class TransfersItemViewModel: ObservableObject, Identifiable {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    var id: String { countryCode }
    @Published var title: String
    let rateTitle: String
    let countryCode: String
    @Published var icon: IconState
    
    lazy var onAction: () -> Void = { [weak self] in
        
        guard let self = self else { return }
        self.action.send(TransfersItemAction.Item.Tap(countryCode: self.countryCode))
    }
    
    init(title: String, rateTitle: String = "", countryCode: String, icon: IconState) {
        
        self.title = title
        self.rateTitle = rateTitle
        self.countryCode = countryCode
        self.icon = icon
    }
    
    enum IconState {
        case placeholder(String?)
        case icon(Image)
    }
}

extension TransfersDirectionsView.ViewModel {
    
    static func reduce(direction: TransferAbroadResponseData.DirectionTransferData,
                       countriesDict: [CountryData]) -> [TransfersItemViewModel] {
        
        direction.countriesList.map { item in
            
            if let country = countriesDict.first(where: { $0.code == item.code }) {
                
                return .init(title: country.name.capitalized,
                             rateTitle: item.rate,
                             countryCode: item.code,
                             icon: .placeholder(country.md5hash))
            } else {
                
                return .init(title: item.code,
                             rateTitle: item.rate,
                             countryCode: item.code,
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

// MARK: - View

struct TransfersDirectionsView: View {
    
    @ObservedObject var viewModel: TransfersDirectionsView.ViewModel
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.mainColorsGrayLightest)
            
            VStack(alignment: .leading, spacing: 16) {

                HStack {
                    
                    Text(viewModel.title)
                        .font(.textH3SB18240())
                        .foregroundColor(.mainColorsBlack)
                    
                    Spacer()
                    
                }.padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {

                    HStack {

                        ForEach(viewModel.items) { item in
                            TransfersItemView(viewModel: item)
                        }

                    }.padding(.horizontal, 8)
                }
            }
        
        }.frame(height: 148)
    }
}

extension TransfersDirectionsView {
    
    struct TransfersItemView: View {
        
        @ObservedObject var viewModel: TransfersItemViewModel
        
        var body: some View {
            
            Button(action: viewModel.onAction) {
                
                ZStack {
                                 
                    VStack(spacing: 8) {
                         
                        switch viewModel.icon {
                        case let .icon(image):
                            
                            image
                                .resizable()
                                .cornerRadius(28)
                                .frame(width: 56, height: 56)
                        
                        case .placeholder:
                            
                            ZStack {
                                
                                Circle()
                                    .foregroundColor(.mainColorsGrayMedium.opacity(0.4))
                                    .frame(width: 56, height: 56)
                                .shimmering(active: true, bounce: false)
                                
                                Text(viewModel.countryCode)
                                    .font(.textBodySR12160())
                                    .foregroundColor(.mainColorsGray)
                            }
                        }
                        
                        Text(viewModel.title)
                            .font(.textBodySR12160())
                            .foregroundColor(.mainColorsBlack)
                    }
                    
                    HStack {
                        
                        Spacer()
                        
                        VStack {
                            
                            HStack(alignment: .center) {
                                
                                Text(viewModel.rateTitle)
                                    .font(.textBodyXSSB11140())
                                    .foregroundColor(.mainColorsGray)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                            }
                            .background(Color.mainColorsWhite)
                            .cornerRadius(10)
                            
                            Spacer()
                        }
                        
                    }.frame(width: 72)
                
                }.fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Action

enum TransfersItemAction {
    
    enum Item {
        
        struct Tap: Action {
            
            let countryCode: String
        }
    }
}

// MARK: - Content

extension TransfersDirectionsView.ViewModel {
    
    static let sampleItems: [TransfersItemViewModel] = [
        .init(title: "Армения",
              rateTitle: "1%",
              countryCode: "AM",
              icon: .placeholder(nil)),
        .init(title: "Беларусь",
              rateTitle: "1,5%",
              countryCode: "BR",
              icon: .icon(Image("Belarus Flag"))),
        .init(title: "Грузия",
              rateTitle: "1,5%",
              countryCode: "GR",
              icon: .icon(Image("Georgia Flag")))]
}

// MARK: - Preview

struct TransfersDirectionsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TransfersDirectionsView(viewModel: .init(
            model: .emptyMock,
            items: TransfersDirectionsView.ViewModel.sampleItems))
        .previewLayout(.sizeThatFits)
        .padding(8)
    }
}
