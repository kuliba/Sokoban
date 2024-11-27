//
//  OrderSavingsAccountView.swift
//
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import PaymentComponents
import SwiftUI
import SharedConfigs

struct OrderSavingsAccountView: View {
    
    let state: OrderSavingsAccountState
    let event: (Event) -> Void
    let config: Config
    let factory: Factory
    
    private let coordinateSpace: String
    
    @State private(set) var isShowHeader = false
    @State private(set) var isShowingProducts = false
    
    init(
        state: OrderSavingsAccountState,
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
    
    var body: some View {
        
        // MARK: - remove `if #available` after update platforms in package
        
        if #available(iOS 15.0, *) {
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: config.padding) {
                    order()
                    income()
                    topUp()
                    if isShowingProducts {
                        products()
                    }
                }
                .padding(.horizontal, config.padding)
            }
            .coordinateSpace(name: coordinateSpace)
            .toolbar(content: toolbarContent)
            .safeAreaInset(edge: .bottom, spacing: 0, content: footer)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
        } else {
            Text("Only ios 15.0")
        }
    }
    
    @ViewBuilder
    private func footer() -> some View {
        if isShowingProducts {
            amount()
        } else {
            openButton()
        }
    }
    
    @ViewBuilder
    private func amount() -> some View {
        // TODO: move to state, add config
        var amount = Amount(title: "", value: 0, button: .init(title: "Продолжить", isEnabled: true))
        
        AmountView(
            amount: amount,
            event: {
                switch $0 {
                case let .edit(newValue):
                    amount = Amount(title: "", value: newValue, button: .init(title: "Продолжить", isEnabled: true))
                    
                case .pay:
                    print("Сумма пополнения \(amount.value)")
                }
            },
            currencySymbol: state.currency.symbol,
            config: config.amount,
            infoView: {
                HStack {
                    "Без комиссии".text(withConfig: .init(textFont: .system(size: 14), textColor: .gray))
                    
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
            })
    }
    
    private func openButton() -> some View {
        
        Button(action: { event(.continue) }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: config.openButton.cornerRadius)
                    .foregroundColor(config.openButton.background)
                config.openButton.label.text(withConfig: config.openButton.title)
            }
        })
        .padding(.horizontal)
        .frame(height: config.openButton.height)
        .frame(maxWidth: .infinity)
    }
    
    private func orderHeader() -> some View {
        
        VStack(spacing: 0) {
            
            state.header.title.text(withConfig: config.order.header.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            state.header.subtitle.text(withConfig: config.order.header.subtitle)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func orderOption(
        title: String,
        subtitle: String
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            title.text(withConfig: config.order.options.config.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                config.order.image
                    .frame(config.order.imageSize)
                subtitle.text(withConfig: config.order.options.config.subtitle)
            }
        }
    }
    
    private func orderOptions() -> some View {
        
        VStack(alignment: .leading) {
            
            orderOption(title: config.order.options.headlines.open, subtitle: "\(state.fee.openAndMaintenance)")
            orderOption(title: config.order.options.headlines.service, subtitle: "\(state.fee.subscription.value)" + "\(state.fee.subscription.period)")
        }
    }
    
    private func order() -> some View {
        
        VStack {
            
            orderHeader()
            
            HStack(alignment:.top, spacing: config.padding) {
                
                factory.makeIconView(state.designMd5hash)
                    .aspectRatio(contentMode: .fit)
                    .frame(config.order.card)
                
                orderOptions()
            }
        }
        .modifier(ViewWithBackgroundCornerRadiusAndPaddingModifier(config.background, config.cornerRadius, config.padding))
    }
    
    private func incomeInfo() -> some View {
        
        VStack(alignment: .leading) {
            
            config.income.title.text.text(withConfig: config.income.title.config)
                .frame(maxWidth: .infinity, alignment: .leading)
            state.income.text(withConfig: config.income.subtitle)
        }
    }
    
    private func income() -> some View {
        
        HStack(spacing: config.padding) {
            config.income.image
                .frame(config.income.imageSize)
            incomeInfo()
        }
        .modifier(ViewWithBackgroundCornerRadiusAndPaddingModifier(config.background, config.cornerRadius, config.padding))
    }
    
    private func infoWithToggle() -> some View {
        
        HStack(spacing: config.padding) {
            VStack {
                config.topUp.title.text.text(withConfig: config.topUp.title.config)
                    .frame(maxWidth: .infinity, alignment: .leading)
                config.topUp.subtitle.text.text(withConfig: config.topUp.subtitle.config)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Toggle("", isOn: $isShowingProducts)
                .toggleStyle(TopUpToggleStyle(config: config.topUp.toggle))
        }
    }
    
    private func topUp() -> some View {
        
        HStack(alignment: .top, spacing: config.padding) {
            
            config.income.image
                .frame(config.income.imageSize)
            VStack(alignment: .leading) {
                infoWithToggle()
                config.topUp.description.text.text(withConfig: config.topUp.description.config)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .modifier(ViewWithBackgroundCornerRadiusAndPaddingModifier(config.background, config.cornerRadius, config.padding))
    }
    
    private func products() -> some View {
        VStack {
            // TODO: add products
            Text("Products")
        }
        .modifier(ViewWithBackgroundCornerRadiusAndPaddingModifier(config.background, config.cornerRadius, config.padding))
    }
    
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        
        ToolbarItem(placement: .principal) {
            header()
        }
        ToolbarItem(placement: .navigationBarLeading) {
            backButton()
        }
    }
    
    private func backButton() -> some View {
        Button(action: { event(.dismiss) }) { config.backImage }
    }
    
    private func header() -> some View {
        config.header.text.text(withConfig: config.header.config, alignment: .center)
    }
}

private struct ViewWithBackgroundCornerRadiusAndPaddingModifier: ViewModifier {
    
    let background: Color
    let cornerRadius: CGFloat
    let padding: CGFloat
    
    init(_ background: Color, _ cornerRadius: CGFloat, _ padding: CGFloat) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.all, padding)
            .background(background)
            .cornerRadius(cornerRadius)
    }
}

extension OrderSavingsAccountView {
    
    typealias Event = OrderSavingsAccountEvent
    typealias Config = OrderSavingsAccountConfig
    typealias Factory = ImageViewFactory
}

#Preview {
    
    NavigationView {
        OrderSavingsAccountView(
            state: .preview,
            event: {
                switch $0 {
                case .continue:
                    print("Открыть накопительный счет")
                case .dismiss:
                    print("Назад")
                }
            },
            config: .preview,
            factory: .default)
    }
}
