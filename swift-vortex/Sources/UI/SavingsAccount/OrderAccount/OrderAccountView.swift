//
//  OrderAccountView.swift
//
//
//  Created by Andryusina Nataly on 09.02.2025.
//

import LoadableState
import SwiftUI
import UIPrimitives

public struct OrderAccountView<Confirmation, ConfirmationView, ProductSelectView>: View
where ConfirmationView: View,
      ProductSelectView: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    let factory: ListImageViewFactory
    // TODO: move to factory, rename factory
    let confirmationView: (Confirmation) -> ConfirmationView
    let productSelectView: () -> ProductSelectView

    private let coordinateSpace: String
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        config: Config,
        factory: ListImageViewFactory,
        @ViewBuilder confirmationView: @escaping (Confirmation) -> ConfirmationView,
        @ViewBuilder productSelectView: @escaping () -> ProductSelectView,
        coordinateSpace: String = "orderScroll"
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.factory = factory
        self.confirmationView = confirmationView
        self.productSelectView = productSelectView
        self.coordinateSpace = coordinateSpace
    }
    
    public var body: some View {
        
        switch state.loadableForm {
        case .loading(nil):
            loadingProductView(true)
                .frame(maxHeight: .infinity, alignment: .top)
            
        case .loaded(nil), .loaded(.failure):
            loadingProductView(false, true)
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
    
    func loadingProductView(
        _ isLoading: Bool,
        _ isFailure: Bool = false
    ) -> some View {
      
        VStack(spacing: config.padding) {
            
            ProductView(
                data: .sample,
                config: config,
                makeIconView: { _ in EmptyView() },
                isLoading: isLoading
            )
            .rounded(config.roundedConfig)
            
            income(income: "", isLoading)
            topUpView(.init(isOn: false), isLoading, isFailure)
        }
    }
    
    @ViewBuilder
    func formView(
        _ form: Form<Confirmation>
    ) -> some View {
        
        VStack(spacing: config.padding) {
            
            coreFormView(form)
            confirmationView(form.confirmation)
        }
        .padding(.vertical, config.padding)
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
                
            case .otp:
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
            income(income: form.constants.income, false)
            topUpView(topUp(form), false, false)
            
            if form.topUp.isOn {
                productSelectView()
                    .disabled(!form.topUp.isShowFooter)
                
                if !form.topUp.isShowFooter {
                    topUpInfo()
                }
            }
        }
        .disabled(state.hasConfirmation)
    }
    
    private func topUpInfo() -> some View {
        
        VStack(alignment: .leading, spacing: config.padding / 2 ) {
            
            HStack {
                config.topUp.amount.amount.text.text(withConfig: config.topUp.amount.amount.config)
                    .frame(maxWidth: .infinity, alignment: .leading)
                "\(amount) \(currencyCode)".text(withConfig: config.topUp.amount.value)
            }
            HStack {
                config.topUp.amount.fee.text.text(withConfig: config.topUp.amount.fee.config)
                    .frame(maxWidth: .infinity, alignment: .leading)
                "0 \(currencyCode)".text(withConfig: config.topUp.amount.value)
            }
        }
        .modifier(ViewWithBackgroundCornerRadiusAndPaddingModifier(config.background, config.cornerRadius, config.padding))
    }

    var currencyCode: String {
        state.form?.constants.currency.symbol ?? ""
    }
    
    var amount: String {
        if let amount = state.form?.amountValue { return "\(amount)"}
        return ""
    }

    func productView(
        _ product: Product
    ) -> some View {
        
        ProductView(
            data: product,
            config: config,
            makeIconView: factory.makeIconView, 
            isLoading: false
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
    
    func income(
        income: String,
        _ isLoading: Bool = false
    ) -> some View {
        
        HStack(spacing: config.padding) {
            if income.isEmpty {
                Circle()
                    .fill(config.placeholder)
                    .frame(config.income.imageSize)
                    .shimmering(active: isLoading)
            } else {
                config.income.image
                    .renderingMode(.template)
                    .foregroundColor(.gray)
                    .frame(config.income.imageSize)
            }
            incomeInfo(income: income, isLoading: isLoading)
        }
        .rounded(config.roundedConfig)
    }
    
    private func incomeInfo(
        income: String,
        isLoading: Bool = false
    ) -> some View {
        
        VStack(alignment: .leading) {
            
            config.income.title.text.string(isLoading || income.isEmpty)
                .text(withConfig: config.income.title.config)
                .modifier(placeholderModifier(income.isEmpty, isLoading))

            income.text(withConfig: config.income.subtitle)
                .modifier(ShimmeringModifier(isLoading, config.shimmering))
                .background(income.isEmpty ? config.placeholder : .clear)
                .cornerRadius(config.cornerRadius)
        }
    }
    
    private func placeholderModifier(
        _ isFailure: Bool,
        _ isLoading: Bool
    ) -> PlaceholderModifier {
        
        .init(
            colors: config.colors,
            cornerRadius: config.cornerRadius,
            isFailure: isFailure,
            isLoading: isLoading
        )
    }

    func topUp(
        _ form: Form<Confirmation>
    ) -> TopUp {
        
        .init(
            isOn: form.topUp.isOn
        )
    }

    func topUpView(
        _ topUp: TopUp,
        _ isLoading: Bool,
        _ isFailure: Bool
    ) -> some View {
        
        TopUpView(
            state: topUp,
            event: { event(.setMessages($0)) },
            config: config.topUpConfig, 
            isLoading: isLoading,
            isFailure: isFailure
        )
        .rounded(config.roundedConfig)
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

private extension OrderSavingsAccountConfig {
    
    var topUpConfig: TopUpViewConfig {
        .init(
            description: topUp.description,
            icon: topUp.image,
            iconSize: income.imageSize,
            placeholder: placeholder,
            spacing: padding,
            subtitle: topUp.subtitle,
            title: topUp.title,
            toggle: topUp.toggle, 
            shimmering: shimmering
        )
    }
}

extension OrderSavingsAccountConfig {
    
    var colors: PlaceholderModifier.Colors {
        .init(
            placeholder: placeholder,
            shimmering: shimmering
        )
    }
}
