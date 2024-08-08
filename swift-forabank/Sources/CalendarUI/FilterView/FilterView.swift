//
//  FilterView.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//


import SwiftUI
import SharedConfigs

public struct FilterView: View {
    
    public typealias State = FilterState
    public typealias Event = FilterEvent
    public typealias Config = FilterConfig
    
    var state: State
    let event: (Event) -> Void
    let config: Config
    
    let makeButtonsContainer: () -> ButtonsContainer
    let clearOptionsAction: () -> Void
    let dismissAction: () -> Void
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        config: Config,
        makeButtonsContainer: @escaping () -> ButtonsContainer,
        clearOptionsAction: @escaping () -> Void,
        dismissAction: @escaping () -> Void
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.makeButtonsContainer = makeButtonsContainer
        self.clearOptionsAction = clearOptionsAction
        self.dismissAction = dismissAction
    }
    
    public var body: some View {
        
        VStack(alignment: .leading) {
            
            Text(state.title)
                .font(.system(size: 18))
                .padding(.bottom, 10)
            
            config.periodTitle.title.text(withConfig: config.periodTitle.titleConfig)
                .padding(.bottom, 5)
            
            PeriodContainer(
                periods: state.periods,
                event: { event in  }
            )
            
            if !state.services.isEmpty {
                
                config.transactionTitle.title.text(withConfig: config.transactionTitle.titleConfig)
                    .padding(.bottom, 5)
                
                TransactionContainer(
                    transactions: state.transactions,
                    event: { event in },
                    config: config
                )
                
                config.categoryTitle.title.text(withConfig: config.categoryTitle.titleConfig)
                    .padding(.bottom, 5)
                
                FlexibleContainerButtons(
                    data: state.services,
                    selectedItems: state.selectedServices,
                    serviceButtonTapped: {},
                    config: .init(
                        title: "",
                        titleConfig: .init(
                            textFont: .callout,
                            textColor: .red
                        ))
                )
            }
            
            Spacer()
            
            makeButtonsContainer()
        }
        .padding()
    }
}

extension FilterView {
    
    struct PeriodContainer: View {
        
        let periods: [String]
        var selectedPeriod = "Месяц"
        let event: (Event) -> Void
        
        var body: some View {
            
            HStack {
                
                ForEach(periods, id: \.self) { period in
                    
                    Button(action: { event(.selectedPeriod(period)) }) {
                        
                        Text(period)
                            .padding()
                            .background(selectedPeriod == period ? Color.black : .gray.opacity(0.2))
                            .foregroundColor(selectedPeriod == period ? Color.white : Color.black)
                            .frame(height: 32)
                            .cornerRadius(90)
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    struct TransactionContainer: View {
        
        let transactions: [String]
        var selectedTransaction = ""
        let event: (Event) -> Void
        let config: Config
        
        var body: some View {
            
            HStack {
                
                ForEach(transactions, id: \.self) { transaction in
                    
                    Button(action: { event(.selectedTransaction(transaction)) }) {
                        
                        Text(transaction)
                            .padding()
                            .background(selectedTransaction == transaction ? config.optionConfig.selectBackgroundColor : config.optionConfig.notSelectedBackgroundColor)
                            .foregroundColor(selectedTransaction == transaction ? config.optionConfig.selectForegroundColor : config.optionConfig.notSelectForegroundColor)
                            .frame(height: 32)
                            .cornerRadius(90)
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }
}

public struct ButtonsContainer: View {
    
    let dismissAction: () -> Void
    let clearOptionsAction: () -> Void
    
    let config: Config
    
    public init(
        dismissAction: @escaping () -> Void,
        clearOptionsAction: @escaping () -> Void,
        config: Config
    ) {
        self.dismissAction = dismissAction
        self.clearOptionsAction = clearOptionsAction
        self.config = config
    }
    
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

struct FlexibleContainerButtons: View {
    
    let data: [String]
    var selectedItems: Set<String>
    let serviceButtonTapped: () -> Void
    let config: ServiceButton.Config
    
    var body: some View {
        
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        GeometryReader { geometry in
            
            ZStack(alignment: .topLeading) {
                
                ForEach(data, id: \.self) { service in
                    
                    ServiceButton(
                        state: .init(isSelected: selectedItems.contains(service)),
                        action: serviceButtonTapped,
                        config: .init(
                            title: service,
                            titleConfig: .init(
                                textFont: .system(size: 16),
                                textColor: .black
                            ))
                    )
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
                if service == data.last {
                    width = 0
                } else {
                    width -= dimension.width
                }
                return result
            })
            .alignmentGuide(.top, computeValue: { _ in
                let result = height
                if service == data.last {
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

public struct TitleConfig {
    
    let title: String
    let titleConfig: TextConfig
    
    public init(
        title: String,
        titleConfig: TextConfig
    ) {
        self.title = title
        self.titleConfig = titleConfig
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
                    services: ["Неделя", "Месяц", "Выбрать период"]
                ),
                event: { _ in },
                config: .init(
                    title: .init(
                        title: "Фильтры",
                        titleConfig: .init(
                            textFont: .body,
                            textColor: .orange
                        )
                    ),
                    periodTitle: .init(
                        title: "Период",
                        titleConfig: .init(
                            textFont: .body,
                            textColor: .red
                        )
                    ),
                    transactionTitle: .init(
                        title: "Движение средств",
                        titleConfig: .init(
                            textFont: .body,
                            textColor: .red
                        )
                    ),
                    categoryTitle: .init(
                        title: "Категории",
                        titleConfig: .init(
                            textFont: .body,
                            textColor: .red
                        )
                    ),
                    optionConfig: .init(
                        selectBackgroundColor: Color.black,
                        notSelectedBackgroundColor: Color.gray.opacity(0.2),
                        selectForegroundColor: Color.white,
                        notSelectForegroundColor: Color.black
                    ),
                    buttonsContainerConfig: .init(
                        clearButtonTitle: "Очистить",
                        applyButtonTitle: "Применить"
                    ),
                    errorConfig: .init(
                        title: "Нет подходящих операций. \n Попробуйте изменить параметры фильтра",
                        titleConfig: .init(textFont: .system(size: 16), textColor: .gray)
                    )
                ),
                makeButtonsContainer: {
                    .init(
                        dismissAction: {},
                        clearOptionsAction: {},
                        config: .init(
                            clearButtonTitle: "Очистить",
                            applyButtonTitle: "Применить"
                        )
                    )
                },
                clearOptionsAction: {},
                dismissAction: {}
            )
        }
    }
    
}
