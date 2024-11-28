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
    
    // TODO: need move to State
    @State private(set) var isChecking = true
    @State private(set) var isShowHeader = false
    @State private(set) var isShowingOTP = false
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
            orderSavingsAccount(state.data)
        }
        .coordinateSpace(name: coordinateSpace)
        .toolbar(content: toolbarContent)
        .safeAreaInset(edge: .bottom, spacing: 0, content: footer)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
    
    private func orderSavingsAccount(
        _ data: OrderSavingsAccount?
    ) -> some View {
        
        VStack(spacing: config.padding) {
            order(
                designMd5hash: data?.designMd5hash ?? "",
                header: (data?.header.title ?? "", data?.header.subtitle ?? ""),
                orderOption: (
                    state.openAndMaintenance,
                    state.orderServiceOption
                ),
                needShimmering: data == nil
            )
            income(income: data?.income ?? "", data == nil)
            topUp(data == nil)
            if isShowingProducts {
                products()
            }
            if isShowingOTP {
                otp()
            }
            condition(data?.links)
        }
        .padding(.all, config.padding)
    }
    
    private func condition(
        _ links: OrderSavingsAccount.Links?
    ) -> some View {
        
        HStack(spacing: 0) {
            
            if links != nil {
                Button(action: { isChecking.toggle()
                }, label: {
                    isChecking ? config.images.checkOn : config.images.checkOff
                })
                .frame(config.linkableTexts.checkBoxSize)
            }
            
            if let links {
                
                LinkableTextView(taggedText: config.linkableTexts.condition, urlString: links.conditions, tag: config.linkableTexts.tag, handleURL: {_ in })
                    .minimumScaleFactor(0.9)
                LinkableTextView(taggedText: config.linkableTexts.tariff, urlString: links.tariff, tag: config.linkableTexts.tag, handleURL: {_ in })
                    .minimumScaleFactor(0.9)
            }
            Spacer()
        }
        .frame(height: 24)
        .modifier(ShimmeringModifier(links == nil, config.shimmering))
    }
    
    @ViewBuilder
    private func footer() -> some View {
        if isShowingProducts {
            amount(state.data?.currency.symbol ?? "")
        } else {
            openButton()
        }
    }
    
    @ViewBuilder
    private func amount(
        _ currencySymbol: String
    ) -> some View {
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
            currencySymbol: currencySymbol,
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
                    .foregroundColor((isChecking && state.data != nil) ? config.openButton.background.active : config.openButton.background.inactive)
                config.openButton.label.text(withConfig: config.openButton.title)
            }
        })
        .padding(.horizontal)
        .frame(height: config.openButton.height)
        .disabled(!(isChecking && state.data != nil))
        .frame(maxWidth: .infinity)
    }
    
    private func orderHeader(
        title: String,
        subtitle: String,
        needShimmering: Bool = false
    ) -> some View {
        
        VStack(spacing: 0) {
            
            title.text(withConfig: config.order.header.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 24)
                .modifier(ShimmeringModifier(needShimmering, config.shimmering))
            
            subtitle.text(withConfig: config.order.header.subtitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 16)
                .modifier(ShimmeringModifier(needShimmering, config.shimmering))
        }
    }
    
    private func orderOption(
        title: String,
        subtitle: String,
        _ needShimmering: Bool
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            title.text(withConfig: config.order.options.config.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .modifier(ShimmeringModifier(needShimmering, config.shimmering))
            
            HStack {
                if needShimmering {
                    Circle()
                        .fill(config.shimmering)
                        .frame(config.order.imageSize)
                        .shimmering()
                } else {
                    config.order.image
                        .frame(config.order.imageSize)
                }
                subtitle.text(withConfig: config.order.options.config.subtitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(ShimmeringModifier(needShimmering, config.shimmering))
            }
        }
    }
    
    private func orderOptions(
        open: String,
        service: String,
        needShimmering: Bool = false
    ) -> some View {
        
        VStack(alignment: .leading) {
            
            orderOption(
                title: config.order.options.headlines.open.string(needShimmering),
                subtitle: open,
                needShimmering
            )
            
            orderOption(title: config.order.options.headlines.service.string(needShimmering),
                        subtitle: service,
                        needShimmering
            )
        }
    }
    
    private func order(
        designMd5hash: String,
        header: (title: String, subtitle: String),
        orderOption: (open: String, service: String),
        needShimmering: Bool = false
    ) -> some View {
        
        VStack {
            
            orderHeader(title: header.title, subtitle: header.subtitle, needShimmering: needShimmering)
            
            HStack(alignment:.top, spacing: config.padding) {
                
                product(designMd5hash: designMd5hash, needShimmering)
                
                orderOptions(
                    open: orderOption.open,
                    service: orderOption.service,
                    needShimmering: needShimmering
                )
            }
        }
        .modifier(ViewWithBackgroundCornerRadiusAndPaddingModifier(config.background, config.cornerRadius, config.padding))
    }
    
    @ViewBuilder
    private func product(
        designMd5hash: String,
        _  needShimmering: Bool
    ) -> some View {
        
        if needShimmering {
            RoundedRectangle(cornerRadius: 8)
                .fill(config.shimmering)
                .frame(config.order.card)
                .shimmering()
        }
        else {
            factory.makeIconView(designMd5hash)
                .aspectRatio(contentMode: .fit)
                .frame(config.order.card)
        }
    }
    
    private func incomeInfo(
        income: String,
        needShimmering: Bool = false
    ) -> some View {
        
        VStack(alignment: .leading) {
            
            config.income.title.text.string(needShimmering).text(withConfig: config.income.title.config)
                .frame(maxWidth: .infinity, alignment: .leading)
                .modifier(ShimmeringModifier(needShimmering, config.shimmering))
            income.text(withConfig: config.income.subtitle)
                .modifier(ShimmeringModifier(needShimmering, config.shimmering))
        }
    }
    
    private func income(
        income: String,
        _ needShimmering: Bool = false
    ) -> some View {
        
        HStack(spacing: config.padding) {
            if needShimmering {
                Circle()
                    .fill(config.shimmering)
                    .frame(config.income.imageSize)
                    .shimmering()
            } else {
                config.income.image
                    .frame(config.income.imageSize)
            }
            incomeInfo(income: income, needShimmering: needShimmering)
        }
        .modifier(ViewWithBackgroundCornerRadiusAndPaddingModifier(config.background, config.cornerRadius, config.padding))
    }
    
    private func infoWithToggle(
        _ needShimmering: Bool = false
    ) -> some View {
        
        HStack(spacing: config.padding) {
            VStack {
                config.topUp.title.text.string(needShimmering).text(withConfig: config.topUp.title.config)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(ShimmeringModifier(needShimmering, config.shimmering))
                
                config.topUp.subtitle.text.string(needShimmering).text(withConfig: config.topUp.subtitle.config)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(ShimmeringModifier(needShimmering, config.shimmering))
                
            }
            Toggle("", isOn: $isShowingProducts)
                .toggleStyle(TopUpToggleStyle(config: config.topUp.toggle))
            
        }
    }
    
    private func topUp(
        _ needShimmering: Bool = false
    ) -> some View {
        
        HStack(alignment: .top, spacing: config.padding) {
            
            if needShimmering {
                Circle()
                    .fill(config.shimmering)
                    .frame(config.income.imageSize)
                    .shimmering()
            }
            else {
                config.income.image
                    .frame(config.income.imageSize)
                    .modifier(ShimmeringModifier(needShimmering, config.shimmering))
            }
            VStack(alignment: .leading) {
                infoWithToggle(needShimmering)
                    .disabled(needShimmering)
                config.topUp.description.text.string(needShimmering).text(withConfig: config.topUp.description.config)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(ShimmeringModifier(needShimmering, config.shimmering))
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

struct ShimmeringModifier: ViewModifier {
    
    let needShimmering: Bool
    let color: Color
    
    init(
        _ needShimmering: Bool = false,
        _ color: Color
    ) {
        self.needShimmering = needShimmering
        self.color = color
    }
    
    func body(content: Content) -> some View {
        if needShimmering {
            content
                .background(color)
                .cornerRadius(90)
                .shimmering()
        }
        else {
            content
        }
    }
}

extension OrderSavingsAccountView {
    
    typealias Event = OrderSavingsAccountEvent
    typealias Config = OrderSavingsAccountConfig
    typealias Factory = ImageViewFactory
}

private extension OrderSavingsAccountState {
    
    var orderServiceOption: String {
        
        guard let data else { return "" }
        
        return "\(data.fee.subscription.value)" + "\(data.fee.subscription.period)"
    }
    
    var openAndMaintenance: String {
        
        guard let data else { return "" }
        
        return "\(data.fee.openAndMaintenance)"
    }
}

private extension String {
    
    func string(
        _ needShimmering: Bool
    ) -> String {
        needShimmering ? "" : self
    }
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
    
    static var placeholder: Self {
        
        OrderSavingsAccountView(
            state: .placeholder,
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

struct LandingUIView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            OrderSavingsAccountView.preview
        }
        .previewDisplayName("With data")
        
        NavigationView {
            OrderSavingsAccountView.placeholder
        }
        .previewDisplayName("Placeholder")
    }
}

