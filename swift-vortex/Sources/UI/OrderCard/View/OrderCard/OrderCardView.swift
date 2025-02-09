//
//  OrderProcessCardView.swift
//
//
//  Created by Дмитрий Савушкин on 09.02.2025.
//

//import CreateCardApplication
//import Foundation
//import LinkableText
//import OTPInputComponent
//import PaymentComponents
//import SharedConfigs
//import UIPrimitives
import SwiftUI

public struct OrderCardView<Confirmation>: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    
    private let coordinateSpace: String
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        config: Config,
        coordinateSpace: String = "orderScroll"
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.coordinateSpace = coordinateSpace
    }
    
    public var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            //                orderProcessCardView(state.orderProduct)
        }
        .coordinateSpace(name: coordinateSpace)
    }
}

public extension OrderCardView {
    
    typealias State = OrderCard.State<Confirmation>
    typealias Event = OrderCard.Event<Confirmation>
    typealias Config = OrderCardViewConfig
}

struct OrderCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        orderCardView(.isLoading)
            .previewDisplayName("isLoading")
        orderCardView(.empty)
            .previewDisplayName("empty")
        orderCardView(.alertFailure)
            .previewDisplayName("alertFailure")
        orderCardView(.informerFailure)
            .previewDisplayName("informerFailure")
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
        product: .preview,
        shimmeringColor: .gray
    )
}

private extension ProductConfig {
    
    static let preview: Self = .init(
        padding: 0,
        title: .init(textFont: .title, textColor: .orange),
        subtitle: .init(textFont: .headline, textColor: .pink),
        optionTitle: .init(textFont: .caption, textColor: .green),
        optionSubtitle: .init(textFont: .footnote, textColor: .blue),
        shimmeringColor: .gray,
        orderOptionIcon: .flag,
        cornerRadius: 24,
        background: .blue.opacity(0.2)
    )
}
