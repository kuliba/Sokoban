//
//  OrderSavingsAccountView.swift
//
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import PaymentComponents
import SwiftUI
import SharedConfigs
import LinkableText

struct OrderSavingsAccountView<OTPView, ProductPicker>: View
where OTPView: View,
      ProductPicker: View {
    
    let state: OrderSavingsAccountState
    let event: (Event) -> Void
    let config: Config
    let factory: Factory
    let viewFactory: ViewFactory<OTPView, ProductPicker>
    
    private let coordinateSpace: String
    
    @State private(set) var isChecking = true
    @State private(set) var isShowHeader = false
    @State private(set) var isShowingProducts = false
    
    init(
        state: OrderSavingsAccountState,
        event: @escaping (Event) -> Void,
        config: Config,
        factory: Factory,
        viewFactory: ViewFactory<OTPView, ProductPicker>,
        coordinateSpace: String = "orderScroll"
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.factory = factory
        self.coordinateSpace = coordinateSpace
        self.viewFactory = viewFactory
    }
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: config.padding) {
                order()
                income()
                topUp()
                if isShowingProducts {
                    products()
                }
                otp()
                condition()
            }
            .padding(.horizontal, config.padding)
        }
        .coordinateSpace(name: coordinateSpace)
        .toolbar(content: toolbarContent)
        .safeAreaInset(edge: .bottom, spacing: 0, content: footer)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
    
    private func condition() -> some View {
        
        HStack(spacing: 0) {
            
            Button(action: { isChecking.toggle()
            }, label: {
                isChecking ? config.images.checkOn : config.images.checkOff
            })
            .frame(config.linkableTexts.checkBoxSize)
            
            LinkableTextView(taggedText: config.linkableTexts.condition, urlString: state.data.links.conditions, tag: config.linkableTexts.tag, handleURL: {_ in })
            LinkableTextView(taggedText: config.linkableTexts.tariff, urlString: state.data.links.tariff, tag: config.linkableTexts.tag, handleURL: {_ in })
            
            Spacer()
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
            currencySymbol: state.data.currency.symbol,
            config: config.amount,
            infoView: {
                HStack {
                    "Без комиссии".text(withConfig: .init(textFont: .system(size: 14), textColor: .gray))
                    
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
            })
    }
    
    @ViewBuilder
    private func openButton() -> some View {
        
        Button(action: { event(.continue) }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: config.openButton.cornerRadius)
                    .foregroundColor(isChecking ? config.openButton.background.active : config.openButton.background.inactive)
                config.openButton.label.text(withConfig: config.openButton.title)
            }
        })
        .padding(.horizontal)
        .frame(height: config.openButton.height)
        .disabled(!isChecking)
        .frame(maxWidth: .infinity)
    }
    
    private func orderHeader() -> some View {
        
        VStack(spacing: 0) {
            
            state.data.header.title.text(withConfig: config.order.header.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            state.data.header.subtitle.text(withConfig: config.order.header.subtitle)
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
            
            orderOption(title: config.order.options.headlines.open, subtitle: "\(state.data.fee.openAndMaintenance)")
            orderOption(title: config.order.options.headlines.service, subtitle: "\(state.data.fee.subscription.value)" + "\(state.data.fee.subscription.period)")
        }
    }
    
    private func order() -> some View {
        
        VStack {
            
            orderHeader()
            
            HStack(alignment:.top, spacing: config.padding) {
                
                factory.makeIconView(state.data.designMd5hash)
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
            state.data.income.text(withConfig: config.income.subtitle)
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
        viewFactory.makeProductPickerView()
            .modifier(ViewWithBackgroundCornerRadiusAndPaddingModifier(config.background, config.cornerRadius, config.padding))
    }
    
    private func otp() -> some View {
        viewFactory.makeOTPView()
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
        Button(action: { event(.dismiss) }) { config.images.back }
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

extension OrderSavingsAccountView
where OTPView == Text,
      ProductPicker == Text {
    
    static var preview: Self {
        
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
            factory: .default,
            viewFactory: .init(
                makeOTPView: { Text("Otp") }, 
                makeProductPickerView: { Text("Products") })
            )
    }
}

#Preview {
    
    NavigationView {
        OrderSavingsAccountView.preview
    }
}

