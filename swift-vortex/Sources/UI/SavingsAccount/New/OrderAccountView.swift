//
//  OrderAccountView.swift
//
//
//  Created by Andryusina Nataly on 09.02.2025.
//

import SwiftUI

public struct OrderAccountView<Confirmation, ConfirmationView>: View
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
                .frame(maxHeight: .infinity, alignment: .top)
            
        case let .loading(.some(form)):
            formView(form)
                .disabled(true)
            
        case let .loaded(.success(form)):
            formView(form)
        }
    }
}

public extension OrderAccountView {
    
    typealias State = ProductState<Confirmation>
    typealias Event = ProductEvent<Confirmation>
    typealias Config = OrderSavingsAccountConfig
}

private extension OrderAccountView {
    
    func loadingProductView() -> some View {
        
        ProductView(
            data: .sample,
            config: config,
            makeIconView: { _ in EmptyView() })
        .rounded(RoundedConfig(padding: config.padding, cornerRadius: config.cornerRadius, background: config.background))
    }
    
    @ViewBuilder
    func formView(
        _ form: Form<Confirmation>
    ) -> some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: config.padding) {
                
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
            RoundedRectangle(cornerRadius: config.cornerRadius)
                .foregroundColor(config.shimmering.opacity(0.7))
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
    }
    
    func coreFormView(
        _ form: Form<Confirmation>
    ) -> some View {
        
        VStack(spacing: config.padding) {
            
            productView(form.product)
        }
        .disabled(state.hasConfirmation)
    }
    
    func productView(
        _ product: ProductData
    ) -> some View {
        
        ProductView(
            data: product,
            config: config,
            makeIconView: factory.makeIconView
        )
        .rounded(RoundedConfig(padding: config.padding, cornerRadius: config.cornerRadius, background: config.background))
    }
    
    
    /*func messageView(
        _ messages: Messages
    ) -> some View {
        
        // TODO: fix: message has link
        MessageView(
            state: messages,
            event: { event(.setMessages($0)) },
            config: config.messages
        )
        .rounded(config.roundedConfig)
    }*/
}

private extension ProductData {
    
    static let sample: Self = .init(designMd5hash: "", header: .init(title: "", subtitle: ""), openValue: "", orderServiceOption: "")
}
