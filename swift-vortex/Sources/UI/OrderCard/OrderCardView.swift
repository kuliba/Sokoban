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

public struct OrderCardView<Confirmation, ConfirmationView>: View
where ConfirmationView: View{
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    let factory: ImageViewFactory
    // TODO: move to factory, rename factory
    let confirmationView: (Confirmation) -> ConfirmationView
    
    private let coordinateSpace: String
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        config: Config,
        factory: ImageViewFactory,
        @ViewBuilder confirmationView: @escaping (Confirmation) -> ConfirmationView,
        coordinateSpace: String = "orderScroll"
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.factory = factory
        self.confirmationView = confirmationView
        self.coordinateSpace = coordinateSpace
    }
    
    public var body: some View {
        
        switch state.loadableForm {
        case .loading(nil), .loaded(nil), .loaded(.failure):
            loadingProductView()
            
        case let .loading(.some(form)):
            formView(form)
                .disabled(true)
            
        case let .loaded(.success(form)):
            formView(form)
        }
    }
}

public extension OrderCardView {
    
    typealias State = OrderCard.State<Confirmation>
    typealias Event = OrderCard.Event<Confirmation>
    typealias Config = OrderCardViewConfig
}

private extension OrderCardView {
    
    func loadingProductView() -> some View {
        
        ProductView(product: .sample, isLoading: true, config: config.product)
            .rounded(config.roundedConfig)
    }
    
    @ViewBuilder
    func formView(
        _ form: Form<Confirmation>
    ) -> some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: config.formSpacing) {
                
                coreFormView(form)
                confirmationView(form.confirmation)
            }
        }
        .coordinateSpace(name: coordinateSpace)
    }
    
    @ViewBuilder
    func confirmationView(
        _ confirmation: Loadable<Confirmation>?
    ) -> some View {
        
        switch confirmation {
        case .none, .loaded(nil):
            EmptyView()
            
        case .loading:
            RoundedRectangle(cornerRadius: config.roundedConfig.cornerRadius)
                .foregroundColor(config.shimmeringColor.opacity(0.7))
                .frame(height: 56) // TODO: move to config
                ._shimmering()
            
        case let .loaded(.failure(failure)):
            switch failure.type {
            case .alert:
                EmptyView()
                
            case .informer:
                EmptyView()
            }
            
        case let .loaded(.success(confirmation)):
            confirmationView(confirmation)
        }
        //
        //        private let coordinateSpace: String = "orderScroll"
        //
        //        var _body: some View {
        //            ScrollView(showsIndicators: false) {
        //#warning("USE SCROLLVIEW")
        //
        //                //                orderProcessCardView(state.orderProduct)
        //                Text("TBD: Form")
        //            }
        //            .coordinateSpace(name: coordinateSpace)
        //        }
        
    }
    
    func coreFormView(
        _ form: Form<Confirmation>
    ) -> some View {
        
        VStack(spacing: config.formSpacing) {
            
            productView(form.product)
            cardTypeView(form.type)
            messageView(form.messages)
        }
        .disabled(state.hasConfirmation)
    }
    
    func productView(
        _ product: Product
    ) -> some View {
        
        ProductView(
            product: product,
            isLoading: state.loadableForm.isLoading,
            config: config.product
        )
        .rounded(config.roundedConfig)
    }
    
    func cardTypeView(
        _ type: CardType
    ) -> some View {
        
        CardTypeView(
            select: type,
            config: config.cardType,
            makeIconView: factory.makeIconView
        )
        .rounded(config.roundedConfig)
    }
    
    func messageView(
        _ messages: Messages
    ) -> some View {
        
        // TODO: fix: message has link
        MessageView(
            state: messages.isOn,
            event: { event(.setMessages($0)) },
            config: config.messages
        )
        .rounded(config.roundedConfig)
    }
}

private extension Product {
    
    static let sample: Self = .init(image: "", header: ("", ""), orderOption: ("", ""))
}
