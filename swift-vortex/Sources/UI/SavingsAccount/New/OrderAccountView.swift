//
//  OrderAccountView.swift
//
//
//  Created by Andryusina Nataly on 09.02.2025.
//

import LoadableState
import SwiftUI
import UIPrimitives

public struct OrderAccountView<Confirmation, ConfirmationView>: View
where ConfirmationView: View{
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    let factory: ListImageViewFactory
    // TODO: move to factory, rename factory
    let confirmationView: (Confirmation) -> ConfirmationView
    
    private let coordinateSpace: String
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        config: Config,
        factory: ListImageViewFactory,
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
            makeIconView: { _ in EmptyView() }, 
            isLoading: true
        )
        .rounded(config.roundedConfig)
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
            
            productView(product(form))
        }
        .disabled(state.hasConfirmation)
    }
    
    func productView(
        _ product: Product
    ) -> some View {
        
        ProductView(
            data: product,
            config: config,
            makeIconView: factory.makeIconView, 
            isLoading: state.loadableForm.isLoading
        )
        .rounded(config.roundedConfig)
    }
    
    func product(
        _ form: Form<Confirmation>
    ) -> Product {
        
        .init(
            designMd5hash: form.constants.designMd5hash,
            header: .init(
                title: form.constants.header.title,
                subtitle: form.constants.header.subtitle),
            openValue: form.constants.openValue,
            orderServiceOption: form.constants.orderServiceOption)
    }
}

private extension Product {
    
    static let sample: Self = .init(designMd5hash: "", header: .init(title: "", subtitle: ""), openValue: "", orderServiceOption: "")
}

private extension OrderSavingsAccountConfig {
    
    var roundedConfig: RoundedConfig {
        
        RoundedConfig(padding: padding, cornerRadius: cornerRadius, background: background)
    }
}
