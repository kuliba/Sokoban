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

                    Text(viewModel.percentFormat(viewModel.interestRateValue))
                        .foregroundColor(.mainColorsWhite)
                        .font(.textH4M16240())
                }

                Spacer()
            }

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

            DepositSliderViewComponent(value: $viewModel.value, bounds: viewModel.bounds)
                .padding(.bottom, 12)

        }.padding([.leading, .trailing], 20)
    }
}

extension DepositCalculateAmountView {

    final class DepositCalculateTextField: UIViewRepresentable {

        @ObservedObject var viewModel: DepositCalculateAmountViewModel
        private var bindings = Set<AnyCancellable>()

        let view = UITextField()

        init(viewModel: DepositCalculateAmountViewModel) {

            self.viewModel = viewModel

            viewModel.$value
                .receive(on: DispatchQueue.main)
                .sink { value in
                    self.view.text = "\(value)"
                }.store(in: &bindings)
        }

        func makeUIView(context: Context) -> UITextField {

            view.text = "\(viewModel.value)"
            view.textColor = .white
            view.font = UIFont(name: "Inter-SemiBold", size: 24)
            view.delegate = context.coordinator

            return view
        }

        func updateUIView(_ uiView: UITextField, context: Context) {

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

            func textFieldDidEndEditing(_ textField: UITextField) {

                DispatchQueue.main.async {

                    guard let text = textField.text, let value = Double(text) else {
                        return
                    }

                    self.viewModel.value = value
                }
            }

            func textFieldShouldReturn(_ textField: UITextField) -> Bool {

                viewModel.isFirstResponder.toggle()
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
