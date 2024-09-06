//
//  CalendarView.swift
//
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import SwiftUI

public struct CalendarView: View {
    
    var selectedData: CalendarViewModel
    let monthsData: [Month]
    let configuration: CalendarConfig

    var optionViewModel: [OptionsViewModel]
    
    public init(
        _ selectedDate: Date?,
        _ selectedRange: MDateRange?,
        _ optionViewModel: [OptionsViewModel] = [],
        _ startDate: Date?,
        _ configuration: CalendarConfig
    ) {
        
        self.selectedData = .init(selectedDate, selectedRange)
        self.configuration = configuration
        self.monthsData = .generate(startDate: startDate)
        self.optionViewModel = []
        
        self.optionViewModel = [
            .init(title: { "Неделя" }, type: .week, isSelected: false, action: { [self] in
                
                self.selectedData.range?.setLowerDate(.startOfWeek ?? Date())
                self.selectedData.range?.setUpperDate(Date())
            }),
            .init(title: { "Месяц" }, type: .month, isSelected: false, action: { [self] in
                
                self.selectedData.range?.setLowerDate(.startOfMonth)
                self.selectedData.range?.setUpperDate(Date())
            }),
            .init(title: { [self] in
                
                if let range = self.selectedData.range,
                   let lowerDate = range.lowerDate,
                   let upperDate = range.upperDate
                {
                    
                    let lowerString = DateFormatter.shortDate.string(from: lowerDate)
                    let upperString = DateFormatter.shortDate.string(from: upperDate)
                    
                    return "\(lowerString) - \(upperString)"
                } else {
                    return "Выбрать период"
                }
            }, type: .dates, isSelected: false, action: {
                
            })
        ]
    }
    
    public var body: some View {
        
        VStack(spacing: 24) {
            
            HStack(spacing: 8) {
            
                ForEach(optionViewModel, id: \.id) { item in
                
                    OptionButtonView(viewModel: item)
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
        configuration.weekdaysView().erased()
    }
    
    func scrollView() -> some View {
        
        ScrollViewReader { reader in
            
            ScrollView(showsIndicators: false) {
                
                LazyVStack(spacing: configuration.monthsSpacing) {
                    
                    ForEach(monthsData, id: \.month, content: monthItem)
                }
                .padding(.top, configuration.monthsPadding.top)
                .padding(.bottom, configuration.monthsPadding.bottom)
                .background(configuration.monthsViewBackground)
            }
            .onAppear() { scrollToDate(reader, animatable: false) }
            .onChange(of: configuration.scrollDate) { _ in
//                scrollToDate(reader, animatable: true)
            }
        }
    }
}

private extension CalendarView {
    
    func monthItem(_ data: Month) -> some View {
        
        VStack(spacing: configuration.monthLabelDaysSpacing) {
            
            monthLabel(data.month)
            monthView(data)
        }
    }
}
private extension CalendarView {
    
    func monthLabel(_ month: Date) -> some View {
        
        configuration.monthLabel(month)
            .erased()
            .onAppear { onMonthChange(month) }
    }
    
    func monthView(_ data: Month) -> some View {
        
        MonthView(
            selectedDate: selectedData.date,
            selectedRange: selectedData.range,
            data: data,
            config: configuration
        ) { date in
            self.selectedData.range?.addToRange(date)
        }
    }
}

public extension View {
    func erased() -> AnyView { .init(self) }
}
// MARK: - Modifiers
private extension CalendarView {
    
    func scrollToDate(_ reader: ScrollViewProxy, animatable: Bool) {
        
        guard let date = configuration.scrollDate else { return }

        let scrollDate = date.start(of: .month)
        withAnimation(animatable ? .default : nil) { reader.scrollTo(scrollDate, anchor: .center) }
    }
    
    func onMonthChange(_ date: Date) {
        configuration.onMonthChange(date)
    }
}

extension DateFormatter {
    
    static var shortDate: DateFormatter {

        let dateFormatter = DateFormatter()

        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.long

        dateFormatter.dateFormat =  "dd.MM.yy"
        dateFormatter.locale = Locale(identifier: "ru_RU")

        return dateFormatter
    }
}

public extension Date {
    static var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    static var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
    
    static var startOfMonth: Date {

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: Date())

        return  calendar.date(from: components)!
    }
    
}
