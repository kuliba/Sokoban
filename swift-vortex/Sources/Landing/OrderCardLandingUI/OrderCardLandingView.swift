//
//  LandingView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 05.12.2024.
//

import SwiftUI

public struct OrderCardLandingView: View {
    
    public typealias State = LandingState
    public typealias Config = OrderCardLandingViewConfig
    
    private let state: State
    private let config: Config
    
    public init(
        state: State,
        config: Config
    ) {
        self.state = state
        self.config = config
    }
    
    public var body: some View {
        
        LazyVStack(spacing: 16) {
            
            HeaderView(
                model: state.headerViewModel,
                config: config.headerConfig
            )
            
            OrderCardVerticalList(
                model: state.conditions,
                config: config.orderCardVerticalConfig
            )
            .background(.gray)
            .cornerRadius(12)
            .padding(.horizontal, 15)
            .padding(.top, 76)
            
            OrderCardVerticalList(
                model: state.security,
                config: config.orderCardVerticalConfig
            )
            .background(.gray)
            .cornerRadius(12)
            .padding(.horizontal, 15)
            
            DropDownList(
                viewModel: state.dropDownList,
                config: config.dropDownListConfig
            )
            .padding(.horizontal, 15)
        }
    }
}

#Preview {
    
    OrderCardLandingView(state: .init(
        headerViewModel: .init(
            title: "Карта МИР «Все включено»",
            options: [
                "кешбэк до 10 000 ₽ в месяц",
                "5% выгода при покупке топлива",
                "5% на категории сезона",
                "от 0,5% до 1% кешбэк на остальные покупки**"
            ],
            horizontList: .init(
                title: "Скидки и переводы",
                items: [
                    .init(title: "СПБ", image: nil),
                    .init(title: "За рубеж", image: nil),
                    .init(title: "ЖКХ", image: nil),
                    .init(title: "Налоги", image: nil)
                ]
            ),
            backgroundImage: Image("orderCardLanding")
        ),
        conditions: .init(
            title: "Выгодные условия",
            items: [
                .init(
                    title: "0 ₽",
                    subtitle: "Условия обслуживания",
                    image: nil
                ),
                .init(
                    title: "До 35%",
                    subtitle: "Кешбэк и скидки",
                    image: nil
                ),
                .init(
                    title: "Кешбэк 5%",
                    subtitle: "На востребованные категории",
                    image: nil
                ),
                .init(
                    title: "Кешбэк 5%",
                    subtitle: "На топливо и 3% кешбэк на кофе",
                    image: nil
                ),
                .init(
                    title: "8% годовых",
                    subtitle: "При сумме остатка от 500 001 ₽ ",
                    image: nil
                )
            ]
        ),
        security: .init(
            title: "Безопасность",
            items: [
                .init(
                    title: "Ваши средства застрахованы в АСВ",
                    subtitle: "Банк входит в систему страхования вкладов Агентства по страхованию вкладов",
                    image: nil
                ),
                .init(
                    title: "Безопасные платежи в Интернете (3-D Secure)",
                    subtitle: "3-D Secure — технология, предназначенная для повышения безопасности расчетов",
                    image: nil
                ),
                .init(
                    title: "Блокировка подозрительных операций",
                    subtitle: "Банк производит мониторинг и предотвращение подозрительных операций по картам",
                    image: nil
                )
            ]
        ),
        dropDownList: .init(
            title: "Часто задаваемые вопросы",
            items: [
                .init(
                    title: "Как повторно подключить подписку?",
                    description: "тест"
                ),
                .init(
                    title: "Как начисляются проценты?",
                    description: "тесттесттесттесттесттесттесттест"
                ),
                .init(
                    title: "Какие условия бесплатного обслуживания?",
                    description: ""
                )
            ]
        )
    ), config: .init(
        headerConfig: .init(
            title: .init(
                textFont: .body,
                textColor: .black
            ),
            optionPlaceholder: .black,
            cardHorizontalBackground: .black,
            cardHorizontListConfig: .init(
                title: .init(textFont: .body, textColor: .black),
                itemConfig: .init(textFont: .body, textColor: .black)
            )
        ),
        orderCardHorizontalConfig: .init(
            title: .init(textFont: .body, textColor: .black),
            itemConfig: .init(textFont: .body, textColor: .black)
        ),
        orderCardVerticalConfig: .init(
            title: .init(textFont: .body,textColor: .black),
            itemTitle: .init(textFont: .body, textColor: .red),
            itemSubTitle: .init(textFont: .body, textColor: .blue)
        ),
        dropDownListConfig: .init(
            title: .init(textFont: .body, textColor: .black),
            itemTitle: .init(textFont: .body, textColor: .red),
            backgroundColor: .black
        )
    ))
}
