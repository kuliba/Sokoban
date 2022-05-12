//
//  DepositCalculateAmountView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 04.05.2022.
//


import SwiftUI
import Combine

struct DepositCalculateAmountView: View {

    @ObservedObject var viewModel: DepositCalculateAmountViewModel

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            HStack {

                VStack(alignment: .leading, spacing: 8) {

                    Text(viewModel.depositTerm)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsGray)

                    HStack {

                        Text("\(viewModel.depositValue) дней")
                            .foregroundColor(.mainColorsWhite)
                            .font(.textH4M16240())

                        Button {

                            viewModel.isShowBottomSheet.toggle()

                        } label: {

                            Image.ic24ChevronDown
                                .renderingMode(.template)
                                .foregroundColor(.mainColorsGray)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .leading, spacing: 8) {

                    Text(viewModel.interestRate)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsGray)

                    Text(viewModel.interestRateValue.currencyDepositFormatter(symbol: "₽"))
                        .foregroundColor(.mainColorsWhite)
                        .font(.textH4M16240())
                }

                Spacer()
            }

            HStack {

                VStack(alignment: .leading, spacing: 8) {

                    Text(viewModel.depositAmount)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsGray)

                    HStack {

                        DepositCalculateTextField(viewModel: viewModel)
                            .fixedSize()

                        Button {

                            viewModel.isFirstResponder.toggle()

                        } label: {

                            Image.ic16Edit2
                                .renderingMode(.template)
                                .foregroundColor(.mainColorsGray)
                        }
                    }
                }
                .padding([.top, .bottom], 8)

                Spacer()

                Text("От \(viewModel.bounds.lowerBound.currencyDepositShortFormatter())")
                    .font(.textBodySR12160())
                    .foregroundColor(.mainColorsGray)
                    .padding(.top, 26)
            }

            DepositSliderViewComponent(
                viewModel: .init(
                    value: $viewModel.value,
                    bounds: viewModel.bounds)
            ).padding(.bottom, 12)

        }.padding([.leading, .trailing], 20)
    }
}

extension DepositCalculateAmountView {

    final class DepositCalculateTextField: UIViewRepresentable {

        @ObservedObject var viewModel: DepositCalculateAmountViewModel
        private var bindings = Set<AnyCancellable>()

        private let textField = UITextField()

        init(viewModel: DepositCalculateAmountViewModel) {

            self.viewModel = viewModel

            bind()
        }

        private func bind() {

            viewModel.$value
                .receive(on: DispatchQueue.main)
                .sink { value in

                    DispatchQueue.main.async { [unowned self] in
                        textField.text = "\(value.currencyDepositFormatter(symbol: "₽"))"
                        textField.updateCursorPosition()
                    }

                }.store(in: &bindings)
        }

        func makeUIView(context: Context) -> UITextField {

            textField.delegate = context.coordinator
            textField.textColor = Color.mainColorsWhite.uiColor()
            textField.tintColor = Color.mainColorsGray.uiColor()
            textField.backgroundColor = .clear
            textField.font = UIFont(name: "Inter-SemiBold", size: 24)
            textField.keyboardType = .numberPad

            return textField
        }

        func updateUIView(_ uiView: UITextField, context: Context) {

            uiView.isUserInteractionEnabled = viewModel.isFirstResponder

            switch viewModel.isFirstResponder {
            case true: uiView.becomeFirstResponder()
            case false: uiView.resignFirstResponder()
            }
        }

        func makeCoordinator() -> Coordinator {

            Coordinator(viewModel: viewModel)
        }

        class Coordinator: NSObject, UITextFieldDelegate {

            @ObservedObject var viewModel: DepositCalculateAmountViewModel

            init(viewModel: DepositCalculateAmountViewModel) {
                self.viewModel = viewModel
            }

            func textFieldDidBeginEditing(_ textField: UITextField) {
                textField.updateCursorPosition()
            }

            func textFieldDidEndEditing(_ textField: UITextField) {

                DispatchQueue.main.async {

                    let filterred = textField.text?.filterred()

                    guard let text = filterred, let value = Double(text) else {
                        textField.text = self.viewModel.value.currencyDepositFormatter()
                        return
                    }

                    self.viewModel.value = value
                }
            }

            func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

                guard let text = textField.text else {
                    return false
                }

                let filterred = "\(text)\(string)".filterred()

                if filterred.count > 1 && filterred.first == "0" {
                    return false
                }

                guard let value = Double(filterred), value <= viewModel.bounds.upperBound else {
                    return false
                }

                return true
            }
        }
    }
}

struct DepositCalculateAmountView_Previews: PreviewProvider {
    static var previews: some View {

        DepositCalculateAmountView(viewModel: .sample1)
            .background(Color.mainColorsBlack)
            .previewLayout(.sizeThatFits)
    }
}
