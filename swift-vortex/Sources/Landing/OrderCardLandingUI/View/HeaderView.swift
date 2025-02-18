//
//  HeaderView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 03.12.2024.
//

import SwiftUI

struct HeaderView: View {
    
    typealias Model = HeaderViewModel
    typealias Config = HeaderViewConfig
    
    let model: Model
    let config: Config
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            model.backgroundImage
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            textView()
                .padding(.leading, 16)
                .padding(.trailing, 15)
        }
    }
}

private extension HeaderView {
    
    func textView() -> some View {
        
        //TODO: constants extract to config
        VStack(spacing: 26) {
            
            model.title.text(withConfig: config.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 20) {
                
                ForEach(model.options, id: \.self, content: optionView)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            OrderCardHorizontalList(model: model.horizontList, config: config.cardHorizontListConfig)
                .background(config.cardHorizontalBackground)
                .cornerRadius(12)
                .offset(y: 76)
        }
    }
    
    func optionView(
        _ option: String
    ) -> some View {
        
        //TODO: constants extract to config
        HStack(alignment: .center, spacing: 5) {
            
            Circle()
                .foregroundStyle(config.optionPlaceholder)
                .frame(width: 5, height: 5, alignment: .center)
            
            Text(option)
                .frame(maxWidth: 150, alignment: .leading)
        }
    }
}

struct HeaderViewModel {
    
    let title: String
    let options: [String]
    let horizontList: OrderCardHorizontalListViewModel
    let backgroundImage: Image
}

#Preview {
    
    ScrollView(.vertical, showsIndicators: false) {
        
        LazyVStack(spacing: 16) {
            
            HeaderView(
                model: .init(
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
                config: .init(
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
                )
            )
            
            OrderCardVerticalList(
                model: .init(
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
                config: .init(
                    title: .init(textFont: .body,textColor: .black),
                    itemTitle: .init(textFont: .body, textColor: .red),
                    itemSubTitle: .init(textFont: .body, textColor: .blue)
                )
            )
            .background(.gray)
            .cornerRadius(12)
            .padding(.horizontal, 15)
            .padding(.top, 76)
            
            OrderCardVerticalList(
                model: .init(
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
                ), config: .init(
                    title: .init(textFont: .body, textColor: .black),
                    itemTitle: .init(textFont: .headline, textColor: .red),
                    itemSubTitle: .init(textFont: .body, textColor: .blue)
                )
            )
            .background(.gray)
            .cornerRadius(12)
            .padding(.horizontal, 15)
            
            DropDownList(
                viewModel: .init(
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
                ),
                config: .init(
                    title: .init(textFont: .body, textColor: .black),
                    itemTitle: .init(textFont: .body, textColor: .red),
                    backgroundColor: .black
                )
            )
            .padding(.horizontal, 15)
        }
    }
}
