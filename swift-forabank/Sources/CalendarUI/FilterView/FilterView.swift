//
//  FilterView.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//


import SwiftUI
import SharedConfigs

public typealias Event = FilterEvent
public  typealias Config = FilterConfig

public struct FilterView: View {
    
    public typealias State = FilterState
    
    var state: State
    let event: (Event) -> Void
    let config: Config
    
    let clearOptionsAction: () -> Void
    let dismissAction: () -> Void
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        config: Config,
        clearOptionsAction: @escaping () -> Void,
        dismissAction: @escaping () -> Void
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.clearOptionsAction = clearOptionsAction
        self.dismissAction = dismissAction
    }
    
    public var body: some View {
        
        VStack(alignment: .leading) {
            
            Text(state.title)
                .font(.system(size: 18))
                .padding(.bottom, 10)
            
            TitleView(config: config.periodTitle)
            
            HStack {
                
                ForEach(state.periods, id: \.self) { period in
                    
                    Button(action: { event(.selectedPeriod(period)) }) {
                        
                        Text(period)
                            .padding()
                            .background(state.selectedPeriod == period ? Color.black : .gray.opacity(0.2))
                            .foregroundColor(state.selectedPeriod == period ? Color.white : Color.black)
                            .frame(height: 32)
                            .cornerRadius(90)
                    }
                }
            }
            .padding(.bottom, 20)
            
            if !state.services.isEmpty {
                
                TitleView(config: config.transferTitle)
                
                HStack {
                    
                    ForEach(state.transactions, id: \.self) { transaction in
                        
                        Button(action: { event(.selectedTransaction(transaction)) }) {
                            
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
                
                TitleView(config: config.categoriesTitle)
                
                WrapView(
                    data: state.services,
                    selectedItems: state.selectedServices,
                    serviceButtonTapped: {},
                    config: .init(title: "", titleConfig: .init(textFont: .callout, textColor: .red))
                )
            }
            
            Spacer()
            
            ButtonsContainer(
                dismissAction: dismissAction,
                clearOptionsAction: clearOptionsAction,
                config: config.buttonsContainerConfig
            )
        }
        .padding()
    }
}

public struct ButtonsContainer: View {
    
    let dismissAction: () -> Void
    let clearOptionsAction: () -> Void
    
    let config: Config
    
    public var body: some View {
        
        HStack(spacing: 8) {
            
            BottomButton(
                title: config.clearButtonTitle,
                action: clearOptionsAction,
                config: .init(
                    background: .gray.opacity(0.2),
                    foreground: .black
                ))
            
            BottomButton(
                title: config.applyButtonTitle,
                action: dismissAction,
                config: .init(
                    background: .red,
                    foreground: .white
                ))
            
        }
    }
    
    public struct Config {
        
        let clearButtonTitle: String
        let applyButtonTitle: String
        
        public init(
            clearButtonTitle: String,
            applyButtonTitle: String
        ) {
            self.clearButtonTitle = clearButtonTitle
            self.applyButtonTitle = applyButtonTitle
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
    let serviceButtonTapped: () -> Void
    let config: ServiceButton.Config
    
    var body: some View {
        
        return GeometryReader { geometry in
            
            ZStack(alignment: .topLeading) {
                
                ForEach(data, id: \.self) { service in
                    
                    ServiceButton(
                        state: .init(isSelected: selectedItems.contains(service)),
                        action: serviceButtonTapped,
                        config: config
                    )
                    .padding([.horizontal, .vertical], 4)
                    .serviceButtonAlignmentGuide(data: data, service: service, geometry: geometry)
                }
            }
        }
    }
}

extension View {
    
    @ViewBuilder func serviceButtonAlignmentGuide(
        data: [String],
        service: String,
        geometry: GeometryProxy
    ) -> some View {
        
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        self
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

struct ServiceButton: View {
    
    let state: State
    let action: () -> Void
    let config: Config
    
    var body: some View {
        
        Button(action: action) {
            
            config.title.text(withConfig: config.titleConfig)
                .padding()
                .background(state.isSelected ? Color.black : .gray.opacity(0.2))
                .foregroundColor(state.isSelected ? .white : .black)
                .frame(height: 32)
                .cornerRadius(90)
        }
    }
    
    struct State {
        
        let isSelected: Bool
    }
    
    struct Config {
        
        let title: String
        let titleConfig: TextConfig
    }
}

public extension FilterView {
    
    struct TitleView: View {
        
        let config: Config
        
        public var body: some View {
            
            config.title.text(withConfig: config.titleConfig)
                .padding(.bottom, 5)
        }
        
        public struct Config {
            
            let title: String
            let titleConfig: TextConfig
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
                config: .init(
                    periodTitle: .init(title: "Период", titleConfig: .init(textFont: .body, textColor: .black)),
                    transferTitle: .init(title: "Движение средств", titleConfig: .init(textFont: .body, textColor: .black)),
                    categoriesTitle:.init(title: "Категории", titleConfig: .init(textFont: .body, textColor: .black)),
                    button: .init(
                        selectBackgroundColor: Color.black,
                        notSelectedBackgroundColor: Color.gray.opacity(0.2),
                        selectForegroundColor: Color.white,
                        notSelectForegroundColor: Color.black
                    ), buttonsContainerConfig: .init(
                        clearButtonTitle: "Очистить",
                        applyButtonTitle: "Применить"
                    ), errorConfig: .init(
                        title: "Нет подходящих операций. \n Попробуйте изменить параметры фильтра",
                        titleConfig: .init(textFont: .system(size: 16), textColor: .gray)
                    )),
                clearOptionsAction: {},
                dismissAction: {}
            )
        }
    }
    
}
