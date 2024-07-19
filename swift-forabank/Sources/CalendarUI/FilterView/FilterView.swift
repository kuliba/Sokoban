//
//  FilterView.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//


import SwiftUI

typealias Event = FilterEvent
typealias Config = FilterConfig

struct FilterView: View {

    typealias State = FilterState

    var state: State
    let event: (Event) -> Void
    let config: Config
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text(state.title)
                .font(.system(size: 18))
                .padding(.bottom, 10)
            
            TitleView(title: "Период")
            
            HStack {
                
                ForEach(state.periods, id: \.self) { period in
                    
                    Button(action: { event(.selectedPeriod) }) {
                        
                        Text(period)
                            .padding()
                            .background(state.selectedPeriod == period ? Color.black : Color.gray.opacity(0.2))
                            .foregroundColor(state.selectedPeriod == period ? Color.white : Color.black)
                            .frame(height: 32)
                            .cornerRadius(90)
                    }
                }
            }
            .padding(.bottom, 20)
            
            if !state.services.isEmpty {
                
                TitleView(title: "Движение средств")
                
                HStack {
                    
                    ForEach(state.transactions, id: \.self) { transaction in
                        
                        Button(action: { event(.selectedTransaction) }) {
                            
                            Text(transaction)
                                .padding()
                                .background(state.selectedTransaction == transaction ? config.button.selectBackgroundColor : config.button.notSelectedBackgroundColor)
                                .foregroundColor(state.selectedTransaction == transaction ? config.button.notSelectedBackgroundColor : config.button.selectForegroundColor)
                            
                                .frame(height: 32)
                                .cornerRadius(90)
                        }
                    }
                }
                .padding(.bottom, 20)
                
                TitleView(title: "Категории")
                
                WrapView(
                    data: state.services,
                    selectedItems: state.selectedServices
                )
                
            } else {
            
                ErrorView()
            }
            
            Spacer()
            
            ButtonsContainer(
                dismissAction: {
                    state.selectedPeriod = "Месяц"
                    state.selectedServices.removeAll()
                },
                clearOptionsAction: {}
            )
        }
        .padding()
    }
}

struct ButtonsContainer: View {

    let dismissAction: () -> Void
    let clearOptionsAction: () -> Void
    
    var body: some View {
        
        HStack(spacing: 8) {

            BottomButton(title: "Очистить", action: clearOptionsAction, config: .init(background: Color.gray.opacity(0.2), foreground: .black))

            BottomButton(title: "Применить", action: dismissAction, config: .init(background: Color.red, foreground: .white))

        }
    }
}

struct BottomButton: View {

    typealias Config = ButtonConfig
    
    let title: String
    let action: () -> Void
    let config: Config
    
    var body: some View {
        
        Button(action: action) {
            
            Text(title)
                .frame(maxWidth: .infinity, minHeight: 56)
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(12)
                .font(.system(size: 18))
        }
        
    }
    
    struct ButtonConfig {
        
        let background: Color
        let foreground: Color
    }
}

struct WrapView: View {
    
    let data: [String]
    var selectedItems: Set<String>
    
    var body: some View {
        
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return GeometryReader { geometry in
            
            ZStack(alignment: .topLeading) {
                
                ForEach(data, id: \.self) { service in
                    
                    ServiceButton(service: service, isSelected: selectedItems.contains(service)) {
                        if selectedItems.contains(service) {
//                            selectedItems.remove(service)
                        } else {
//                            selectedItems.insert(service)
                        }
                    }
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= dimension.height
                        }
                        
                        let result = width
                        if service == data.last! {
                            width = 0
                        } else {
                            width -= dimension.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if service == data.last! {
                            height = 0
                        }
                        return result
                    })
                }
            }
        }
    }
}

struct ServiceButton: View {
    
    let service: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text(service)
                .padding()
                .background(isSelected ? Color.black : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? Color.white : Color.black)
                .frame(height: 32)
                .cornerRadius(90)
        }
    }
}

extension FilterView {
 
    struct TitleView: View {
        
        let title: String
        
        var body: some View {
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .fontWeight(.medium)
                .padding(.bottom, 5)
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            FilterView(
                state: .init(
                    title: "Фильтры",
                    selectedServices: [],
                    periods: ["Неделя", "Месяц", "Выбрать период"],
                    transactions: ["Списание", "Пополнение"],
                    services: []
                ),
                event: { _ in },
                config: .init(button: .init(
                    selectBackgroundColor: Color.black,
                    notSelectedBackgroundColor: Color.gray.opacity(0.2),
                    selectForegroundColor: Color.white,
                    notSelectForegroundColor: Color.black
                ))
            )
            
//            FilterView(
//                title: "Фильтры",
//                periods: ["Неделя", "Месяц", "Выбрать период"],
//                transactions: ["Списание", "Пополнение"],
//                services: ["В другой банк", "Между своими", "ЖКХ", "Входящие СБП", "Выплата процентов", "Гос. услуги", "Дом, ремонт", "Ж/д билеты", "Закрытие вклада", "Закрытие счета", "Интернет, ТВ", "Заработная плата", "Потребительские кредиты"]
//            )
        }
    }
    
}
