//
//  OrderCardView_Previews.swift
//
//
//  Created by Igor Malyarov on 09.02.2025.
//

import Combine
import SwiftUI

struct OrderCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        orderCardView(.isLoading)
            .previewDisplayName("isLoading")
        orderCardView(.isLoadingWithPrevious)
            .previewDisplayName("isLoadingWithPrevious")
        
        orderCardView(.idle)
            .previewDisplayName("idle")
        
        orderCardView(.alert)
            .previewDisplayName("alert")
        orderCardView(.informer)
            .previewDisplayName("informer")
        
        orderCardView(.noConfirmation)
            .previewDisplayName("noConfirmation")
        
        orderCardView(.isLoadingConfirmation)
            .previewDisplayName("isLoadingConfirmation")
        orderCardView(.isLoadingWithPreviousConfirmation)
            .previewDisplayName("isLoadingWithPreviousConfirmation")
        
        orderCardView(.confirmationAlert)
            .previewDisplayName("confirmationAlert")
        orderCardView(.confirmationInformer)
            .previewDisplayName("confirmationInformer")
        
        orderCardView(.confirmationSuccess)
            .previewDisplayName("confirmationSuccess")
    }
    
    private static func orderCardView(
        _ state: State<PreviewConfirmation>
    ) -> some View {
        
        OrderCardView(state: state, event: { print($0) }, config: .preview, factory: .default)
    }
}

private struct PreviewConfirmation {}

private extension State
where Confirmation == PreviewConfirmation {
    
    static let isLoading: Self = .init(loadableForm: .loading(nil))
    static let isLoadingWithPrevious: Self = .init(loadableForm: .loading(.confirmationSuccess))
    
    static let idle: Self = .init(loadableForm: .loaded(nil)) // empty
    
    static let alert: Self = .init(loadableForm: .loaded(.alert))
    static let informer: Self = .init(loadableForm: .loaded(.informer))
    
    static let noConfirmation: Self = .init(loadableForm: .loaded(.noConfirmation))
    
    static let isLoadingConfirmation: Self = .init(loadableForm: .loaded(.isLoadingConfirmation))
    static let isLoadingWithPreviousConfirmation: Self = .init(loadableForm: .loaded(.isLoadingWithPreviousConfirmation))
    
    static let confirmationAlert: Self = .init(loadableForm: .loaded(.confirmationAlert))
    static let confirmationInformer: Self = .init(loadableForm: .loaded(.confirmationInformer))
    
    static let confirmationSuccess: Self = .init(loadableForm: .loaded(.confirmationSuccess))
}

private extension Result
where Success == Form<PreviewConfirmation>,
      Failure == LoadFailure {
    
    static let alert: Self = .failure(.alert)
    static let informer: Self = .failure(.informer)
    
    static let noConfirmation: Self = .success(.noConfirmation)
    
    static let isLoadingConfirmation: Self = .success(.isLoadingConfirmation)
    static let isLoadingWithPreviousConfirmation: Self = .success(.isLoadingWithPreviousConfirmation)
    
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
    
    static let noConfirmation: Self = .preview(confirmation: .idle)
    
    static let isLoadingConfirmation: Self = .preview(confirmation: .isLoading)
    static let isLoadingWithPreviousConfirmation: Self = .preview(confirmation: .isLoadingWithPrevious)
    
    static let confirmationAlert: Self = .preview(confirmation: .alert, consent: true)
    static let confirmationInformer: Self = .preview(confirmation: .informer, consent: false)
    
    static let confirmationSuccess: Self = .preview(confirmation: .success, consent: false)
    
    static func preview(
        requestID: String = "requestID",
        cardApplicationCardType: String = "cardApplicationCardType",
        cardProductExtID: String = "cardProductExtID",
        cardProductName: String = "cardProductName",
        confirmation: Loadable<PreviewConfirmation>,
        consent: Bool = true,
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

private extension Loadable
where State == PreviewConfirmation {
    
    static let idle: Self = .loaded(nil)
    
    static let isLoading: Self = .loading(nil)
    static let isLoadingWithPrevious: Self = .loading(.init())
    
    static let alert: Self = .loaded(.alert)
    static let informer: Self = .loaded(.informer)
    
    static let success: Self = .loaded(.success)
}

private extension Product {
    
    static let preview: Self = .init(image: "", header: ("String", "String"), orderOption: (open: "String", service: "String"))
}

private extension CardType {
    
    static let preview: Self = .init(icon: "icon", title: "title")
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
        messages: .preview,
        product: .preview,
        shimmeringColor: .gray,
        roundedConfig: .init(
            padding: 16,
            cornerRadius: 24,
            background: .blue.opacity(0.1)
        )
    )
}

private extension CardTypeViewConfig {
    
    static let preview: Self = .init(
        title: .init(
            textFont: .title2,
            textColor: .orange
        ),
        subtitle: .init(
            text: "Select type",
            config: .init(
                textFont: .headline,
                textColor: .green
            )
        )
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

private extension ImageViewFactory {
    
    static let `default`: Self = .init(
        makeIconView: {
            switch $0 {
            case "1":
                return  .init(
                    image: .bolt,
                    publisher: Just(.bolt).eraseToAnyPublisher()
                )
                
            case "2":
                return  .init(
                    image: .shield,
                    publisher: Just(.shield).eraseToAnyPublisher()
                )
                
            default:
                return .init(
                    image: .flag,
                    publisher: Just(.flag).eraseToAnyPublisher()
                )
            }
        },
        makeBannerImageView: {
            switch $0 {
            case "1":
                return  .init(
                    image: .shield,
                    publisher: Just(.shield).eraseToAnyPublisher()
                )
                
            case "2":
                return  .init(
                    image: .bolt,
                    publisher: Just(.bolt).eraseToAnyPublisher()
                )
                
            default:
                return .init(
                    image: .percent,
                    publisher: Just(.percent).eraseToAnyPublisher()
                )
            }
        }
    )
}
