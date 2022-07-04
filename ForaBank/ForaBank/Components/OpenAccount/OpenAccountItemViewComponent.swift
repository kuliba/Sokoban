//
//  OpenAccountItemViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 12.06.2022.
//

import SwiftUI

typealias OpenAccountItemViewModel = OpenAccountItemView.ViewModel
typealias OpenAccountOptionViewModel = OpenAccountItemViewModel.OptionViewModel

// MARK: - ViewModel

extension OpenAccountItemView {

    class ViewModel: ObservableObject, Identifiable {

        @Published var isAccountOpen: Bool

        let id: String
        let currencyCode: Int
        let conditionLinkURL: String
        let ratesLinkURL: String?

        let header: HeaderViewModel
        let card: OpenAccountCardView.ViewModel
        let options: [OptionViewModel]
        let currencyType: OpenAccountСurrencyType

        init(id: String = UUID().uuidString,
             currencyCode: Int,
             conditionLinkURL: String,
             ratesLinkURL: String?,
             header: HeaderViewModel,
             card: OpenAccountCardView.ViewModel,
             options: [OptionViewModel],
             currencyType: OpenAccountСurrencyType,
             isAccountOpen: Bool) {

            self.id = id
            self.currencyCode = currencyCode
            self.conditionLinkURL = conditionLinkURL
            self.ratesLinkURL = ratesLinkURL
            self.header = header
            self.card = card
            self.options = options
            self.currencyType = currencyType
            self.isAccountOpen = isAccountOpen
        }
    }
}

extension OpenAccountItemView.ViewModel {

    // MARK: - Header

    class HeaderViewModel: ObservableObject {

        @Published var title: String
        @Published var isAccountOpened: Bool

        let detailTitle: String

        init(title: String, detailTitle: String, isAccountOpened: Bool = false) {

            self.title = title
            self.detailTitle = detailTitle
            self.isAccountOpened = isAccountOpened
        }
    }

    // MARK: - Option

    struct OptionViewModel: Identifiable {

        let id = UUID()
        let title: String
        let icon: Image
        let description: String
        let colorType: ColorType

        init(title: String,
             icon: Image = .init("Arrow Circle"),
             description: String = "Бесплатно",
             colorType: ColorType = .green) {

            self.title = title
            self.icon = icon
            self.description = description
            self.colorType = colorType
        }

        enum ColorType: String {

            case green

            var iconColor: Color {

                switch self {
                case .green: return .systemColorActive
                }
            }

        }
    }
}

// MARK: - View

struct OpenAccountItemView: View {

    @ObservedObject var viewModel: ViewModel
    
    var body: some View {

        ZStack {

            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.mainColorsGrayLightest)

            VStack(alignment: .leading) {

                HeaderView(viewModel: viewModel.header)

                HStack(alignment: .top, spacing: 20) {

                    OpenAccountCardView(viewModel: viewModel.card)

                    VStack {

                        ForEach(viewModel.options) { option in
                            OptionView(viewModel: option)
                        }
                    }
                }.padding(20)

                Spacer()
            }
        }.frame(width: UIScreen.main.bounds.width - 40, height: 200)
    }
}

extension OpenAccountItemView {

    // MARK: - Header

    struct HeaderView: View {

        @ObservedObject var viewModel: ViewModel.HeaderViewModel

        var body: some View {

            HStack(alignment: .top) {

                VStack(alignment: .leading, spacing: 4) {

                    Text(viewModel.title)
                        .font(.textH3SB18240())
                        .foregroundColor(.mainColorsBlack)

                    Text(viewModel.detailTitle)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsGray)
                }

                Spacer()

                if viewModel.isAccountOpened {

                    Image("Check Enabled")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }.padding([.leading, .trailing, .top], 20)
        }
    }

    // MARK: - Option

    struct OptionView: View {

        let viewModel: ViewModel.OptionViewModel

        var body: some View {

            VStack(alignment: .leading, spacing: 8) {

                Text(viewModel.title)
                    .font(.textBodySR12160())
                    .foregroundColor(.mainColorsGray)

                HStack {

                    viewModel.icon
                        .renderingMode(.template)
                        .foregroundColor(viewModel.colorType.iconColor)

                    Text(viewModel.description)
                        .font(.textH4M16240())
                        .foregroundColor(.mainColorsBlack)
                }
            }
        }
    }
}

//MARK: - Preview Content

extension OpenAccountItemView.ViewModel {

    static let empty: OpenAccountItemView.ViewModel = .init(
        id: UUID().uuidString,
        currencyCode: 0,
        conditionLinkURL: "",
        ratesLinkURL: nil,
        header: .init(title: "", detailTitle: ""),
        card: .init(currencyType: .RUB),
        options: .init(),
        currencyType: .RUB,
        isAccountOpen: false
    )

    static let sample = OpenAccountItemViewModel(
        currencyCode: 810,
        conditionLinkURL: "https://www.forabank.ru/dkbo/dkbo.pdf",
        ratesLinkURL: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_tarifi.pdf",
        header: .init(
            title: "USD счет",
            detailTitle: "Счет в долларах США"),
        card: .sample,
        options: [
            .init(title: "Открытие"),
            .init(title: "Обслуживание")
        ],
        currencyType: .USD,
        isAccountOpen: false)
}

// MARK: - Previews

struct OpenAccountItemViewComponent_Previews: PreviewProvider {

    static var previews: some View {

        OpenAccountItemView(viewModel: .sample)
            .previewLayout(.sizeThatFits)
    }
}
