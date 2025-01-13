//
//  OrderSavingsAccountView.swift
//
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import LinkableText
import PaymentComponents
import SharedConfigs
import SwiftUI
import ToggleComponent

struct OrderSavingsAccountView<AmountInfo, OTPView, ProductPicker>: View
where AmountInfo: View,
      OTPView: View,
      ProductPicker: View {
    
    let amountToString: AmountToString
    let state: OrderSavingsAccountState
    let event: (Event) -> Void
    let config: Config
    let factory: Factory
    let viewFactory: ViewFactory<AmountInfo, OTPView, ProductPicker>
    
    private let coordinateSpace: String
    
    @State private(set) var isShowHeader = false
    @State private(set) var isShowingProducts = false
    
    init(
        amountToString: @escaping AmountToString,
        state: OrderSavingsAccountState,
        event: @escaping (Event) -> Void,
        config: Config,
        factory: Factory,
        viewFactory: ViewFactory<AmountInfo, OTPView, ProductPicker>,
        coordinateSpace: String = "orderScroll"
    ) {
        self.amountToString = amountToString
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
                    state.openValue,
                    state.orderServiceOption
                ),
                needShimmering: data == nil
            )
            income(income: data?.income ?? "", data == nil)
            topUp(data == nil)
            if isShowingProducts {
                products()
            }
            if state.amountValue > 0, state.isShowingOTP {
                topUpInfo()
            }
            if state.isShowingOTP {
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
                Button(
                    action: { event(.consent) },
                    label: {
                        state.consent ? config.images.checkOn : config.images.checkOff
                    })
                .disabled(state.isShowingOTP)
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
        if isShowingProducts, !state.isShowingOTP {
            amount()
        } else {
            openButton()
        }
    }
    
    private func amount() -> some View {
        
        AmountView(
            amount: state.amountView,
            event: {
                switch $0 {
                case let .edit(newValue):
                    event(.amount(.edit(newValue)))
                    
                case .pay:
                    event(.amount(.pay))
                }
            },
            currencySymbol: state.currencyCode,
            config: config.amount,
            infoView: viewFactory.makeAmountInfoView
        )
    }
    
    private func openButton() -> some View {
        
        Button(
            action: { event(.continue) },
            label: {
                ZStack {
                    RoundedRectangle(cornerRadius: config.openButton.cornerRadius)
                        .foregroundColor(openButtonForegroundColor)
                    openButtonText
                }
            })
        .padding(.horizontal)
        .frame(height: config.openButton.height)
        .disabled(!(state.consent && state.data != nil))
        .frame(maxWidth: .infinity)
    }
    
    var openButtonForegroundColor: Color {
        
        (state.consent && state.data != nil) ? config.openButton.background.active : config.openButton.background.inactive
    }
    
    var openButtonText: some View {
        if state.isShowingOTP {
            config.openButton.labels.confirm.text(withConfig: config.openButton.title)
        } else {
            config.openButton.labels.open.text(withConfig: config.openButton.title)
        }
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
    
    private func topUpInfo() -> some View {
        
        VStack(alignment: .leading, spacing: config.padding / 2 ) {
            
            HStack {
                config.topUp.amount.amount.text.text(withConfig: config.topUp.amount.amount.config)
                    .frame(maxWidth: .infinity, alignment: .leading)
                amountToString(state.amountValue, state.currencyCode).text(withConfig: config.topUp.amount.value)
            }
            HStack {
                config.topUp.amount.fee.text.text(withConfig: config.topUp.amount.fee.config)
                    .frame(maxWidth: .infinity, alignment: .leading)
                "0 \(state.currencyCode)".text(withConfig: config.topUp.amount.value)
            }
        }
        .modifier(ViewWithBackgroundCornerRadiusAndPaddingModifier(config.background, config.cornerRadius, config.padding))
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
                .toggleStyle(ToggleComponentStyle(config: config.topUp.toggle))
                .disabled(state.isShowingOTP)
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
                config.topUp.image
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

extension OrderSavingsAccountView {
    
    typealias Event = OrderSavingsAccountEvent
    typealias Config = OrderSavingsAccountConfig
    typealias Factory = ImageViewFactory
    typealias AmountToString = (Decimal, String) -> String
}

private extension OrderSavingsAccountState {
    
    var orderServiceOption: String {
        
        guard let data else { return "" }
        
        return (data.fee.subscription.value == 0 || data.fee.subscription.period == "free")
        ? "Бесплатно"
        : "\(data.fee.subscription.value) \(currencyCode) " + period
    }
    
    var period: String {
        
        switch data?.fee.subscription.period {
        case "month": return "в месяц"
        case "year": return "в год"
        default: return ""
        }
    }
    
    var openValue: String {
        
        guard let data else { return "" }
        
        return data.fee.open == 0 ? "Бесплатно" : "\(data.fee.open) \(currencyCode)"
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
where AmountInfo == Text,
      OTPView == Text,
      ProductPicker == Text {
    
    static var placeholder: Self {
        
        OrderSavingsAccountView(
            amountToString: 
                { "\($0) \($1)" },
            state: .placeholder,
            event: {
                switch $0 {
                case .continue:
                    print("Открыть накопительный счет")
                    
                case .dismiss:
                    print("Назад")
                    
                case let .amount(amountEvent):
                    switch amountEvent {
                    case let .edit(newValue):
                        print("newValue \(newValue)")
                        
                    case .pay:
                        print("pay")
                    }
                case .consent:
                    print("consent")
                    
                }
            },
            config: .preview,
            factory: .default,
            viewFactory: .init(
                makeAmountInfoView: { Text("") },
                makeOTPView: { Text("Otp") },
                makeProductPickerView: { Text("Products") })
        )
    }
}

struct LandingUIView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            OrderSavingsAccountView.placeholder
        }
        .previewDisplayName("Placeholder")
        
        NavigationView {
            OrderSavingsAccountWrapperView.init(
                viewModel: .init(
                    initialState: .preview,
                    reduce: { state, event in
                        
                        var state = state
                        switch event {
                        case .dismiss:
                            print("dismiss")
                            
                        case .continue:
                            state.isShowingOTP = true
                            
                        case let .amount(amountEvent):
                            switch amountEvent {
                                
                            case let .edit(newValue):
                                state.amountValue = newValue
                                
                            case .pay:
                                state.isShowingOTP = true
                            }
                            
                        case .consent:
                            state.consent.toggle()
                        }
                        
                        return (state, .none)
                    },
                    handleEffect: {_,_ in }),
                config: .preview,
                imageViewFactory: .default)
        }
        .previewDisplayName("Value")
    }
}

// TODO: move to main target

import RxViewModel

struct OrderSavingsAccountWrapperView: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    private let config: Config
    private let imageViewFactory: ImageViewFactory
    
    init(
        viewModel: ViewModel,
        config: Config,
        imageViewFactory: ImageViewFactory
    ) {
        self.viewModel = viewModel
        self.config = config
        self.imageViewFactory = imageViewFactory
    }
    
    public var body: some View {
        
        RxWrapperView(
            model: viewModel,
            makeContentView: {
                OrderSavingsAccountView(
                    amountToString: {
                        let formatter = NumberFormatter.preview()
                        return (formatter.string(for: $0) ?? "") + " " + $1
                    },
                    state: $0,
                    event: $1,
                    config: config,
                    factory: imageViewFactory,
                    viewFactory: .init(
                        makeAmountInfoView: {
                            HStack {
                                "Без комиссии".text(withConfig: .init(textFont: .system(size: 14), textColor: .gray))
                                
                                Image(systemName: "info.circle")
                                    .foregroundColor(.gray)
                            }
                        },
                        makeOTPView: { Text("Otp") },
                        makeProductPickerView: { Text("Products") })
                )
            }
        )
    }
}

extension OrderSavingsAccountWrapperView {
    
    typealias ViewModel = OrderSavingsAccountViewModel
    typealias Config = OrderSavingsAccountConfig
}

typealias OrderSavingsAccountViewModel = RxViewModel<OrderSavingsAccountState, OrderSavingsAccountEvent, OrderSavingsAccountEffect>
