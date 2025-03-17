//
//  OrderProcessCardView.swift
//
//
//  Created by Дмитрий Савушкин on 09.02.2025.
//

import SwiftUI
import SelectorComponent

public struct OrderCardView<Confirmation, ConfirmationView, SelectorView>: View
where ConfirmationView: View,
      SelectorView: View {
    
    public typealias Factory = ViewFactory<Confirmation, ConfirmationView, SelectorView>
    
    private let state: State
    private let event: (Event) -> Void
    private let config: Config
    private let factory: Factory
    
    private let coordinateSpace: String
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        config: Config,
        factory: Factory,
        coordinateSpace: String = "orderScroll"
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.factory = factory
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

public extension OrderCardView {
    
    typealias State = OrderCard.State<Confirmation>
    typealias Event = OrderCard.Event<Confirmation>
    typealias Config = OrderCardViewConfig
}

private extension OrderCardView {
    
    func loadingProductView() -> some View {
        
        ProductView(
            product: .sample,
            isLoading: true,
            config: config.product,
            makeIconView: { _ in EmptyView() }
        )
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
            factory.makeConfirmationView(confirmation)
        }
    }
    
    func coreFormView(
        _ form: Form<Confirmation>
    ) -> some View {
        
        VStack(spacing: config.formSpacing) {
            
            productView(form.product)
            (state.form?.selector).map(selectorView)
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
            config: config.product,
            makeIconView: { factory.makeIconView($0) }
        )
        .rounded(config.roundedConfig)
    }
    
    func selectorView(
        selector: SelectorComponent.Selector<Product>
    ) -> some View {
        
        factory.makeSelectorView(selector) { event(.selector($0)) }
            .rounded(config.roundedConfig)
    }
    
    func messageView(
        _ messages: Messages
    ) -> some View {
        
        // TODO: fix: message has link
        MessageView(
            state: messages,
            event: { event(.setMessages($0)) },
            config: config.messages
        )
        .rounded(config.roundedConfig)
    }
}

private extension Product {
    
    static let sample: Self = .init(
        image: "image", 
        typeText: "typeText",
        header: "header",
        subtitle: "subtitle",
        orderTitle: "orderTitle",
        serviceTitle: "serviceTitle"
    )
}
