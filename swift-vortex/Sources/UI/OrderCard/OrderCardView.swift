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
    let factory: ImageViewFactory
    
    private let coordinateSpace: String
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        config: Config,
        factory: ImageViewFactory,
        coordinateSpace: String = "orderScroll"
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.factory = factory
        self.coordinateSpace = coordinateSpace
    }
    
    public var body: some View {
        
        switch state.form {
        case .none:
            loadingProductView()
            
        case let .some(form):
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
    }
    
    @ViewBuilder
    func formView(
        _ form: Form<Confirmation>
    ) -> some View {
        
        VStack(spacing: config.formSpacing) {
            
            coreFormView(form)
            confirmationView(form.confirmation)
        }
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
                .foregroundColor(config.roundedConfig.background)
                .frame(height: 56) // TODO: move to config
                ._shimmering()
            
        case let .loaded(.failure(failure)):
            switch failure.type {
            case .alert:
                Text("confirmation failure alert")
                
            case .informer:
                Text("confirmation failure informer")
            }
            
        case let .loaded(.success(confirmation)):
            Text("form with confirmation \(confirmation)")
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
