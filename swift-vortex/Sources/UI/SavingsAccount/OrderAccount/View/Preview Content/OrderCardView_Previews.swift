//
//  OrderCardView_Previews.swift
//
//
//  Created by Igor Malyarov on 09.02.2025.
//

import Combine
import LoadableState
import SwiftUI

struct OrderCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        orderAccountView(.isLoading)
            .previewDisplayName("isLoading")
        orderAccountView(.isLoadingWithPrevious)
            .previewDisplayName("isLoadingWithPrevious")
        
        orderAccountView(.idle)
            .previewDisplayName("idle")
        
        orderAccountView(.alert)
            .previewDisplayName("alert")
        orderAccountView(.informer)
            .previewDisplayName("informer")
        
        orderAccountView(.noConfirmation)
            .previewDisplayName("noConfirmation")
        
        orderAccountView(.isLoadingConfirmation)
            .previewDisplayName("isLoadingConfirmation")
        orderAccountView(.isLoadingWithPreviousConfirmation)
            .previewDisplayName("isLoadingWithPreviousConfirmation")
        
        orderAccountView(.confirmationAlert)
            .previewDisplayName("confirmationAlert")
        orderAccountView(.confirmationInformer)
            .previewDisplayName("confirmationInformer")
        
        orderAccountView(.confirmationSuccess)
            .previewDisplayName("confirmationSuccess")
    }
    
    private static func orderAccountView(
        _ state: ProductState<PreviewConfirmation>
    ) -> some View {
        
        OrderAccountView(
            state: state,
            event: { print($0) },
            config: .preview,
            factory: .default
        ) { confirmation in
            
            Color.green
                .frame(height: 400)
                .overlay {
                
                    Text(String(describing: confirmation))
                        .foregroundStyle(.white)
                        .font(.title3)
                }
        } productSelectView: {
            Text("productSelectView")
        }
    }
}

private struct PreviewConfirmation {}

private extension ProductState
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
        constants: Constants = .preview,
        confirmation: Loadable<PreviewConfirmation>,
        consent: Bool = true,
        messages: TopUp = .preview(),
        otp: String? = nil,
        orderAccountResponse: OrderAccountResponse? = nil
    ) -> Self {
        
        return .init(
            constants: constants,
            confirmation: confirmation,
            topUp: messages,
            otp: otp,
            orderAccountResponse: orderAccountResponse, 
            amount: .preview
        )
    }
}

private extension Constants {
    
    static let preview: Self = .init(
        currency: .init(code: 810, symbol: "rub"),
        designMd5hash: "",
        header: .init(title: "title", subtitle: "subtitle"),
        hint: "hint",
        income: "income",
        links: .init(conditions: "conditions", tariff: "tariff"),
        openValue: "openValue",
        orderServiceOption: "orderServiceOption"
    )
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
    
    static let preview: Self = .init(designMd5hash: "designMd5hash", header: .init(title: "title", subtitle: "subtitle"), openValue: "openValue", orderServiceOption: "orderServiceOption")
}

private extension Result
where Success == PreviewConfirmation,
      Failure == LoadFailure {
    
    static let alert: Self = .failure(.alert)
    static let informer: Self = .failure(.informer)
    
    static let success: Self = .success(.init())
}

private extension TopUp {
    
    static func preview(
        isOn: Bool = false
    ) -> Self {
        
        return .init(
            isOn: isOn
        )
    }
}
