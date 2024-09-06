//
//  ContentView.swift
//  CalendarPreview
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import SwiftUI
import CalendarUI

struct ContentView: View {
    
    @State private var selectedDate: Date? = nil
    @State private var selectedRange: MDateRange? = .init()
    @State private var showingSheet = false

    var body: some View {
        
        Button("CalendarView") {
            showingSheet.toggle()
        }
        .sheet(isPresented: $showingSheet) {
            
            NavigationStack {
                
                CalendarViewWrapper(closeAction: { showingSheet = false })
                    .navigationTitle("Выберите даты или период")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    ContentView()
}

struct CalendarViewWrapper: View {
    
    @State private var selectedRange: MDateRange? = .init()
    let closeAction: () -> Void
    
    var body: some View {

        VStack(spacing: 24) {
            
            ZStack {
                
                createCalendarView()
                    .padding(10)
                
                VStack {
                    
                    Spacer()
                    
                    HStack {
                        
                        createSimpleButtonView(
                            title: "Закрыть",
                            action: closeAction
                        )
                        
                        createSimpleButtonView(
                            title: selectedRange?.rangeSelected == true ? "Показать" : "Выбрать",
                            action: closeAction
                        )
                        .allowsHitTesting(selectedRange?.rangeSelected == true ? false : true)
                        
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 30)
                    
                }
            }
        }
    }
}

private extension CalendarViewWrapper {
    
    func createSelectedRangeView() -> some View {
        SelectedRangeView(selectedRange: $selectedRange)
    }
    
    func createCalendarView() -> some View {
        CalendarView(nil, nil, [], nil, CalendarConfig(
            weekdaysView: {
                WeekdaysView.init()
            },
            monthLabel: { date in
                MonthLabel(month: date)
            },
            dayView: { date, isCurrentMonth, selectedDate, selectedRange, selectDate in
                DayView(
                    date: date,
                    isCurrentMonth: isCurrentMonth,
                    selectedDate: selectedDate,
                    selectedRange: selectedRange,
                    selectDate: selectDate
                )
            }
        ))
    }
    
    func createSimpleButtonView(
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        
        Button(action: action) {
            
            Text(title)
                .frame(minWidth: 100, idealWidth: 100, maxWidth: .infinity, minHeight: 56, idealHeight: 56, maxHeight: 56, alignment: .center)
                .padding(.horizontal, 16)
                .background(Color.gray)
                .foregroundColor(.white)
                .font(.system(size: 18))
                .fontWeight(.semibold)
                .clipShape(.rect(cornerRadius: 12))
        }
    }
}

private extension CalendarViewWrapper {
    
    func configureCalendar(_ config: CalendarConfig) -> CalendarConfig {
       
        config
//            .scrollTo(date: .now)
    }
}

// MARK: - Selected Range View
fileprivate struct SelectedRangeView: View {
    
    @Binding var selectedRange: MDateRange?

    var body: some View {
        
        HStack(spacing: 12) {
            createDateText(startDateText)
            createArrowIcon()
            createDateText(endDateText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, margins)
        .animation(.bouncy, value: selectedRange?.getRange())
    }
}

private extension SelectedRangeView {
    func createDateText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 24))
            .foregroundStyle(.black)
            .lineLimit(1)
            .contentTransition(.numericText(countsDown: true))
    }
    func createArrowIcon() -> some View {
        Image("arrow-right")
            .resizable()
            .frame(width: 28)
            .foregroundStyle(.black)
    }
}

private extension SelectedRangeView {
    var startDateText: String {
        guard let date = selectedRange?.getRange()?.lowerBound else { return "N/A" }
        return dateFormatter.string(from: date)
    }
    var endDateText: String {
        guard let date = selectedRange?.getRange()?.upperBound else { return "N/A" }
        return dateFormatter.string(from: date)
    }
}

private extension SelectedRangeView {
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d"
        return dateFormatter
    }
}


// MARK: - Modifiers
fileprivate let margins: CGFloat = 24
