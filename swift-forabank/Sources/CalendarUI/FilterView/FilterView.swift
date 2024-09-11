//
//  FilterView.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//


import SwiftUI
import SharedConfigs

public struct FilterView: View {
    
    public typealias Event = FilterEvent
    public typealias Config = FilterConfig
    
    @State var filterState: FilterState
    let filterEvent: (Event) -> Void
    let config: Config
    
    let makeButtonsContainer: (@escaping () -> Void, FilterState) -> ButtonsContainer
    let clearOptionsAction: () -> Void
    let dismissAction: () -> Void
    let calendarViewAction: () -> Void
    
    public init(
        filterState: FilterState,
        event: @escaping (Event) -> Void,
        config: Config,
        makeButtonsContainer: @escaping (@escaping () -> Void, FilterState) -> ButtonsContainer,
        clearOptionsAction: @escaping () -> Void,
        dismissAction: @escaping () -> Void,
        calendarViewAction: @escaping () -> Void
    ) {
        self._filterState = .init(wrappedValue: filterState)
        self.filterEvent = event
        self.config = config
        self.makeButtonsContainer = makeButtonsContainer
        self.clearOptionsAction = clearOptionsAction
        self.dismissAction = dismissAction
        self.calendarViewAction = calendarViewAction
    }
    
    public var body: some View {
        
        VStack(alignment: .leading) {
            
            Text(filterState.title)
                .font(.system(size: 18))
                .padding(.bottom, 10)
            
            config.periodTitle.title.text(withConfig: config.periodTitle.titleConfig)
                .padding(.bottom, 5)
            
            PeriodContainer(
                state: filterState,
                event: { event in
                    
                    switch event {
                    case .calendar:
                        calendarViewAction()
                    case .clearOptions:
                        filterEvent(.clearOptions)
                    case let .selectPeriod(period):
                        filterState.selectedPeriod = period
                    }
                },
                config: .init(closeImage: config.optionButtonCloseImage)
            )
            
            if !filterState.services.isEmpty {
                
                config.transactionTitle.title.text(withConfig: config.transactionTitle.titleConfig)
                    .padding(.bottom, 5)
                
                TransactionContainer(
                    transactions: filterState.transactionType,
                    selectedTransaction: filterState.selectedTransaction,
                    event: { transaction in
                        
                        self.filterState.selectedTransaction = transaction
                    },
                    config: config
                )
                
                config.categoryTitle.title.text(withConfig: config.categoryTitle.titleConfig)
                    .padding(.bottom, 5)
                
                FlexibleContainerButtons(
                    data: filterState.services.sorted(),
                    selectedItems: filterState.selectedServices,
                    serviceButtonTapped: { service in
                        
                        if filterState.selectedServices.contains(service) {
                            
                            self.filterState.selectedServices.remove(service)
                        } else {
                            self.filterState.selectedServices.insert(service)
                        }
                    },
                    config: .init(
                        title: "",
                        titleConfig: .init(
                            textFont: .callout,
                            textColor: .red
                        ))
                )
            }
            
            Spacer()
            
            makeButtonsContainer({
                filterEvent(.selectedPeriod(filterState.selectedPeriod))
                filterEvent(.selectedTransaction(filterState.selectedTransaction))
                filterEvent(.selectedCategory(filterState.selectedServices))
            },filterState)
        }
        .padding()
    }
}

extension FilterView {
    
    struct PeriodState {
        
        let periods: [FilterState.Period]
        let selectedDates: (lowerDate: Date?, upperDate: Date?)?
        var selectedPeriod: FilterState.Period = .month
    }
    
    enum PeriodEvent {
        
        case calendar
        case clearOptions
        case selectPeriod(FilterState.Period)
    }
    
    struct PeriodContainer: View {
        
        typealias Config = PeriodConfig
        typealias Event = PeriodEvent
        
        let state: FilterState
        let event: (Event) -> Void
        let config: Config
                
        var body: some View {
            
            HStack {
                
                ForEach(state.periods, id: \.self) { period in
                    
                    if period == .dates {
                        
                        HStack {
                            
                            Button(action: { event(.calendar) }) {
                                
                                if let lowerDate = state.selectDates?.lowerDate,
                                   let upperDate = state.selectDates?.upperDate {
                                    
                                    Text("\(DateFormatter.shortDate.string(from: lowerDate)) - \(DateFormatter.shortDate.string(from: upperDate))")
                                    
                                } else {
                                    
                                    Text(period.id)
                                }
                            }
                            
                            if let _ = state.selectDates?.lowerDate,
                               let _ = state.selectDates?.upperDate {
                                
                                Button { event(.clearOptions) } label: {
                                    
                                    config.closeImage
                                }
                            }

                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(Color.black)
                        .frame(height: 32)
                        .cornerRadius(90)
                        
                    } else {
                        
                        Button(action: {
                            
                            event(.selectPeriod(period))
                            
                        }) {
                            
                            Text(period.id)
                                .padding()
                                .background(state.selectedPeriod == period ? Color.black : .gray.opacity(0.2))
                                .foregroundColor(state.selectedPeriod == period ? Color.white : Color.black)
                                .frame(height: 32)
                                .cornerRadius(90)
                        }
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    struct PeriodConfig {
    
        let closeImage: Image
    }
    
    struct TransactionContainer: View {
        
        let transactions: [FilterState.TransactionType]
        var selectedTransaction: FilterState.TransactionType?
        let event: (FilterState.TransactionType) -> Void
        let config: Config
        
        var body: some View {
            
            HStack {
                
                ForEach(transactions, id: \.self) { transaction in
                    
                    Button(action: { event(transaction) }) {
                        
                        Text(transaction.id)
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
    
    let applyAction: () -> Void
    let clearOptionsAction: () -> Void
    
    let config: Config
    
    public init(
        applyAction: @escaping () -> Void,
        clearOptionsAction: @escaping () -> Void,
        config: Config
    ) {
        self.applyAction = applyAction
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
                action: applyAction,
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
                .foregroundColor(config.foreground)
                .background(config.background)
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
    let serviceButtonTapped: (String) -> Void
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
                                textColor: .white
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
    let action: (String) -> Void
    let config: Config
    
    var body: some View {
        
        Button(action: { action(self.config.title) }) {
            
            Text(config.title)
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
                filterState: .init(
                    title: "Фильтры",
                    selectDates: nil,
                    selectedServices: [],
                    periods: FilterState.Period.allCases,
                    transactionType: FilterState.TransactionType.allCases,
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
                    ), 
                    optionButtonCloseImage: .init(systemName: "")
                ),
                makeButtonsContainer: { _,_  in 
                    .init(
                        applyAction: {},
                        clearOptionsAction: {},
                        config: .init(
                            clearButtonTitle: "Очистить",
                            applyButtonTitle: "Применить"
                        )
                    )
                },
                clearOptionsAction: {},
                dismissAction: {},
                calendarViewAction: {}
            )
        }
    }
    
}
