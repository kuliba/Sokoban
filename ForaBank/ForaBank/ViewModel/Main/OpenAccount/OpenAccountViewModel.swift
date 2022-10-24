//
//  OpenAccountViewModel.swift
//  BottomSheetView
//
//  Created by Pavel Samsonov on 31.05.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

class OpenAccountViewModel: ObservableObject {

    @Published var item: OpenAccountItemViewModel
    @Published var items: [OpenAccountItemViewModel]
    @Published var currency: Currency
    @Published var pagerViewModel: PagerScrollViewModel

    let model: Model
    let style: Style
    let closeAction: () -> Void

    private var bindings = Set<AnyCancellable>()

    var currentItem: OpenAccountItemViewModel? {
        items[safe: pagerViewModel.currentIndex]
    }

    var heightContent: CGFloat {

        if items.count > 1 {
            return 235
        } else {
            return 225
        }
    }
    
    enum Style {
        
        case openAccount
        case currencyWallet
    }

    init(model: Model,
         item: OpenAccountItemViewModel,
         items: [OpenAccountItemViewModel],
         currency: Currency,
         pagerViewModel: PagerScrollViewModel,
         style: Style = .openAccount,
         closeAction: @escaping () -> Void = {}) {

        self.model = model
        self.item = item
        self.items = items
        self.currency = currency
        self.pagerViewModel = pagerViewModel
        self.style = style
        self.closeAction = closeAction
    }
    
    convenience init?(_ model: Model, products: [OpenAccountProductData], closeAction: @escaping () -> Void = {}) {
        
        let currencyData = model.currencyList.value
        let imageData = model.images.value
        
        let items = Self.reduce(products: products, currencyData: currencyData, images: imageData)
        
        guard let item = items.first, let product = products.first else {
            return nil
        }
        
        self.init(model: model, item: item, items: items, currency: product.currency, pagerViewModel: .init(items.count), style: .openAccount, closeAction: closeAction)

        if let currentItem = currentItem {
            self.item = currentItem
        }

        bind()
        updateImagesIfNeeds(products, images: imageData)
    }
    
    convenience init?(_ model: Model, product: OpenAccountProductData?, closeAction: @escaping () -> Void = {}) {
        
        guard let product = product, product.open == false else {
            return nil
        }
        
        let currencyData = model.currencyList.value
        let imageData = model.images.value
        
        let items = Self.reduce(products: [product], currencyData: currencyData, images: imageData)
        
        guard let item = items.first else {
            return nil
        }
        
        self.init(model: model, item: item, items: items, currency: product.currency, pagerViewModel: .init(items.count), style: .currencyWallet, closeAction: closeAction)

        if let currentItem = currentItem {
            self.item = currentItem
        }

        bind()
        updateImagesIfNeeds([product], images: imageData)
    }

    private func bind() {

        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in

                switch action {
                case _ as ModelAction.Account.PrepareOpenAccount.Request:
                    pagerViewModel.isUserInteractionEnabled = false

                case let payload as ModelAction.Account.PrepareOpenAccount.Response:
                    
                    switch payload {
                    case .complete:
                        
                        setItemsHidden(true)
                        
                    case .failed:
                        
                        setItemsHidden(false)
                        pagerViewModel.isUserInteractionEnabled = true
                    }
                    
                case let payload as ModelAction.Account.MakeOpenAccount.Response:
                    
                    switch payload {
                    case .complete:
                        
                        setItemsHidden(false)
                        pagerViewModel.isUserInteractionEnabled = true
                        
                    case .failed(error: let error):
                        
                        let rawValue = model.accountRawResponse(error: error)
                        
                        if rawValue == .exhaust {
                         
                            setItemsHidden(false)
                            pagerViewModel.isUserInteractionEnabled = true
                        }
                    }

                default:
                    break
                }
            }.store(in: &bindings)
        
        model.images
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] images in
                
                let items = self.items.filter { $0.card.icon == nil }
                
                for item in items {
                    
                    if let imageData = images[item.id] {
                        item.card.icon = imageData.image
                    }
                }
                
            }.store(in: &bindings)

        pagerViewModel.$currentIndex
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] currentIndex in

                guard let currentItem = currentItem else {
                    return
                }

                guard currency.description != currentItem.currency else {
                    return
                }

                item = currentItem
                currency = .init(description: currentItem.currency)

            }.store(in: &bindings)
    }
    
    private func updateImagesIfNeeds(_ products: [OpenAccountProductData], images: [String: ImageData]) {
        
        let imagesIds = Model.reduce(products, images: images)
        
        if imagesIds.isEmpty == false {
            model.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: imagesIds))
        }
    }

    private func setItemsHidden(_ isHidden: Bool) {
        
        guard let currentItem = currentItem else {
            return
        }
        
        items
            .filter { $0.id != currentItem.id }
            .forEach { item in
                item.isHidden = isHidden
            }
    }
}

extension OpenAccountViewModel: Hashable {

    func hash(into hasher: inout Hasher) {

        hasher.combine(item.id)
    }

    static func == (lhs: OpenAccountViewModel, rhs: OpenAccountViewModel) -> Bool {

        lhs.item.id == rhs.item.id
    }
}

// MARK: - Reducer

extension OpenAccountViewModel {

    static func reduce(products: [OpenAccountProductData], currencyData: [CurrencyData], images: [String: ImageData]) -> [OpenAccountItemViewModel] {

        return products.compactMap { item in
            
            let currencyItem = currencyData.first(where: { $0.code == item.currency.description })
            
            guard let currencyItem = currencyItem, let currencySymbol = currencyItem.currencySymbol else {
                return nil
            }
            
            let options = item.txtConditionList.map { option -> OpenAccountOptionViewModel in

                let colorType: OpenAccountOptionViewModel.ColorType = .init(rawValue: option.type.rawValue) ?? .green

                return OpenAccountOptionViewModel(
                    title: option.name,
                    description: option.descriptoin,
                    colorType: colorType)
            }

            return OpenAccountItemViewModel(
                id: item.designMd5hash,
                currency: item.currency.description,
                conditionLinkURL: item.detailedConditionUrl,
                ratesLinkURL: item.detailedRatesUrl,
                currencyCode: item.currencyCode,
                header: .init(title: item.currencyAccount, detailTitle: item.breakdownAccount),
                card: .init(currrentAccountTitle: item.accountType, currencySymbol: currencySymbol, icon: images[item.designMd5hash]?.image),
                options: options,
                isAccountOpen: item.open)
        }
    }
}

//MARK: - Preview Content

extension OpenAccountViewModel {

    static let sample = OpenAccountViewModel(
        model: .productsMock,
        item: .sample,
        items: [
            .init(
                currency: "RUB",
                conditionLinkURL: "https://www.forabank.ru/dkbo/dkbo.pdf",
                ratesLinkURL: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_tarifi.pdf",
                currencyCode: 810,
                header: .init(
                    title: "RUB счет",
                    detailTitle: "Счет в российских рублях"),
                card: .init(
                    numberCard: "4444555566664345",
                    currencySymbol: "₽",
                    icon: .init("RUB")),
                options: [
                    .init(title: "Открытие"),
                    .init(title: "Обслуживание")
                ],
                isAccountOpen: false),
            .init(
                currency: "USD",
                conditionLinkURL: "https://www.forabank.ru/dkbo/dkbo.pdf",
                ratesLinkURL: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_tarifi.pdf",
                currencyCode: 840,
                header: .init(
                    title: "USD счет",
                    detailTitle: "Счет в долларах США"),
                card: .init(
                    numberCard: "4444555566664346",
                    currencySymbol: "$",
                    icon: .init("USD")),
                options: [
                    .init(title: "Открытие"),
                    .init(title: "Обслуживание")
                ],
                isAccountOpen: false),
            .init(
                currency: "EUR",
                conditionLinkURL: "https://www.forabank.ru/dkbo/dkbo.pdf",
                ratesLinkURL: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_tarifi.pdf",
                currencyCode: 978,
                header: .init(
                    title: "EUR счет",
                    detailTitle: "Счет в евро"),
                card: .init(
                    numberCard: "4444555566664347",
                    currencySymbol: "€",
                    icon: .init("EUR")),
                options: [
                    .init(title: "Открытие"),
                    .init(title: "Обслуживание")
                ],
                isAccountOpen: true),
            .init(
                currency: "GBP",
                conditionLinkURL: "https://www.forabank.ru/dkbo/dkbo.pdf",
                ratesLinkURL: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_tarifi.pdf",
                currencyCode: 826,
                header: .init(
                    title: "GBP счет",
                    detailTitle: "Счет в Британских фунтах"),
                card: .init(
                    numberCard: "4444555566664348",
                    currencySymbol: "£",
                    icon: .init("GBP")),
                options: [
                    .init(title: "Открытие"),
                    .init(title: "Обслуживание")
                ],
                isAccountOpen: true),
            .init(
                currency: "CHF",
                conditionLinkURL: "https://www.forabank.ru/dkbo/dkbo.pdf",
                ratesLinkURL: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_tarifi.pdf",
                currencyCode: 756,
                header: .init(
                    title: "CHF счет",
                    detailTitle: "Счет в Швейцарских франках"),
                card: .init(
                    numberCard: "4444555566664349",
                    currencySymbol: "₣",
                    icon: .init("CHF")),
                options: [
                    .init(title: "Открытие"),
                    .init(title: "Обслуживание")
                ],
                isAccountOpen: false)
        ],
        currency: .usd,
        pagerViewModel: .init(5))
}
