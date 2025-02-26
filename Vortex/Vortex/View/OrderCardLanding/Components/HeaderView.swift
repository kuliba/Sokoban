//
//  HeaderView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 03.12.2024.
//

import SwiftUI

struct HeaderView: View {
    
    let model: HeaderViewModel
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            model.backgroundImage
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            VStack(spacing: 26) {
                
                Text(model.title)
                    .font(.marketingH0B40X480())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 20) {
                    
                    ForEach(model.options) { option in
                        
                        HStack(alignment: .center, spacing: 5) {
                            
                            Circle()
                                .foregroundStyle(.textSecondary)
                                .frame(width: 5, height: 5, alignment: .center)
                            
                            Text(option)
                                .frame(maxWidth: 150, alignment: .leading)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.trailing, 15)
        }
    }
}

struct HeaderViewModel {
    
    let title: String
    let options: [String]
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
                    backgroundImage: Image("orderCardLanding")
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
                )
            )
            .background(.mainColorsGrayLightest)
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
                )
            )
            .background(.mainColorsGrayLightest)
            .cornerRadius(12)
            .padding(.horizontal, 15)
            
            ButtonSimpleView(viewModel: .init(
                title: "Продолжить",
                style: .red,
                action: {}
            ))
            .frame(height: 56, alignment: .center)
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
                    ])
            )
            .padding(.horizontal, 15)
        }
    }
}
