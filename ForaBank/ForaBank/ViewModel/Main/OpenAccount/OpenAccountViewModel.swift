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
    @Published var currencyName: String

    let model: Model

    private var bindings = Set<AnyCancellable>()

    var currentItem: OpenAccountItemViewModel? {
        items[safe: pagerViewModel.currentIndex]
    }

    let pagerViewModel: PagerContentViewModel

    init(model: Model,
         items: [OpenAccountItemViewModel],
         currencyName: String = "") {

        self.model = model
        self.item = .empty
        self.items = items
        self.currencyName = currencyName

        pagerViewModel = .init(pageCount: items.count)

        if let currentItem = currentItem {
            self.item = currentItem
        }

        bind()
    }

    private func bind() {

        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in

                switch action {
                case _ as ModelAction.Account.MakeOpenAccount.Request:
                    pagerViewModel.isUserInteractionEnabled = false

                case _ as ModelAction.Account.MakeOpenAccount.Response:
                    pagerViewModel.isUserInteractionEnabled = true

                default:
                    break
                }
            }.store(in: &bindings)

        pagerViewModel.$currentIndex
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] currentIndex in

                guard let currentItem = currentItem else {
                    return
                }

                let currencyType = currentItem.currencyType

                guard currencyName != currencyType.rawValue else {
                    return
                }

                item = currentItem
                currencyName = currencyType.rawValue

            }.store(in: &bindings)
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

    static func reduce(products: [OpenAccountProductData]) -> [OpenAccountItemViewModel] {

        return products.compactMap { item in

            guard let currencyType: OpenAccountСurrencyType = .init(
                rawValue: item.currency.rawValue) else {
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
                currencyCode: item.currencyCode,
                conditionLinkURL: item.detailedConditionUrl,
                ratesLinkURL: item.detailedRatesUrl,
                header: .init(title: item.currencyAccount, detailTitle: item.breakdownAccount),
                card: .init(currrentAccountTitle: item.accountType, currencyType: currencyType),
                options: options,
                currencyType: currencyType,
                isAccountOpen: item.open)
        }
    }
}

// MARK: - СurrencyType

enum OpenAccountСurrencyType: String {

    case RUB
    case USD
    case EUR
    case GBP
    case CHF

    var icon: Image {

        switch self {

        case .RUB: return .init("RUB")
        case .USD: return .init("USD")
        case .EUR: return .init("EUR")
        case .GBP: return .init("GBP")
        case .CHF: return .init("CHF")
        }
    }

    var iconDetail: Image {

        switch self {

        case .RUB: return .init("RUB Detail")
        case .USD: return .init("USD Detail")
        case .EUR: return .init("EUR Detail")
        case .GBP: return .init("GBP Detail")
        case .CHF: return .init("CHF Detail")
        }
    }

    var moneySign: String {

        switch self {

        case .RUB: return "₽"
        case .USD: return "$"
        case .EUR: return "€"
        case .GBP: return "£"
        case .CHF: return "₣"
        }
    }
}

//MARK: - Preview Content

extension OpenAccountViewModel {

    static let sample = OpenAccountViewModel(
        model: .productsMock,
        items: [
            .init(
                currencyCode: 810,
                conditionLinkURL: "https://www.forabank.ru/dkbo/dkbo.pdf",
                ratesLinkURL: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_tarifi.pdf",
                header: .init(
                    title: "RUB счет",
                    detailTitle: "Счет в российских рублях"),
                card: .init(numberCard: "4444555566664345", currencyType: .RUB),
                options: [
                    .init(title: "Открытие"),
                    .init(title: "Обслуживание")
                ],
                currencyType: .RUB,
                isAccountOpen: false),
            .init(
                currencyCode: 840,
                conditionLinkURL: "https://www.forabank.ru/dkbo/dkbo.pdf",
                ratesLinkURL: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_tarifi.pdf",
                header: .init(
                    title: "USD счет",
                    detailTitle: "Счет в долларах США"),
                card: .init(numberCard: "4444555566664346", currencyType: .USD),
                options: [
                    .init(title: "Открытие"),
                    .init(title: "Обслуживание")
                ],
                currencyType: .USD,
                isAccountOpen: false),
            .init(
                currencyCode: 978,
                conditionLinkURL: "https://www.forabank.ru/dkbo/dkbo.pdf",
                ratesLinkURL: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_tarifi.pdf",
                header: .init(
                    title: "EUR счет",
                    detailTitle: "Счет в евро"),
                card: .init(numberCard: "4444555566664347", currencyType: .EUR),
                options: [
                    .init(title: "Открытие"),
                    .init(title: "Обслуживание")
                ],
                currencyType: .EUR,
                isAccountOpen: true),
            .init(
                currencyCode: 826,
                conditionLinkURL: "https://www.forabank.ru/dkbo/dkbo.pdf",
                ratesLinkURL: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_tarifi.pdf",
                header: .init(
                    title: "GBP счет",
                    detailTitle: "Счет в Британских фунтах"),
                card: .init(numberCard: "4444555566664348", currencyType: .GBP),
                options: [
                    .init(title: "Открытие"),
                    .init(title: "Обслуживание")
                ],
                currencyType: .GBP,
                isAccountOpen: true),
            .init(
                currencyCode: 756,
                conditionLinkURL: "https://www.forabank.ru/dkbo/dkbo.pdf",
                ratesLinkURL: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_tarifi.pdf",
                header: .init(
                    title: "CHF счет",
                    detailTitle: "Счет в Швейцарских франках"),
                card: .init(numberCard: "4444555566664349", currencyType: .CHF),
                options: [
                    .init(title: "Открытие"),
                    .init(title: "Обслуживание")
                ],
                currencyType: .CHF,
                isAccountOpen: false)
        ])
}
