//
//  CurrencyListVIewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 22.06.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension CurrencyListVIew {

    class ViewModel: ObservableObject {

        let action: PassthroughSubject<Action, Never> = .init()

        @Published var items: [ItemViewModel]

        lazy var button: ButtonViewModel = .init { [unowned self] in
            action.send(CurrencyListAction.Button.Tapped())
        }

        init(items: [ItemViewModel]) {

            self.items = items
        }
    }
}

extension CurrencyListVIew.ViewModel {

    // MARK: - Item

    class ItemViewModel: ObservableObject, Identifiable {

        @Published var isSelected: Bool

        let id: String
        let icon: Image
        let currencyType: String
        let rateBuy: Double
        let rateSell: Double

        var rateBuyCurrency: String {
            rateBuy.currencyFormatterForMain()
        }

        var rateSellCurrency: String {
            rateSell.currencyFormatterForMain()
        }

        init(id: String = UUID().uuidString,
             icon: Image,
             currencyType: String,
             rateBuy: Double,
             rateSell: Double,
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

struct CurrencyListVIew: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {

        HStack {
            ScrollView(.horizontal, showsIndicators: false) {

                HStack(spacing: 8) {

                    ButtonView(viewModel: viewModel.button)

                    ForEach(viewModel.items) { viewModel in
                        ItemView(viewModel: viewModel)
                    }
                }.padding(20)
            }
        }
    }
}

extension CurrencyListVIew {

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

                            viewModel.icon
                                .resizable()
                                .frame(width: 20, height: 20)

                        }.frame(width: 25, height: 25)

                        Text(viewModel.currencyType)
                            .font(.textBodySM12160())
                            .foregroundColor(.mainColorsGray)
                    }

                    VStack(spacing: 8) {

                        Text(viewModel.rateBuyCurrency)
                            .font(.textBodySM12160())
                            .foregroundColor(.mainColorsBlack)

                        Divider()
                            .frame(width: 34)
                            .background(Color.mainColorsGrayMedium)

                        Text(viewModel.rateSellCurrency)
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

// MARK: - Action

enum CurrencyListAction {

    enum Button {

        struct Tapped: Action {}
    }
}

// MARK: - Previews

struct CurrencyListVIewComponent_Previews: PreviewProvider {

    static var previews: some View {

        CurrencyListVIew(viewModel: .init(items: [
            .init(icon: .init("Flag USD"),
                  currencyType: "USD",
                  rateBuy: 68.19,
                  rateSell: 69.45,
                  isSelected: true),
            .init(icon: .init("Flag EUR"),
                  currencyType: "EUR",
                  rateBuy: 69.23,
                  rateSell: 70.01),
            .init(icon: .init("Flag GBP"),
                  currencyType: "GBP",
                  rateBuy: 75.65,
                  rateSell: 76.83),
            .init(icon: .init("Flag CHF"),
                  currencyType: "CHF",
                  rateBuy: 64.89,
                  rateSell: 65.09),
            .init(icon: .init("Flag CHY"),
                  currencyType: "CHY",
                  rateBuy: 18.45,
                  rateSell: 19.26)
        ])).previewLayout(.sizeThatFits)
    }
}
