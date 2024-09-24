//
//  FilterView.swift
//
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//


import SwiftUI
import SharedConfigs
import RxViewModel
import Shimmer

public typealias FilterViewModel = RxViewModel<FilterState, FilterEvent, FilterEffect>

public struct FilterWrapperView<ButtonsView: View>: View {
    
    public typealias Model = FilterViewModel
    public typealias State = FilterState
    public typealias Event = FilterEvent
    public typealias Effect = FilterEffect
    public typealias Config = FilterConfig
        
    @ObservedObject private var model: Model
    private let config: Config
    private let calendarViewAction: (CalendarState) -> Void
    private let buttonsView: () -> ButtonsView

    public init(
        model: Model,
        config: Config,
        calendarViewAction: @escaping (CalendarState) -> Void,
        buttonsView: @escaping () -> ButtonsView
    ) {
        self.model = model
        self.calendarViewAction = calendarViewAction
        self.config = config
        self.buttonsView = buttonsView
    }
    
    public var body: some View {
        
        FilterView(
            filterState: model.state,
            event: model.event(_:),
            config: config,
            calendarViewAction: calendarViewAction,
            buttonsView: buttonsView
        )
    }
}

public struct FilterView<ButtonsView: View>: View {
    
    public typealias Event = FilterEvent
    public typealias Config = FilterConfig
    
    private let filterState: FilterState
    private let filterEvent: (Event) -> Void
    private let config: Config
    private let buttonsView: () -> ButtonsView

    private let calendarViewAction: (CalendarState) -> Void
    
    public init(
        filterState: FilterState,
        event: @escaping (Event) -> Void,
        config: Config,
        calendarViewAction: @escaping (CalendarState) -> Void,
        buttonsView: @escaping () -> ButtonsView
    ) {
        self.filterState = filterState
        self.filterEvent = event
        self.config = config
        self.calendarViewAction = calendarViewAction
        self.buttonsView = buttonsView
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
                        switch period {
                        case .week:
                            filterEvent(.selectedDates((.startOfWeek ?? Date())..<Date(), period))
                            
                        case .month:
                            filterEvent(.selectedDates((.startOfMonth)..<(Date()), period))
                            
                        case .dates:
                            break
                        }
                        
                        filterEvent(.selectedPeriod(period))
                    }
                },
                config: .init(
                    font: config.optionConfig.font,
                    selectBackgroundColor: config.optionConfig.selectBackgroundColor,
                    closeImage: config.optionButtonCloseImage
                )
            )
            
            switch filterState.status {
            case .empty:
                ErrorView(config: config.emptyConfig)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .failure:
                ErrorView(config: config.failureConfig)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loading:
                PlaceHolderFilterView(state: filterState, config: config)
                
            case .normal:
                
                if !filterState.filter.services.isEmpty {
                    
                    config.transactionTitle.title.text(withConfig: config.transactionTitle.titleConfig)
                        .padding(.bottom, 5)
                    
                    TransactionContainer(
                        transactions: filterState.filter.transactionType,
                        selectedTransaction: filterState.filter.selectedTransaction,
                        event: {
                            filterEvent(.selectedTransaction($0))
                        },
                        config: config
                    )
                    
                    config.categoryTitle.title.text(withConfig: config.categoryTitle.titleConfig)
                        .padding(.bottom, 5)
                    
                    FlexibleContainerButtons(
                        data: filterState.filter.services.sorted(),
                        selectedItems: filterState.filter.selectedServices,
                        serviceButtonTapped: {
                            filterEvent(.selectedCategory($0))
                        },
                        config: .init(
                            title: "",
                            titleConfig: .init(
                                textFont: .callout,
                                textColor: .red
                            ))
                    )
                }
                
            }
            Spacer()
            
            buttonsView()
        }
        .padding()
    }
}

private extension FilterState {
    
    func formattedPeriod(
        fallback: String
    ) -> String {
        
        if let lowerDate = filter.selectDates?.lowerBound,
           let upperDate = filter.selectDates?.upperBound,
           filter.selectedPeriod == .dates {
            
            "\(DateFormatter.shortDate.string(from: lowerDate)) - \(DateFormatter.shortDate.string(from: upperDate))"
            
        } else {
            
            fallback
        }
    }
}

private extension FilterView {
    
    struct PeriodState {
        
        let periods: [FilterHistoryState.Period]
        let selectedDates: (lowerDate: Date?, upperDate: Date?)?
        var selectedPeriod: FilterHistoryState.Period = .dates
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
                        
                        HStack(spacing: 4) {
                            
                            Button(action: { 
                                event(.calendar)
                                event(.selectPeriod(period))
                            }) {
                                
                                Text(state.formattedPeriod(fallback: period.id))
                                    .font(config.font)

                            }
                            
                            if state.filter.selectDates?.lowerBound != nil,
                               state.filter.selectDates?.upperBound != nil,
                               state.filter.selectedPeriod == .dates {
                                
                                Button { event(.clearOptions) } label: {
                                    
                                    config.closeImage
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .background(state.filter.selectedPeriod == period ? config.selectBackgroundColor : .gray.opacity(0.2))
                        .foregroundColor(state.filter.selectedPeriod == period ? Color.white : Color.black)
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
                                .font(config.font)
                        }
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    struct PeriodConfig {
        let font: Font
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
                    productId: 0,
                    calendar: .init(date: nil, range: nil, monthsData: [], periods: []),
                    filter: .init(
                        title: "Фильтры",
                        selectDates: nil, 
                        selectedPeriod: .month,
                        selectedServices: [],
                        periods: FilterHistoryState.Period.allCases,
                        transactionType: FilterHistoryState.TransactionType.allCases,
                        services: ["Неделя", "Месяц", "Выбрать период"]
                    ),
                    status: .normal
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
                        font: .body,
                        selectBackgroundColor: Color.black,
                        notSelectedBackgroundColor: Color.gray.opacity(0.2),
                        selectForegroundColor: Color.white,
                        notSelectForegroundColor: Color.black
                    ),
                    buttonsContainerConfig: .init(
                        clearButtonTitle: "Очистить",
                        applyButtonTitle: "Применить"
                    ),
                    optionButtonCloseImage: .init(systemName: ""),
                    failureConfig: .init(
                        title: "Мы не смогли загрузить данные.\nПопробуйте позже.",
                        titleConfig: .init(textFont: .body, textColor: .red),
                        icon: .init(systemName: "slider.horizontal.2.square"),
                        iconForeground: .black,
                        backgroundIcon: .gray
                    ),
                    emptyConfig: .init(
                        title: "В этот период операции отсутствовали",
                        titleConfig: .init(textFont: .body, textColor: .red),
                        icon: .init(systemName: "slider.horizontal.2.square"),
                        iconForeground: .black,
                        backgroundIcon: .gray
                    )
                ),
                calendarViewAction: {_ in },
                buttonsView: { Text("Buttons") }
            )
        }
    }
    
}
