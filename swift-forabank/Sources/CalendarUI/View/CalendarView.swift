//
//  CalendarView.swift
//
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import SwiftUI

public struct CalendarState {
    
    let date: Date?
    public let range: MDateRange?
    let monthsData: [Month]
    let selectPeriod: FilterState.Period? = nil
    let periods: [FilterState.Period]
    
    public init(
        date: Date?,
        range: MDateRange?,
        monthsData: [Month],
        periods: [FilterState.Period]
    ) {
        self.date = date
        self.range = range
        self.monthsData = monthsData
        self.periods = periods
    }
}
//self.monthsData = .generate(startDate: startDate)

public enum CalendarEvent {
    
}

public struct CalendarView: View {
    
    public typealias State = CalendarState
    public typealias Event = CalendarEvent
    public typealias Config = CalendarConfig
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        config: Config
    ) {
        self.state = state
        self.event = event
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: 24) {
            
//            HStack(spacing: 8) {
//            
//                ForEach(state.periods, id: \.id) { item in
//                    
//                    OptionButtonView(state: .init(
//                        title: item.id,
//                        type: item,
//                        range: state.selectedData.range
//                    ))
//                        .font(config.option.textFont)
//                        .foregroundColor(item == state.selectPeriod ? Color.white : Color.black)
//                        .background(Capsule().foregroundColor(item == state.selectPeriod ? Color.black.opacity(0.9) : Color.gray.opacity(0.1)))
//                }
//
//                
//                Spacer()
//            }
            
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
            .onChange(of: config.scrollDate) { _ in
//                scrollToDate(reader, animatable: true)
            }
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
            self.state.range?.addToRange(date)
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
