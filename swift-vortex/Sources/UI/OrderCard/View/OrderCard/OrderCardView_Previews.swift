//
//  OrderCardView_Previews.swift
//
//
//  Created by Igor Malyarov on 09.02.2025.
//

import SwiftUI

struct OrderCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        orderCardView(.isLoading)
            .previewDisplayName("isLoading")
        orderCardView(.empty)
            .previewDisplayName("empty")
        orderCardView(.alertFailure)
            .previewDisplayName("alert")
        orderCardView(.informerFailure)
            .previewDisplayName("informer")
        orderCardView(.noConfirmation)
            .previewDisplayName("noConfirmation")
        orderCardView(.confirmationAlert)
            .previewDisplayName("confirmationAlert")
        orderCardView(.confirmationAlertIsLoading)
            .previewDisplayName("confirmationAlertIsLoading")
        orderCardView(.confirmationInformer)
            .previewDisplayName("confirmationInformer")
        orderCardView(.confirmationInformerIsLoading)
            .previewDisplayName("confirmationInformerIsLoading")
        orderCardView(.confirmationSuccess)
            .previewDisplayName("confirmationSuccess")
        orderCardView(.confirmationSuccessIsLoading)
            .previewDisplayName("confirmationSuccessIsLoading")
    }
    
    private static func orderCardView(
        _ state: State<PreviewConfirmation>
    ) -> some View {
        
        OrderCardView(state: state, event: { print($0) }, config: .preview)
    }
}

private struct PreviewConfirmation {}

private extension State
where Confirmation == PreviewConfirmation {
    
    static let isLoading: Self = .init(isLoading: true)
    static let empty: Self = .init(isLoading: false, formResult: nil)
    
    static let alertFailure: Self = .init(formResult: .alertFailure)
    static let informerFailure: Self = .init(formResult: .informerFailure)
    
    static let noConfirmation: Self = .init(formResult: .noConfirmation)
    
    static let confirmationAlert: Self = .init(formResult: .confirmationAlert)
    static let confirmationAlertIsLoading: Self = .init(isLoading: true, formResult: .confirmationAlert)
    
    static let confirmationInformer: Self = .init(formResult: .confirmationInformer)
    static let confirmationInformerIsLoading: Self = .init(isLoading: true, formResult: .confirmationInformer)
    
    static let confirmationSuccess: Self = .init(formResult: .confirmationSuccess)
    static let confirmationSuccessIsLoading: Self = .init(isLoading: true, formResult: .confirmationSuccess)
}

private extension Result
where Success == Form<PreviewConfirmation>,
      Failure == LoadFailure {
    
    static let alertFailure: Self = .failure(.alert)
    static let informerFailure: Self = .failure(.informer)
    
    static let noConfirmation: Self = .success(.preview(confirmation: nil, consent: true))
    
    static let confirmationAlert: Self = .success(.confirmationAlert)
    static let confirmationInformer: Self = .success(.confirmationInformer)
    
    static let confirmationSuccess: Self = .success(.confirmationSuccess)
}

private extension LoadFailure {
    
    static let alert: Self = .init(message: "Long error message", type: .alert)
    static let informer: Self = .init(message: "Long error message", type: .informer)
}

private extension Form
where Confirmation == PreviewConfirmation {
    
    static let confirmationAlert: Self = .preview(confirmation: .alert, consent: true)
    static let confirmationInformer: Self = .preview(confirmation: .informer, consent: false)
    static let confirmationSuccess: Self = .preview(confirmation: .success, consent: false)
    
    static func preview(
        requestID: String = "requestID",
        cardApplicationCardType: String = "cardApplicationCardType",
        cardProductExtID: String = "cardProductExtID",
        cardProductName: String = "cardProductName",
        confirmation: Result<PreviewConfirmation, LoadFailure>?,
        consent: Bool,
        messages: Messages = .preview(),
        otp: String? = nil,
        orderCardResponse: OrderCardResponse? = nil
    ) -> Self {
        
        return .init(
            product: .preview,
            type: .preview,
            requestID: requestID,
            cardApplicationCardType: cardApplicationCardType,
            cardProductExtID: cardProductExtID,
            cardProductName: cardProductName,
            confirmation: confirmation,
            consent: consent,
            messages: messages,
            otp: otp,
            orderCardResponse: orderCardResponse
        )
    }
}

private extension Product {
    
    static let preview: Self = .init(image: "", header: ("String", "String"), orderOption: (open: "String", service: "String"))
}

private extension CardType {
    
    static let preview: Self = .init(title: "title", cardType: "cardType", icon: "icon")
}

private extension Result
where Success == PreviewConfirmation,
      Failure == LoadFailure {
    
    static let alert: Self = .failure(.alert)
    static let informer: Self = .failure(.informer)
    
    static let success: Self = .success(.init())
}

private extension Messages {
    
    static func preview(
        description: String = "description",
        icon: String = "icon",
        subtitle: String = "subtitle",
        title: String = "title",
        isOn: Bool = false
    ) -> Self {
        
        return .init(
            description: description,
            icon: icon,
            subtitle: subtitle,
            title: title,
            isOn: isOn
        )
    }
}

private extension OrderCardViewConfig {
    
    static let preview: Self = .init(
        cardType: .preview,
        formSpacing: 16,
        product: .preview,
        shimmeringColor: .gray
    )
}

private extension SelectConfig {
    
    static let preview: Self = .init(
        title: .init(
            textFont: .title2,
            textColor: .orange
        ),
        select: .init(
            textFont: .headline,
            textColor: .green
        ),
        icon: .percent
    )
}

private extension ProductConfig {
    
    static let preview: Self = .init(
        padding: 16,
        title: .init(textFont: .title, textColor: .orange),
        subtitle: .init(textFont: .headline, textColor: .pink),
        optionTitle: .init(textFont: .caption, textColor: .green),
        optionSubtitle: .init(textFont: .footnote, textColor: .blue),
        shimmeringColor: .gray,
        orderOptionIcon: .flag,
        cornerRadius: 24,
        background: .blue.opacity(0.1)
    )
}
