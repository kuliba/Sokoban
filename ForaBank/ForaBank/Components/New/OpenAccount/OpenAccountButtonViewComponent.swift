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

        let action: () -> Void

        static private func makeTitle(
            currencyName: String,
            operationType: OpenAccountPerformType) -> String {

            switch operationType {
            case .open: return "Открыть \(currencyName) счет"
            case .opened, .opening: return "Открыть еще один \(currencyName) счет"
            case .edit, .confirm: return "Подтвердить"
            }
        }

        static private func makeTitleColor(
            confirmCode: String,
            operationType: OpenAccountPerformType) -> Color {

                switch operationType {
                case .opened:
                    return .mainColorsBlack
                case .edit:

                    if confirmCode.isEmpty {
                        return .mainColorsGrayMedium
                    }

                    return .mainColorsWhite

                default:
                    return .mainColorsWhite
                }
            }

        static private func makeBackgroundColor(
            confirmCode: String,
            operationType: OpenAccountPerformType) -> Color {

                switch operationType {
                case .opened:
                    return .mainColorsGrayLightest
                case .edit:

                    if confirmCode.isEmpty {
                        return .mainColorsGrayLightest
                    }

                    return .mainColorsRed

                default:
                    return .mainColorsRed
                }
            }

        func update(operationType: OpenAccountPerformType,
                    currencyName: String,
                    confirmCode: String) {

            title = Self.makeTitle(currencyName: currencyName, operationType: operationType)
            titleColor = Self.makeTitleColor(confirmCode: confirmCode, operationType: operationType)
            backgroundColor = Self.makeBackgroundColor(confirmCode: confirmCode, operationType: operationType)
        }

        init(currencyName: String, confirmCode: String, operationType: OpenAccountPerformType, action: @escaping () -> Void) {

            self.title = Self.makeTitle(currencyName: currencyName, operationType: operationType)
            self.titleColor = Self.makeTitleColor(confirmCode: confirmCode, operationType: operationType)
            self.backgroundColor = Self.makeBackgroundColor(confirmCode: confirmCode, operationType: operationType)
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
                currencyName: "USD",
                confirmCode: "567834",
                operationType: .open,
                action: {}))
            .frame(height: 48)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
