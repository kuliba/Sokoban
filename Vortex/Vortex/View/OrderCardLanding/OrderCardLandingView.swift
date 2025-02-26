//
//  LandingView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 05.12.2024.
//

import SwiftUI

struct LandingState {
    
    let headerViewModel: HeaderViewModel
    let conditions: OrderCardVerticalListViewModel
    let security: OrderCardVerticalListViewModel
    let dropDownList: DropDownListViewModel
    let buttonViewModel: ButtonSimpleView.ViewModel
}

struct OrderCardLandingView: View {
    
    typealias State = LandingState
    
    let state: State
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            LazyVStack(spacing: 16) {
                
                HeaderView(model: state.headerViewModel)
                
                OrderCardVerticalList(model: state.conditions)
                    .background(.mainColorsGrayLightest)
                    .cornerRadius(12)
                    .padding(.horizontal, 15)
                    .padding(.top, 76)
                
                OrderCardVerticalList(model: state.security)
                    .background(.mainColorsGrayLightest)
                    .cornerRadius(12)
                    .padding(.horizontal, 15)
                
                ButtonSimpleView(viewModel: state.buttonViewModel)
                    .frame(height: 56, alignment: .center)
                    .padding(.horizontal, 15)
                
                DropDownList(viewModel: state.dropDownList)
                    .padding(.horizontal, 15)
            }
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
        ),
        buttonViewModel: .init(
            title: "Продолжить",
            style: .red,
            action: {}
        )
    ))
}
