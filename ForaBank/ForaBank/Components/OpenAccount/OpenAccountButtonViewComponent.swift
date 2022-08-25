//
//  OpenAccountButtonViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 12.06.2022.
//

import SwiftUI

// MARK: - ViewModel

extension OpenAccountButtonView {

    class ViewModel: ObservableObject {

        @Published var title: String
        @Published var titleColor: Color
        @Published var backgroundColor: Color

        private let style: OpenAccountViewModel.Style
        let action: () -> Void

        static private func makeTitle(
            currency: Currency,
            operationType: OpenAccountPerformType,
            style: OpenAccountViewModel.Style) -> String {

            switch operationType {
            case .open: return "Открыть \(currency.description) счет"
            case .opening: return "Открыть еще один \(currency.description) счет"
            case .opened: return makeTitleStyle(style, currency: currency)
            case .edit, .confirm: return "Подтвердить"
            }
        }
        
        static private func makeTitleStyle(_ style: OpenAccountViewModel.Style, currency: Currency) -> String {
            
            switch style {
            case .openAccount:
                return "Открыть еще один \(currency.description) счет"
            case .currencyWallet:
                return "Продолжить"
            }
        }

        static private func makeTitleColor(
            operationType: OpenAccountPerformType,
            style: OpenAccountViewModel.Style) -> Color {

                switch operationType {
                case .opened:
                    return makeTitleColorStyle(style)
                default:
                    return .mainColorsWhite
                }
            }
        
        static private func makeTitleColorStyle(_ style: OpenAccountViewModel.Style) -> Color {
            
            switch style {
            case .openAccount: return .mainColorsBlack
            case .currencyWallet: return .mainColorsWhite
            }
        }

        static private func makeBackgroundColor(
            operationType: OpenAccountPerformType,
            style: OpenAccountViewModel.Style) -> Color {

                switch operationType {
                case .opened:
                    return makeBackgroundColorStyle(style)
                default:
                    return .mainColorsRed
                }
            }
        
        static private func makeBackgroundColorStyle(_ style: OpenAccountViewModel.Style) -> Color {
            
            switch style {
            case .openAccount: return .mainColorsGrayLightest
            case .currencyWallet: return .mainColorsRed
            }
        }

        func update(operationType: OpenAccountPerformType, currency: Currency) {

            title = Self.makeTitle(currency: currency, operationType: operationType, style: style)
            titleColor = Self.makeTitleColor(operationType: operationType, style: style)
            backgroundColor = Self.makeBackgroundColor(operationType: operationType, style: style)
        }

        init(currency: Currency, operationType: OpenAccountPerformType, style: OpenAccountViewModel.Style, action: @escaping () -> Void) {

            self.title = Self.makeTitle(currency: currency, operationType: operationType, style: style)
            self.titleColor = Self.makeTitleColor(operationType: operationType, style: style)
            self.backgroundColor = Self.makeBackgroundColor(operationType: operationType, style: style)
            
            self.style = style
            self.action = action
        }
    }
}

// MARK: - View

struct OpenAccountButtonView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {

        Button(action: viewModel.action) {

            ZStack {

                RoundedRectangle(cornerRadius: 9)
                    .foregroundColor(viewModel.backgroundColor)

                Text(viewModel.title)
                    .font(.buttonLargeSB16180())
                    .foregroundColor(viewModel.titleColor)
            }
        }
    }
}

// MARK: - Previews

struct OpenAccountButtonViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        OpenAccountButtonView(
            viewModel: .init(
                currency: .init(description: "USD"),
                operationType: .open,
                style: .openAccount,
                action: {}))
            .frame(height: 48)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
