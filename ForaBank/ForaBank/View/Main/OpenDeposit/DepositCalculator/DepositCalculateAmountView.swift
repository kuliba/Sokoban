//
//  DepositCalculateAmountView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 04.05.2022.
//

import SwiftUI
import Combine
import IQKeyboardManagerSwift

struct DepositCalculateAmountView: View {
    
    @ObservedObject var viewModel: DepositCalculateAmountViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(viewModel.depositTerm)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsGray)
                        .accessibilityIdentifier("DepositCalculatorTermTitle")
                    
                    HStack {
                        
                        Text(viewModel.depositValue)
                            .foregroundColor(.mainColorsWhite)
                            .font(.textH4M16240())
                            .accessibilityIdentifier("DepositCalculatorTermValue")
                        
                        Button {
                            
                            viewModel.isShowBottomSheet.toggle()
                            
                        } label: {
                            
                            Image.ic24ChevronDown
                                .renderingMode(.template)
                                .foregroundColor(.mainColorsGray)
                                .accessibilityIdentifier("DepositCalculatorTermButton")
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(viewModel.interestRate)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsGray)
                        .accessibilityIdentifier("DepositCalculatorRateTitle")
                    
                    Text(viewModel.interestRateValueCurrency)
                        .foregroundColor(.mainColorsWhite)
                        .font(.textH4M16240())
                        .accessibilityIdentifier("DepositCalculatorRateValue")
                }
                .padding(.trailing, 15)
            }
            
            HStack {
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(viewModel.depositAmount)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsGray)
                        .accessibilityIdentifier("DepositCalculatorAmountTitle")
                    
                    HStack {
                        
                        DepositCalculateTextField(viewModel: viewModel)
                            .fixedSize()
                            .onAppear {
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                                    
                                    IQKeyboardManager.shared.enable = true
                                    IQKeyboardManager.shared.enableAutoToolbar = true
                                    IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
                                    IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
                                }
                            }
                            .onDisappear {
                                
                                IQKeyboardManager.shared.enable = false
                                IQKeyboardManager.shared.enableAutoToolbar = false
                            }
                            .accessibilityIdentifier("DepositCalculatorAmountTextField")
                        
                        Button {
                            
                            viewModel.isFirstResponder.toggle()
                            
                        } label: {
                            
                            Image.ic16Edit2
                                .renderingMode(.template)
                                .foregroundColor(.mainColorsGray)
                                .accessibilityIdentifier("DepositCalculatorAmountEditButton")
                        }
                    }
                }
                .padding([.top, .bottom], 8)
                
                Spacer()
                
                Text(viewModel.lowerBoundCurrency)
                    .font(.textBodySR12160())
                    .foregroundColor(.mainColorsGray)
                    .padding(.top, 26)
                    .accessibilityIdentifier("DepositCalculatorInitialAmountText")
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
    
    struct DepositCalculateTextField: UIViewRepresentable {
        
        @ObservedObject var viewModel: DepositCalculateAmountViewModel
        
        init(viewModel: DepositCalculateAmountViewModel) {
            self.viewModel = viewModel
        }
        
        func makeUIView(context: Context) -> UITextField {
            
            let textField = UITextField()
            textField.delegate = context.coordinator
            textField.textColor = Color.mainColorsWhite.uiColor()
            textField.tintColor = Color.mainColorsGray.uiColor()
            textField.backgroundColor = .clear
            textField.font = UIFont(name: "Inter-SemiBold", size: 24)
            textField.keyboardType = .numberPad
            
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            textField.spellCheckingType = .no
            
            return textField
        }
        
        func updateUIView(_ uiView: UITextField, context: Context) {
            
            uiView.isUserInteractionEnabled = viewModel.isFirstResponder
            uiView.text = viewModel.valueCurrencySymbol
            uiView.updateCursorPosition()
            
            switch viewModel.isFirstResponder {
            case true: uiView.becomeFirstResponder()
            case false: uiView.resignFirstResponder()
            }
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(viewModel: viewModel)
        }
        
        class Coordinator: NSObject, UITextFieldDelegate {
            
            let viewModel: DepositCalculateAmountViewModel
            
            init(viewModel: DepositCalculateAmountViewModel) {
                self.viewModel = viewModel
                super.init()
            }
            
            func textFieldDidBeginEditing(_ textField: UITextField) {
                textField.updateCursorPosition()
            }
            
            func textFieldDidEndEditing(_ textField: UITextField) {
                viewModel.textFieldDidEndEditing(textField)
            }
            
            func textField(
                _ textField: UITextField,
                shouldChangeCharactersIn range: NSRange,
                replacementString string: String
            ) -> Bool {
                
                textField.shouldChangeCharacters(
                    in: range,
                    replacementString: string,
                    viewModel: viewModel
                )
            }
        }
    }
}
extension UITextField {
    
    func shouldChangeCharacters(
        in range: NSRange,
        replacementString string: String,
        viewModel: DepositCalculateAmountViewModel
    ) -> Bool {
        
        guard let text = self.text else {
            return false
        }
        
        var temporary = text.filtered()
        
        if string.isEmpty {
            if temporary.count > 0 {
                temporary.removeLast()
            }
            viewModel.value = Double(temporary) ?? 0
            return true
        }
        
        var filtered = "\(temporary)\(string)".filtered()
        
        if filtered.count > 1 && filtered.first == "0" {
            filtered.removeFirst()
            viewModel.value = Double(filtered) ?? 0
            return false
        }
        
        guard let value = Double(filtered), value <= viewModel.bounds.upperBound else {
            return false
        }
        
        viewModel.value = value
        return false
    }
}

struct DepositCalculateAmountView_Previews: PreviewProvider {
    static var previews: some View {
        
        DepositCalculateAmountView(viewModel: .sample1)
            .background(Color.mainColorsBlack)
            .previewLayout(.sizeThatFits)
    }
}
