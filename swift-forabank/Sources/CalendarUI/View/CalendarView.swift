//
//  CalendarView.swift
//
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import SwiftUI

struct OptionButtonView: View {
    
    let title: String
    @State var isSelected: Bool = false
    let action: () -> Void
    
    var body: some View {
        
        Button(
            action: action,
            label: label
        )
        .onTapGesture {
            self.isSelected.toggle()
        }
    }
    
    @ViewBuilder
    private func label() -> some View {
        
        Text(title)
            .foregroundColor(isSelected ? Color.white : Color.black)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().foregroundColor(isSelected ? Color.black.opacity(0.9) : Color.gray.opacity(0.1)))
        
    }
}

struct OptionsViewModel: Identifiable {

    var id: String { title }
    let title: String
    let isSelected: Bool
    let action: () -> Void
}

public struct CalendarView: View {
    
    @StateObject var selectedData: CalendarViewModel
    let monthsData: [Month]
    let configData: CalendarConfig

    init(
        _ selectedDate: Binding<Date?>?,
        _ selectedRange: Binding<MDateRange?>?,
        _ configBuilder: (CalendarConfig) -> CalendarConfig)
    {
        self._selectedData = .init(wrappedValue: .init(selectedDate, selectedRange))
        self.configData = configBuilder(.init())
        self.monthsData = .generate()
    }
    
    public var body: some View {
        
        VStack(spacing: 24) {
            
            HStack(spacing: 8) {
            
                OptionButtonView(title: "Неделя", isSelected: false) {
                    self._selectedData.wrappedValue.range = .init(.now.start(of: .month), .now.end(of: .weekday))
                }
                
                OptionButtonView(title: "Месяц", isSelected: false) {
                    self._selectedData.wrappedValue.range = .init(startDate: .now.start(of: .month), endDate: .now)
                }
                
                OptionButtonView(title: "Выбрать период", isSelected: false) {
                    self._selectedData.wrappedValue.range = .init()
                }
                
                Spacer()
            }
            
            createWeekdaysView()
            createScrollView()
        }
    }
}

private extension CalendarView {
    
    func createButtonsView() -> some View {
    
        Color.red.frame(width: 20, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
    
    func createWeekdaysView() -> some View {
        configData.weekdaysView().erased()
    }
    
    func createScrollView() -> some View { ScrollViewReader { reader in
        
        ScrollView(showsIndicators: false) {
            
            LazyVStack(spacing: configData.monthsSpacing) {
                
                ForEach(monthsData, id: \.month, content: createMonthItem)
            }
            .padding(.top, configData.monthsPadding.top)
            .padding(.bottom, configData.monthsPadding.bottom)
            .background(configData.monthsViewBackground)
        }
        .onAppear() { scrollToDate(reader, animatable: false) }
        .onChange(of: configData.scrollDate) { _ in scrollToDate(reader, animatable: true) }
    }}
}

private extension CalendarView {
    
    func createMonthItem(_ data: Month) -> some View {
        
        VStack(spacing: configData.monthLabelDaysSpacing) {
            
            createMonthLabel(data.month)
            createMonthView(data)
        }
    }
}
private extension CalendarView {
    
    func createMonthLabel(_ month: Date) -> some View {
        
        configData.monthLabel(month)
            .erased()
            .onAppear { onMonthChange(month) }
    }
    
    func createMonthView(_ data: Month) -> some View {
        
        MonthView(
            selectedDate: $selectedData.date,
            selectedRange: $selectedData.range,
            data: data,
            config: configData
        )
    }
}

public extension View {
    func erased() -> AnyView { .init(self) }
}
// MARK: - Modifiers
private extension CalendarView {
    
    func scrollToDate(_ reader: ScrollViewProxy, animatable: Bool) {
        
        guard let date = configData.scrollDate else { return }

        let scrollDate = date.start(of: .month)
        withAnimation(animatable ? .default : nil) { reader.scrollTo(scrollDate, anchor: .center) }
    }
    
    func onMonthChange(_ date: Date) { configData.onMonthChange(date) }
}

extension CalendarView {
    
    public init(
        selectedDate: Binding<Date?>?,
        selectedRange: Binding<MDateRange?>?,
        configBuilder: (CalendarConfig) -> CalendarConfig = { $0 }
    ) {
        self.init(selectedDate, selectedRange, configBuilder)
    }
}
