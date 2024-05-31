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
                
                Self.separatedItemView(for: itemViewModel, items: viewModel.items)
            }
        }
    }
}

extension PaymentsGroupView {
    
    @ViewBuilder
    static func separatedItemView(
        for viewModel: PaymentsParameterViewModel,
        items: [PaymentsParameterViewModel]
    ) -> some View {
        
        itemView(for: viewModel)
            .frame(minHeight: frameMinHeight(for: viewModel))
            .background(background(for: viewModel, items: items))
            .padding(.horizontal, horizontalPadding(for: viewModel))
        
        separatorView(for: viewModel, items: items)
            .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    static func itemView(
        for viewModel: PaymentsParameterViewModel
    ) -> some View {
        
        switch viewModel {
        case let amountViewModel as PaymentsAmountView.ViewModel:
            PaymentsAmountView(viewModel: amountViewModel)
            
        case let checkBoxViewModel as PaymentsCheckView.ViewModel:
            PaymentsCheckView(viewModel: checkBoxViewModel)
            
        case let codeViewModel as PaymentsCodeView.ViewModel:
            PaymentsCodeView(viewModel: codeViewModel)
                .onAppear {
                    
                    //FIXME: get rid of this!!!
                    IQKeyboardManager.shared.enable = true
                    IQKeyboardManager.shared.enableAutoToolbar = true
                    IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
                    IQKeyboardManager.shared.keyboardDistanceFromTextField = 30
                }
                .onDisappear {
                    
                    IQKeyboardManager.shared.enable = false
                    IQKeyboardManager.shared.enableAutoToolbar = false
                }
            
        case let continueButtonViewModel as PaymentsButtonView.ViewModel:
            PaymentsButtonView(viewModel: continueButtonViewModel)
                .padding(.bottom, 16)
            
        case let infoViewModel as PaymentsInfoView.ViewModel:
            PaymentsInfoView(viewModel: infoViewModel)
            
        case let inputPhoneViewModel as PaymentsInputPhoneView.ViewModel:
            PaymentsInputPhoneView(viewModel: inputPhoneViewModel)
            
        case let inputViewModel as PaymentsInputView.ViewModel:
            PaymentsInputView(viewModel: inputViewModel)
            
        case let messageViewModel as PaymentsMessageView.ViewModel:
            PaymentsMessageView(viewModel: messageViewModel)
            
        case let nameViewModel as PaymentsNameView.ViewModel:
            PaymentsNameView(viewModel: nameViewModel)
            
        case let productViewModel as PaymentsProductView.ViewModel:
            PaymentsProductView(viewModel: productViewModel)
            
        case let productTemplateViewModel as PaymentsProductTemplateView.ViewModel:
            PaymentsProductTemplateView(viewModel: productTemplateViewModel)
            
        case let selectBankViewModel as PaymentsSelectBankView.ViewModel:
            PaymentsSelectBankView(viewModel: selectBankViewModel)
            
        case let selectCountryViewModel as PaymentsSelectCountryView.ViewModel:
            PaymentsSelectCountryView(viewModel: selectCountryViewModel)
            
        case let selectDropDownViewModel as PaymentSelectDropDownView.ViewModel:
            PaymentSelectDropDownView(viewModel: selectDropDownViewModel)
            
        case let selectViewModel as PaymentsSelectView.ViewModel:
            PaymentsSelectView(viewModel: selectViewModel)
            
        case let subscriberViewModel as PaymentsSubscriberView.ViewModel:
            PaymentsSubscriberView(viewModel: subscriberViewModel)
            
        case let subscribeViewModel as PaymentsSubscribeView.ViewModel:
            PaymentsSubscribeView(viewModel: subscribeViewModel)
            
        case let successAdditionalButtons as PaymentsSuccessAdditionalButtonsView.ViewModel:
            PaymentsSuccessAdditionalButtonsView(viewModel: successAdditionalButtons)
            
        case let successIcon as PaymentsSuccessIconView.ViewModel:
            PaymentsSuccessIconView(viewModel: successIcon)
            
        case let successLink as PaymentsSuccessLinkView.ViewModel:
            PaymentsSuccessLinkView(viewModel: successLink)
            
        case let successLogo as PaymentsSuccessLogoView.ViewModel:
            PaymentsSuccessLogoView(viewModel: successLogo)
            
        case let successOptions as PaymentsSuccessOptionsView.ViewModel:
            PaymentsSuccessOptionsView(viewModel: successOptions)
            
        case let successOptionButtons as PaymentsSuccessOptionButtonsView.ViewModel:
            PaymentsSuccessOptionButtonsView(viewModel: successOptionButtons)
            
        case let successText as PaymentsSuccessTextView.ViewModel:
            PaymentsSuccessTextView(viewModel: successText)
            
        case let successTransferNumber as PaymentsSuccessTransferNumberView.ViewModel:
            PaymentsSuccessTransferNumberView(viewModel: successTransferNumber)
            
        case let successService as PaymentsSuccessServiceView.ViewModel:
            PaymentsSuccessServiceView(viewModel: successService)
            
        case let successStatus as PaymentsSuccessStatusView.ViewModel:
            PaymentsSuccessStatusView(viewModel: successStatus)
                .padding(.top, 130)
            
        default:
            EmptyView()
        }
    }
    
    static func background(
        for itemViewModel: PaymentsParameterViewModel,
        items: [PaymentsParameterViewModel]
    ) -> some View {
        
        RoundedCorner(
            radius: 12,
            corners: backgroundCorners(for: itemViewModel, items: items)
        )
        .foregroundColor(backgroundColor(for: itemViewModel))
    }
    
    static func backgroundCorners(
        for itemViewModel: PaymentsParameterViewModel,
        items: [PaymentsParameterViewModel]
    ) -> UIRectCorner {
        
        switch itemViewModel.source {
        case _ as Payments.ParameterMessage:
            return []
            
        default:
            if items.count > 1 {
                
                switch itemViewModel.id  {
                case items.first?.id:
                    return [.topLeft, .topRight]
                    
                case items.last?.id:
                    return [.bottomLeft, .bottomRight]
                    
                default:
                    return []
                }
            } else {
                
                return .allCorners
            }
        }
    }
    
    static func backgroundColor(
        for itemViewModel: PaymentsParameterViewModel
    ) -> Color {
        
        switch itemViewModel.source {
        case _ as Payments.ParameterMessage:
            return .mainColorsBlack
            
        case _ as Payments.ParameterAmount,
            _ as Payments.ParameterButton,
            _ as Payments.ParameterCheck,
            _ as Payments.ParameterSuccessAdditionalButtons,
            _ as Payments.ParameterSuccessIcon,
            _ as Payments.ParameterSuccessLink,
            _ as Payments.ParameterSuccessLogo,
            _ as Payments.ParameterSuccessOptionButtons,
            _ as Payments.ParameterSuccessOptions,
            _ as Payments.ParameterSuccessText,
            _ as Payments.ParameterSuccessService,
            _ as Payments.ParameterSuccessStatus,
            _ as Payments.ParameterSubscribe,
            _ as Payments.ParameterSubscriber:
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
    
    static func horizontalPadding(
        for itemViewModel: PaymentsParameterViewModel
    ) -> CGFloat {
        
        switch itemViewModel.source {
        case _ as Payments.ParameterAmount,
            _ as Payments.ParameterMessage,
            _ as Payments.ParameterSuccessAdditionalButtons:
            return 0
            
        default:
            return 16
        }
    }
    
    static func frameMinHeight(
        for itemViewModel: PaymentsParameterViewModel
    ) -> CGFloat {
        
        switch itemViewModel.source {
        case _ as Payments.ParameterSuccessStatus,
            _ as Payments.ParameterSuccessText,
            _ as Payments.ParameterSuccessIcon,
            _ as Payments.ParameterSuccessOptionButtons,
            _ as Payments.ParameterSuccessLink,
            _ as Payments.ParameterSubscriber,
            _ as Payments.ParameterSuccessService,
            _ as Payments.ParameterSuccessLogo,
            _ as Payments.ParameterButton:
            return 0
            
        default:
            return 72
        }
    }
    
    @ViewBuilder
    static func separatorView(
        for itemViewModel: PaymentsParameterViewModel,
        items: [PaymentsParameterViewModel]
    ) -> some View {
        
        if items.count > 1,
           itemViewModel.id != items.last?.id {
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.mainColorsGrayMedium)
                .opacity(0.3)
            
        } else  {
            
            EmptyView()
        }
    }
}

//MARK: - Factory

extension PaymentsGroupView {
    
    @ViewBuilder
    static func groupView(
        for groupViewModel: PaymentsGroupViewModel
    ) -> some View {
        
        switch groupViewModel {
        case let contactGroupViewModel as PaymentsContactGroupViewModel:
            PaymentsContactGroupView(viewModel: contactGroupViewModel)
            
        case let infoGroupViewModel as PaymentsInfoGroupViewModel:
            PaymentsInfoGroupView(viewModel: infoGroupViewModel)
            
        case let spoilerGroupViewModel as PaymentsSpoilerGroupViewModel:
            PaymentsSpoilerGroupView(viewModel: spoilerGroupViewModel)
            
        default:
            PaymentsGroupView(viewModel: groupViewModel)
        }
    }
}

//MARK: - Preview Content

struct PaymentsGroupView_Previews: PreviewProvider {
    
    private static func preview(_ viewModel: PaymentsGroupViewModel) -> some View {
        PaymentsGroupView(viewModel: viewModel)
    }

    static var previews: some View {
        
        Group {
            
            VStack {
                
                ScrollView(content: previewsGroup)
            }
            .previewDisplayName("Xcode 14+")
            
            previewsGroup()
        }
    }
    
        @ViewBuilder
    static func previewsGroup() -> some View {
        
        Group {
            
            preview(.sampleSingleMessage)
                .previewDisplayName("Message")
            
            preview(.sampleSingleSelect)
                .previewDisplayName("Select")
            
            preview(.sampleSingleSelectBank)
                .previewDisplayName("Select Bank")
            
            preview(.sampleSingleSelectCountry)
                .previewDisplayName("Select Country")
            
            preview(.sampleSingleSelectDropDown)
                .previewDisplayName("Select Drop Down")
            
            preview(.sampleSingleInput)
                .previewDisplayName("Input")
            
            preview(.sampleSingleInputPhone)
                .previewDisplayName("Input Phone")
            
            preview(.sampleSingleCheck)
                .previewDisplayName("CheckBox")
            
            preview(.sampleSingleInfo)
                .previewDisplayName("Info")
            
            preview(.sampleSingleName)
                .previewDisplayName("Name")
            
        }.previewLayout(.fixed(width: 375, height: 120))
        
        Group {
            
            preview(.sampleSingleProduct)
                .previewDisplayName("Product")
            
            preview(.sampleSingleCode)
                .previewDisplayName("Code")
            
            preview(.sampleSingleContinue)
                .previewDisplayName("Continue Button")
            
            preview(.sampleSingleAmount)
                .previewDisplayName("Amount")
            
            preview(.sampleSuccessStatus)
                .previewDisplayName("Success status")
            
            preview(.sampleSuccessText)
                .previewDisplayName("Success text")
            
        }.previewLayout(.fixed(width: 375, height: 120))
        
        preview(.sampleGroup)
            .previewLayout(.sizeThatFits)
            .padding(.vertical, 16)
    }
}

extension PaymentsGroupViewModel {
    
    static let sampleSingleMessage = PaymentsGroupViewModel(items: [PaymentsMessageView.ViewModel.sample])
    
    static let sampleSingleSelect = PaymentsGroupViewModel(items: [PaymentsSelectView.ViewModel.selectedDisabled])
    
    static let sampleSingleSelectBank = PaymentsGroupViewModel(items: [PaymentsSelectBankView.ViewModel.sampleParameter])
    
    static let sampleSingleSelectCountry = PaymentsGroupViewModel(items: [PaymentsSelectCountryView.ViewModel.sample])
    
    static let sampleSingleSelectDropDown = PaymentsGroupViewModel(items: [PaymentSelectDropDownView.ViewModel.sample])
    
    static let sampleSingleInput = PaymentsGroupViewModel(items: [PaymentsInputView.ViewModel.sample])
    
    static let sampleSingleInputPhone = PaymentsGroupViewModel(items: [PaymentsInputPhoneView.ViewModel.samplePhone])
    
    static let sampleSingleCheck = PaymentsGroupViewModel(items: [PaymentsCheckView.ViewModel.sample])
    
    static let sampleSingleInfo = PaymentsGroupViewModel(items: [PaymentsInfoView.ViewModel.sampleParameter])
    
    static let sampleSingleName = PaymentsGroupViewModel(items: [PaymentsNameView.ViewModel.normal])
    
    static let sampleSingleProduct = PaymentsGroupViewModel(items: [PaymentsProductView.ViewModel.sample])
    
    static let sampleSingleCode = PaymentsGroupViewModel(items: [PaymentsCodeView.ViewModel.sample])
    
    static let sampleSingleContinue = PaymentsGroupViewModel(items: [PaymentsButtonView.ViewModel.sampleParam])
    
    static let sampleSingleAmount = PaymentsGroupViewModel(items: [PaymentsAmountView.ViewModel.amountParameter])
    
    static let sampleSuccessStatus = PaymentsGroupViewModel(items: [PaymentsSuccessStatusView.ViewModel.sampleSuccess])
    
    static let sampleSuccessText = PaymentsGroupViewModel(items: [PaymentsSuccessTextView.ViewModel.sampleTitle])
    
    static let sampleGroup = PaymentsGroupViewModel(items: [
        PaymentsSelectBankView.ViewModel.sampleParameter,
        PaymentsSelectCountryView.ViewModel.sample,
        PaymentSelectDropDownView.ViewModel.sample,
        PaymentsInputView.ViewModel.sample,
        PaymentsInputPhoneView.ViewModel.samplePhone,
        PaymentsCheckView.ViewModel.sample,
        PaymentsInfoView.ViewModel.sampleParameter,
        PaymentsNameView.ViewModel.normal,
        PaymentsProductView.ViewModel.sample,
        PaymentsCodeView.ViewModel.sample
    ])
}
