//
//  PaymentsGroupView.swift
//  ForaBank
//
//  Created by Max Gribov on 20.02.2023.
//

import SwiftUI
import IQKeyboardManagerSwift

struct PaymentsGroupView: View {
    
    let viewModel: PaymentsGroupViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ForEach(viewModel.items) { itemViewModel in
                
                itemView(for: itemViewModel)
                    .frame(minHeight: 72)
                    .background(
                        RoundedCorner(radius: 12, corners: backgroundCorners(for: itemViewModel))
                            .foregroundColor(backgroundColor(for: itemViewModel)))
                    .padding(.horizontal, horizontalPadding(for: itemViewModel))
                
                separatorVeiew(for: itemViewModel)
                    .padding(.horizontal, 16)
            }
        }
    }
}

extension PaymentsGroupView {
    
    func backgroundCorners(for itemViewModel: PaymentsParameterViewModel) -> UIRectCorner {
        
        switch itemViewModel.source {
        case _ as Payments.ParameterMessage:
            return []
            
        case _ as Payments.ParameterAmount:
            return []
         
        case _ as Payments.ParameterCheck:
            return []
            
        case _ as Payments.ParameterContinue:
            return []
            
        default:
            if viewModel.items.count > 1 {
                
                switch itemViewModel.id  {
                case viewModel.items.first?.id:
                    return [.topLeft, .topRight]
                    
                case viewModel.items.last?.id:
                    return [.bottomLeft, .bottomRight]
                    
                default:
                    return []
                    
                }

            } else {
                
                return .allCorners
            }
        }
    }
    
    func backgroundColor(for itemViewModel: PaymentsParameterViewModel) -> Color {
        
        switch itemViewModel.source {
        case _ as Payments.ParameterMessage:
            return .mainColorsBlack
            
        case _ as Payments.ParameterAmount:
            return .clear
        
        case _ as Payments.ParameterCheck:
            return .clear
            
        case _ as Payments.ParameterContinue:
            return .clear

        default:
            switch itemViewModel.source.style {
            case .light:
                return .mainColorsGrayLightest
                
            case .dark:
                return .mainColorsBlack
            }
        }
    }
    
    func horizontalPadding(for itemViewModel: PaymentsParameterViewModel) -> CGFloat {
        
        switch itemViewModel.source {
        case _ as Payments.ParameterMessage:
            return 0
            
        case _ as Payments.ParameterAmount:
            return 0
            
        case _ as Payments.ParameterContinue:
            return 0
            
        default:
            return 16
        }
    }
    
    @ViewBuilder
    func itemView(for viewModel: PaymentsParameterViewModel) -> some View {
        
        switch viewModel {
        case let messageViewModel as PaymentsMessageView.ViewModel:
            PaymentsMessageView(viewModel: messageViewModel)
            
        case let selectViewModel as PaymentsSelectView.ViewModel:
            PaymentsSelectView(viewModel: selectViewModel)
            
        case let selectBankViewModel as PaymentsSelectBankView.ViewModel:
            PaymentsSelectBankView(viewModel: selectBankViewModel)
            
        case let selectCountryViewModel as PaymentsSelectCountryView.ViewModel:
            PaymentsSelectCountryView(viewModel: selectCountryViewModel)
            
        case let selectDropDownViewModel as PaymentSelectDropDownView.ViewModel:
            PaymentSelectDropDownView(viewModel: selectDropDownViewModel)
            
        case let inputViewModel as PaymentsInputView.ViewModel:
            PaymentsInputView(viewModel: inputViewModel)

        case let inputPhoneViewModel as PaymentsInputPhoneView.ViewModel:
            PaymentsInputPhoneView(viewModel: inputPhoneViewModel)
            
        case let checkBoxViewModel as PaymentsCheckView.ViewModel:
            PaymentsCheckView(viewModel: checkBoxViewModel)
            
        case let infoViewModel as PaymentsInfoView.ViewModel:
            PaymentsInfoView(viewModel: infoViewModel)
            
        case let nameViewModel as PaymentsNameView.ViewModel:
            PaymentsNameView(viewModel: nameViewModel)

        case let productViewModel as PaymentsProductView.ViewModel:
            PaymentsProductView(viewModel: productViewModel)
            
        case let productTemplateViewModel as PaymentsProductTemplateView.ViewModel:
            PaymentsProductTemplateView(viewModel: productTemplateViewModel)
            
        case let codeViewModel as PaymentsCodeView.ViewModel:
            PaymentsCodeView(viewModel: codeViewModel)
                .onAppear {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                        
                        //FIXME: get rid of this!!!
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
            
        case let continueButtonViewModel as PaymentsContinueButtonView.ViewModel:
            PaymentsContinueButtonView(viewModel: continueButtonViewModel)
                .padding(.bottom, 16)
            
        case let amountViewModel as PaymentsAmountView.ViewModel:
            PaymentsAmountView(viewModel: amountViewModel)
            
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    func separatorVeiew(for itemViewModel: PaymentsParameterViewModel) -> some View {
        
        if viewModel.items.count > 1,
            itemViewModel.id != viewModel.items.last?.id {
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.mainColorsGrayMedium)
                .opacity(0.5)
            
        } else  {
            
            EmptyView()
        }
    }
}

struct PaymentsGroupView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsGroupView(viewModel: .sampleSingleMessage)
                .previewDisplayName("Message")
            
            PaymentsGroupView(viewModel: .sampleSingleSelect)
                .previewDisplayName("Select")
            
            PaymentsGroupView(viewModel: .sampleSingleSelectBank)
                .previewDisplayName("Select Bank")
            
            PaymentsGroupView(viewModel: .sampleSingleSelectCountry)
                .previewDisplayName("Select Country")
            
            PaymentsGroupView(viewModel: .sampleSingleSelectDropDown)
                .previewDisplayName("Select Drop Down")
            
            PaymentsGroupView(viewModel: .sampleSingleInput)
                .previewDisplayName("Input")
            
            PaymentsGroupView(viewModel: .sampleSingleInputPhone)
                .previewDisplayName("Input Phone")
            
            PaymentsGroupView(viewModel: .sampleSingleCheck)
                .previewDisplayName("CheckBox")
            
            PaymentsGroupView(viewModel: .sampleSingleInfo)
                .previewDisplayName("Info")
            
            PaymentsGroupView(viewModel: .sampleSingleName)
                .previewDisplayName("Name")
            
        }.previewLayout(.fixed(width: 375, height: 120))
        
        Group {
           
            PaymentsGroupView(viewModel: .sampleSingleProduct)
                .previewDisplayName("Product")
            
            PaymentsGroupView(viewModel: .sampleSingleCode)
                .previewDisplayName("Code")
            
            PaymentsGroupView(viewModel: .sampleSingleContinue)
                .previewDisplayName("Continue Button")
            
            PaymentsGroupView(viewModel: .sampleSingleAmount)
                .previewDisplayName("Amount")
            
        }.previewLayout(.fixed(width: 375, height: 120))
        
        PaymentsGroupView(viewModel: .sampleGroup)
            .previewLayout(.sizeThatFits)
            .padding(.vertical, 16)
    }
}

//MARK: - Preview Content

extension PaymentsGroupViewModel {
    
    static let sampleSingleMessage = PaymentsGroupViewModel(items: [PaymentsMessageView.ViewModel.sample])
    
    static let sampleSingleSelect = PaymentsGroupViewModel(items: [PaymentsSelectView.ViewModel.sample])
    
    static let sampleSingleSelectBank = PaymentsGroupViewModel(items: [PaymentsSelectBankView.ViewModel.sample])
    
    static let sampleSingleSelectCountry = PaymentsGroupViewModel(items: [PaymentsSelectCountryView.ViewModel.sample])
    
    static let sampleSingleSelectDropDown = PaymentsGroupViewModel(items: [PaymentSelectDropDownView.ViewModel.sample])
    
    static let sampleSingleInput = PaymentsGroupViewModel(items: [PaymentsInputView.ViewModel.sampleValue])
    
    static let sampleSingleInputPhone = PaymentsGroupViewModel(items: [PaymentsInputPhoneView.ViewModel.samplePhone])
    
    static let sampleSingleCheck = PaymentsGroupViewModel(items: [PaymentsCheckView.ViewModel.sample])
    
    static let sampleSingleInfo = PaymentsGroupViewModel(items: [PaymentsInfoView.ViewModel.sampleParameter])
    
    static let sampleSingleName = PaymentsGroupViewModel(items: [PaymentsNameView.ViewModel.normal])
    
    static let sampleSingleProduct = PaymentsGroupViewModel(items: [PaymentsProductView.ViewModel.sample])
    
    static let sampleSingleCode = PaymentsGroupViewModel(items: [PaymentsCodeView.ViewModel.sample])
    
    static let sampleSingleContinue = PaymentsGroupViewModel(items: [PaymentsContinueButtonView.ViewModel.sampleParam])
    
    static let sampleSingleAmount = PaymentsGroupViewModel(items: [PaymentsAmountView.ViewModel.amountParameter])
    
    static let sampleGroup = PaymentsGroupViewModel(items: [
        PaymentsSelectBankView.ViewModel.sample,
        PaymentsSelectCountryView.ViewModel.sample,
        PaymentSelectDropDownView.ViewModel.sample,
        PaymentsInputView.ViewModel.sampleValue,
        PaymentsInputPhoneView.ViewModel.samplePhone,
        PaymentsCheckView.ViewModel.sample,
        PaymentsInfoView.ViewModel.sampleParameter,
        PaymentsNameView.ViewModel.normal,
        PaymentsProductView.ViewModel.sample,
        PaymentsCodeView.ViewModel.sample
    ])
}

extension PaymentsInputView.ViewModel {
    
    static let sampleEmpty = PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: nil), icon: .init(with: UIImage(named: "Payments Input Sample")!)!, title: "ИНН подразделения", validator: .anyValue, limitator: .init(limit: 9)), model: .emptyMock)
    
    static let sampleValue = PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "0016196314"), icon: .init(with: UIImage(named: "Payments Input Sample")!)!, title: "ИНН подразделения", validator: .anyValue, limitator: nil), model: .emptyMock)
    
    static let sampleValueNotEditable = PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "0016196314"), icon: .init(with: UIImage(named: "Payments Input Sample")!)!, title: "ИНН подразделения", validator: .anyValue, limitator: nil, isEditable: false), model: .emptyMock)
    
    static let samplePhone = PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "+9 925 555-5555"), icon: .init(named: "ic24Smartphone")!, title: "Номер телефона получателя", validator: .anyValue, limitator: nil, isEditable: false), model: .emptyMock)
    
    static let sampleWarning = PaymentsInputView.ViewModel(with: .init(.init(id: UUID().uuidString, value: "123"), icon: .init(with: UIImage(named: "Payments Input Sample")!)!, title: "ИНН подразделения", validator: .init(rules: [Payments.Validation.MinLengthRule(minLenght: 5, actions: [.post: .warning("Минимальная длинна 5 символов")])]), limitator: nil), model: .emptyMock)
}
