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

        func update(operationType: OpenAccountPerformType, currency: Currency) {
            title = Self.makeTitle(currency: currency, operationType: operationType, style: style)
        }

        init(currency: Currency, operationType: OpenAccountPerformType, style: OpenAccountViewModel.Style, action: @escaping () -> Void) {

            self.title = Self.makeTitle(currency: currency, operationType: operationType, style: style)
            
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
                    .foregroundColor(.mainColorsRed)

                Text(viewModel.title)
                    .font(.buttonLargeSB16180())
                    .foregroundColor(.mainColorsWhite)
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
