//
//  PaymentsSuccessTextView.swift
//  ForaBank
//
//  Created by Max Gribov on 14.03.2023.
//

import SwiftUI

//MARK: - View Model

extension PaymentsSuccessTextView {
    
    final class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        var parameterSuccessText: Payments.ParameterSuccessText? { source as? Payments.ParameterSuccessText }
        
        var text: String { parameterSuccessText?.parameter.value ?? "" }
        var style: Payments.ParameterSuccessText.Style { parameterSuccessText?.style ?? .title }
        
        init(_ source: Payments.ParameterSuccessText) {
            
            super.init(source: source)
        }
    }
}

//MARK: - Veiw

struct PaymentsSuccessTextView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        switch viewModel.style {
        case .title:
            Text(viewModel.text)
                .font(.textH3Sb18240())
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .frame(width: 250)
                .accessibilityIdentifier("SuccessPageTitle")
            
        case .amount:
            Text(viewModel.text)
                .font(.textH1Sb24322())
                .foregroundColor(.textSecondary)
                .padding(.horizontal, 20)
                .accessibilityIdentifier("SuccessPageAmount")
            
        case .subtitle:
            Text(viewModel.text)
                .font(.textBodyMR14180())
                .foregroundColor(.textPlaceholder)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .accessibilityIdentifier("SuccessPageSubtitle")

        case .warning:
            Text(viewModel.text)
                .font(.textH4M16240())
                .foregroundColor(.systemColorError)
                .padding(.horizontal, 20)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("SuccessPageWarning")
            
        case .message:
            Text(viewModel.text)
                .font(.textBodyMR14180())
                .foregroundColor(.textPlaceholder)
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).foregroundColor(.mainColorsGrayLightest))
                .accessibilityIdentifier("SuccessPageMessage")
        }
    }
}

//MARK: - Preview

struct PaymentsSuccessTextView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentsSuccessTextView(viewModel: .sampleTitle)
                .previewLayout(.fixed(width: 375, height: 60))
                .previewDisplayName("Title")
            
            PaymentsSuccessTextView(viewModel: .sampleAmount)
                .previewLayout(.fixed(width: 375, height: 60))
                .previewDisplayName("Amount")
            
            PaymentsSuccessTextView(viewModel: .sampleSubtitle)
                .previewLayout(.fixed(width: 375, height: 60))
                .previewDisplayName("Subtitle")
            
            PaymentsSuccessTextView(viewModel: .sampleWarning)
                .previewLayout(.fixed(width: 375, height: 60))
                .previewDisplayName("Warning")
            
            PaymentsSuccessTextView(viewModel: .sampleMessage)
                .previewLayout(.fixed(width: 375, height: 60))
                .previewDisplayName("Message")
        }
    }
}

//MARK: - Preview Content

extension PaymentsSuccessTextView.ViewModel {
    
    static let sampleTitle = PaymentsSuccessTextView.ViewModel(.init(value: "Платеж принят в обработку", style: .title))
    
    static let sampleAmount = PaymentsSuccessTextView.ViewModel(.init(value: "1 000 ₽", style: .amount))
    
    static let sampleSubtitle = PaymentsSuccessTextView.ViewModel(.init(value: "Денежные средства будут списываться по вашим запросам из Bank Y без подтверждения?", style: .subtitle))
    
    static let sampleWarning = PaymentsSuccessTextView.ViewModel(.init(value: "Перевод отменен!", style: .warning))
    
    static let sampleMessage = PaymentsSuccessTextView.ViewModel(.init(value: "Привяжите счет, деньги будут списываться автоматически. Счет можно будет изменить в настройках приложения", style: .message))
    
    static let sampleC2BSub = PaymentsSuccessTextView.ViewModel(.init(value: "Привязка счета оформлена", style: .title))
    
    static let sampleC2B = PaymentsSuccessTextView.ViewModel(.init(value: "Покупка оплачена", style: .title))
}
