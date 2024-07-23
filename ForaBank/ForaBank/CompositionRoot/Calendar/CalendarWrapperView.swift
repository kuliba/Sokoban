//
//  CalendarWrapperView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 22.07.2024.
//

import Foundation
import SwiftUI
import CalendarUI

struct CalendarViewWrapper: View {
    
    @State private var selectedRange: MDateRange? = .init()
    let closeAction: () -> Void
    
    var body: some View {

        VStack(spacing: 24) {
            
            ZStack {
                
                calendarView()
                    .padding(10)
                
                VStack {
                    
                    Spacer()
                    
                    HStack {
                        
                        simpleButtonView(
                            title: "Закрыть",
                            action: closeAction
                        )
                        
                        simpleButtonView(
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
    
    func selectedRangeView() -> some View {
        SelectedRangeView(selectedRange: $selectedRange)
    }
    
    func calendarView() -> some View {
        CalendarView(selectedDate: nil, selectedRange: $selectedRange, configBuilder: configureCalendar)
    }
    
    func bottomView() -> some View {
        Button("Continue", action: closeAction)
            .padding(.top, 12)
            .padding(.horizontal, margins)
    }
    
    func simpleButtonView(
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
                .clipShape(.rect(cornerRadius: 12))
        }
    }
}

private extension CalendarViewWrapper {
    
    func configureCalendar(_ config: CalendarConfig) -> CalendarConfig {
       
        config
            .dayView(DV.RangeSelector.init)
//            .scrollTo(date: .now)
    }
}

// MARK: - Selected Range View
fileprivate struct SelectedRangeView: View {
    
    @Binding var selectedRange: MDateRange?

    var body: some View {
        HStack(spacing: 12) {
            dateText(startDateText)
            arrowIcon()
            dateText(endDateText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, margins)
        .animation(.bouncy, value: selectedRange?.getRange())
    }
}

private extension SelectedRangeView {
    func dateText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 24))
            .foregroundColor(.black)
            .lineLimit(1)
//            .contentTransition(.numericText(countsDown: true))
    }
    func arrowIcon() -> some View {
        Image("arrow-right")
            .resizable()
            .frame(width: 28)
            .foregroundColor(.black)
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

enum DV {}

extension DV {
    
    struct RangeSelector: DayView {
        
        let date: Date
        let isCurrentMonth: Bool
        let selectedDate: Binding<Date?>?
        var selectedRange: Binding<MDateRange?>? {
            didSet {
                print("print")
            }
        }
    }
}

extension DV.RangeSelector {
    
    func dayLabel() -> AnyView {
        
        Text(getStringFromDay(format: "d"))
            .font(.system(size: 15))
            .foregroundColor(isSelected() ? .white : .black)
            .opacity(isFuture() ? 0.2 : 1)
            .erased()
    }
}

// MARK: - On Selection Logic
extension DV.RangeSelector {
    func onSelection() { if !isFuture() {
        selectedRange?.wrappedValue?.addToRange(date)
    }}
}
