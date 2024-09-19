//
//  FilterView.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//


import SwiftUI
import SharedConfigs
import RxViewModel

public enum FilterEffect: Equatable {}

public struct FilterWrapperView: View {
    
    public typealias State = FilterState
    public typealias Event = FilterEvent
    public typealias Effect = FilterEffect
    public typealias Config = FilterConfig
    
    public typealias Model = RxViewModel<State, Event, Effect>
    
    @ObservedObject private var model: Model
    private let config: Config
    private let calendarViewAction: (CalendarState) -> Void

    public init(
        model: Model,
        config: Config,
        calendarViewAction: @escaping (CalendarState) -> Void
    ) {
        self.model = model
        self.calendarViewAction = calendarViewAction
        self.config = config
    }
    
    public var body: some View {
    
        FilterView(
            filterState: model.state,
            event: model.event(_:),
            config: config,
            calendarViewAction: calendarViewAction
        )
    }
}

public struct FilterView: View {
    
    public typealias Event = FilterEvent
    public typealias Config = FilterConfig
    
    private let initialState: FilterState
    @State private var filterState: FilterState
    let filterEvent: (Event) -> Void
    let config: Config
    
    let calendarViewAction: (CalendarState) -> Void
    
    public init(
        filterState: FilterState,
        event: @escaping (Event) -> Void,
        config: Config,
        calendarViewAction: @escaping (CalendarState) -> Void
    ) {
        self._filterState = .init(wrappedValue: filterState)
        self.initialState = filterState
        self.filterEvent = event
        self.config = config
        self.calendarViewAction = calendarViewAction
    }
    
    public var body: some View {
        
        VStack(alignment: .leading) {
            
            Text(filterState.filter.title)
                .font(.system(size: 18))
                .padding(.bottom, 10)
            
            config.periodTitle.title.text(withConfig: config.periodTitle.titleConfig)
                .padding(.bottom, 5)
            
            PeriodContainer(
                state: filterState,
                event: { event in

                    switch event {
                    case .calendar:
                        calendarViewAction(filterState.calendar)
                    case .clearOptions:
                        filterEvent(.clearOptions)
                    case let .selectPeriod(period):
                        filterState.filter.selectedPeriod = period
                        
                        switch period {
                        case .week:
                            filterState.filter.selectDates = .some((lowerDate: .startOfWeek, upperDate: Date()))
                            
                        case .month:
                            filterState.filter.selectDates = .some((lowerDate: .startOfMonth, upperDate: Date()))
                            
                        case .dates:
                            break
                        }
                    }
                },
                config: .init(
                    selectBackgroundColor: config.optionConfig.selectBackgroundColor,
                    closeImage: config.optionButtonCloseImage
                )
            )
            //MARK: Remove
//            .onAppear {
//                filterState.filter.selectDates = .some((lowerDate: .startOfMonth, upperDate: Date()))
//            }
            
            if !filterState.filter.services.isEmpty {
                
                config.transactionTitle.title.text(withConfig: config.transactionTitle.titleConfig)
                    .padding(.bottom, 5)
                
                TransactionContainer(
                    transactions: filterState.filter.transactionType,
                    selectedTransaction: filterState.filter.selectedTransaction,
                    event: { transaction in
                        
                        self.filterState.filter.selectedTransaction = transaction
                    },
                    config: config
                )
                
                config.categoryTitle.title.text(withConfig: config.categoryTitle.titleConfig)
                    .padding(.bottom, 5)
                
                FlexibleContainerButtons(
                    data: filterState.filter.services.sorted(),
                    selectedItems: filterState.filter.selectedServices,
                    serviceButtonTapped: { service in
                        
                        if filterState.filter.selectedServices.contains(service) {
                            
                            self.filterState.filter.selectedServices.remove(service)
                        } else {
                            self.filterState.filter.selectedServices.insert(service)
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
            
            ButtonsContainer(
                applyAction: {
                    
                    filterEvent(.updateFilter(filterState))
                },
                clearOptionsAction: {
                    filterEvent(.clearOptions)
                    filterState = initialState
                },
                config: .init(
                    clearButtonTitle: "Очистить",
                    applyButtonTitle: "Применить"
                )
            )
        }
        .padding()
    }
}

extension FilterView {
    
    struct PeriodState {
        
        let periods: [FilterHistoryState.Period]
        let selectedDates: (lowerDate: Date?, upperDate: Date?)?
        var selectedPeriod: FilterHistoryState.Period = .month
    }
    
    enum PeriodEvent {
        
        case calendar
        case clearOptions
        case selectPeriod(FilterHistoryState.Period)
    }
    
    struct PeriodContainer: View {
        
        typealias Config = PeriodConfig
        typealias Event = PeriodEvent
        
        let state: FilterState
        let event: (Event) -> Void
        let config: Config
                
        var body: some View {
            
            HStack {
                
                ForEach(state.filter.periods, id: \.self) { period in
                    
                    if period == .dates {
                        
                        HStack {
                            
                            Button(action: { event(.calendar) }) {
                                
                                if let lowerDate = state.filter.selectDates?.lowerDate,
                                   let upperDate = state.filter.selectDates?.upperDate {
                                    
                                    Text("\(DateFormatter.shortDate.string(from: lowerDate)) - \(DateFormatter.shortDate.string(from: upperDate))")
                                    
                                } else {
                                    
                                    Text(period.id)
                                }
                            }
                            
                            if let _ = state.filter.selectDates?.lowerDate,
                               let _ = state.filter.selectDates?.upperDate {
                                
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
                                .background(state.filter.selectedPeriod == period ? config.selectBackgroundColor : .gray.opacity(0.2))
                                .foregroundColor(state.filter.selectedPeriod == period ? Color.white : Color.black)
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
        let selectBackgroundColor: Color
        let closeImage: Image
    }
    
    struct TransactionContainer: View {
        
        let transactions: [FilterHistoryState.TransactionType]
        var selectedTransaction: FilterHistoryState.TransactionType?
        let event: (FilterHistoryState.TransactionType) -> Void
        let config: Config
        
        var body: some View {
            
            HStack {
                
                ForEach(transactions, id: \.self) { transaction in
                    
                    Button(action: { event(transaction) }) {
                        
                        Text(transaction.title)
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
                    productId: nil,
                    calendar: .init(date: nil, range: nil, monthsData: [], periods: []),
                    filter: .init(
                        title: "Фильтры",
                        selectDates: nil,
                        selectedServices: [],
                        periods: FilterHistoryState.Period.allCases,
                        transactionType: FilterHistoryState.TransactionType.allCases,
                        services: ["Неделя", "Месяц", "Выбрать период"]
                    )
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
                calendarViewAction: {_ in }
            )
        }
    }
    
}
