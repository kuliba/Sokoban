//
//  AgreementViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 12.06.2022.
//

import SwiftUI

// MARK: - ViewModel

extension AgreementView {

    class ViewModel: ObservableObject {

        let icon: Image
        let termsButton: ButtonViewModel
        let ratesButton: ButtonViewModel

        let agreeTitle: String
        let termsTitle: String
        let andTitle: String
        let tariffsTitle: String

        init(icon: Image,
             termsButton: ButtonViewModel,
             ratesButton: ButtonViewModel,
             agreeTitle: String = "Я соглашаюсь с",
             termsTitle: String = "Условиями",
             andTitle: String = "и",
             tariffsTitle: String = "Тарифами") {

            self.icon = icon
            self.termsButton = termsButton
            self.ratesButton = ratesButton
            self.agreeTitle = agreeTitle
            self.termsTitle = termsTitle
            self.andTitle = andTitle
            self.tariffsTitle = tariffsTitle
        }
    }
}

extension AgreementView.ViewModel {

    struct ButtonViewModel {

        let action: () -> Void
    }
}

// MARK: - View

struct AgreementView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {

        HStack(alignment: .bottom, spacing: 4) {

            viewModel.icon
                .renderingMode(.original)
                .resizable()
                .foregroundColor(.mainColorsWhite)
                .frame(width: 16, height: 16)

            Text(viewModel.agreeTitle)
                .font(.textBodyXSR11140())
                .foregroundColor(.mainColorsGray)

            Button(action: viewModel.termsButton.action) {

                Text(viewModel.termsTitle)
                    .underline()
                    .font(.textBodyXSR11140())
                    .foregroundColor(.mainColorsGray)
            }

            Text(viewModel.andTitle)
                .font(.textBodyXSR11140())
                .foregroundColor(.mainColorsGray)

            Button(action: viewModel.ratesButton.action) {

                Text(viewModel.tariffsTitle)
                    .underline()
                    .font(.textBodyXSR11140())
                    .foregroundColor(.mainColorsGray)
            }
        }
    }
}

// MARK: - Previews

struct AgreementViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        AgreementView(
            viewModel: .init(
                icon: .init("Checkbox Active"),
                termsButton: .init(action: {}),
                ratesButton: .init(action: {})))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
