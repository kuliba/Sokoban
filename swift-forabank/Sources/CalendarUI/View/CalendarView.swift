//
//  CalendarView.swift
//
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import SwiftUI

public struct CalendarState  {
    
    public let date: Date?
    public var range: MDateRange?
    public let monthsData: [Month]
    public var selectPeriod: FilterHistoryState.Period?
    public let periods: [FilterHistoryState.Period]
    
    public init(
        date: Date?,
        range: MDateRange?,
        monthsData: [Month],
        selectPeriod: FilterHistoryState.Period? = nil,
        periods: [FilterHistoryState.Period]
    ) {
        self.date = date
        self.range = range
        self.monthsData = monthsData
        self.selectPeriod = selectPeriod
        self.periods = periods
    }
}

public enum CalendarEvent {
    
    case selectedDate(Date)
    case selectPeriod(FilterHistoryState.Period, lowerDate: Date, upperDate: Date)
    case selectCustomPeriod //MARK: Remove
}

public struct CalendarView: View {
    
    public typealias Event = CalendarEvent
    public typealias Config = CalendarConfig
    
    var state: CalendarState
    let event: (Event) -> Void
    let config: Config
        
    public init(
        state: CalendarState,
        event: @escaping (Event) -> Void,
        config: Config
    ) {
        self.state = state
        self.event = event
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: 24) {
            
            HStack {
                
                ForEach(state.periods) { period in
                
                    switch period {
                    case .week:
                        
                        Button {
                            
                            event(.selectPeriod(period, lowerDate: .startOfWeek ?? Date(), upperDate: Date()))
                            
                        } label: {
                           
                            if state.selectPeriod == .week {
                                
                                Text("Неделя")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Capsule().foregroundColor(config.optionSelectBackground))
                                
                            } else {
                                
                                Text("Неделя")
                                    .foregroundColor(Color.black)
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Capsule().foregroundColor(Color.gray.opacity(0.1)))
                            }
                        }
                    case .month:
                        
                        Button {
                            
                            event(.selectPeriod(period, lowerDate: .startOfMonth, upperDate: Date()))
                        } label: {
                            if state.selectPeriod == .month {
                                
                                Text("Месяц")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Capsule().foregroundColor(config.optionSelectBackground))
                                
                            } else {
                                
                                Text("Месяц")
                                    .foregroundColor(Color.black)
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Capsule().foregroundColor(Color.gray.opacity(0.1)))
                            }
                        }
                        
                    case .dates:
                        
                        Button {
                            
                            event(.selectCustomPeriod)
                            
                        } label: {
                            
                            if let range = state.range,
                               let lowerDate = range.lowerDate,
                               let upperDate = range.upperDate
                            {
                                
                                let lowerString = DateFormatter.shortDate.string(from: lowerDate)
                                let upperString = DateFormatter.shortDate.string(from: upperDate)
                                
                                HStack(spacing: 0) {
                                    
                                    Text("\(lowerString) - \(upperString)")
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 14))
                                        .padding(.leading, 12)
                                        .padding(.trailing, 4)
                                        .padding(.vertical, 6)
                                    
                                    config.closeImage
                                        .resizable()
                                        .frame(width: 16, height: 16, alignment: .center)
                                        .foregroundColor(.white)
                                        .padding(.trailing, 8)
                                    
                                }
                                .background(Capsule().foregroundColor(config.optionSelectBackground))


                            } else {
                                Text("Выбрать период")
                                    .foregroundColor(Color.black)
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Capsule().foregroundColor(Color.gray.opacity(0.1)))

                            }
                        }
                    }
                }
                
                Spacer()
            }
            
            weekdaysView()
            scrollView()
        }
    }
}

private extension CalendarView {
    
    func weekdaysView() -> some View {
        config.weekdaysView()
    }
    
    func scrollView() -> some View {
        
        ScrollViewReader { reader in
            
            ScrollView(showsIndicators: false) {
                
                LazyVStack(spacing: config.monthsSpacing) {
                    
                    ForEach(state.monthsData, id: \.month, content: monthItem)
                }
                .padding(.top, config.monthsPadding.top)
                .padding(.bottom, config.monthsPadding.bottom)
                .background(config.monthsViewBackground)
            }
            .onAppear() { scrollToDate(reader, animatable: false) }
            .onChange(of: config.scrollDate) { _ in }
        }
    }
}

private extension CalendarView {
    
    func monthItem(_ data: Month) -> some View {
        
        VStack(spacing: config.monthLabelDaysSpacing) {
            
            monthLabel(data.month)
                .font(config.month.textFont)
                .foregroundColor(config.month.textColor)
            
            monthView(data)
        }
    }
}
private extension CalendarView {
    
    func monthLabel(_ month: Date) -> some View {
        
        config.monthLabel(month)
            .erased()
            .onAppear { onMonthChange(month) }
    }
    
    func monthView(_ data: Month) -> some View {
        
        MonthView(
            selectedDate: state.date,
            selectedRange: state.range,
            data: data,
            config: config
        ) { date in
            event(.selectedDate(date))
        }
    }
}

public extension View {
    func erased() -> AnyView { .init(self) }
}
// MARK: - Modifiers
private extension CalendarView {
    
    func scrollToDate(_ reader: ScrollViewProxy, animatable: Bool) {
        
        guard let date = config.scrollDate else { return }

        let scrollDate = date.start(of: .month)
        withAnimation(animatable ? .default : nil) { reader.scrollTo(scrollDate, anchor: .center) }
    }
    
    func onMonthChange(_ date: Date) {
        config.onMonthChange(date)
    }
}

public extension CalendarState {

    var selectedRange: Range<Date>? {
     
        if let lowerDate = range?.lowerDate,
        let upperDate = range?.upperDate {
            return lowerDate..<upperDate
            
        } else {
            
            return nil
        }
    }
}
